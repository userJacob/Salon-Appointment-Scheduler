#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT * FROM services;")

SERVICE_SELECTION() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  echo -e "\nSelect a service:"
  echo "$SERVICES" | while read ID BAR SERVICE
  do
    echo "$ID) $SERVICE"
  done

  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    SERVICE_SELECTION "Please enter one of the following numbers:"
  else
    SERVICE_VERIFICATION=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
    if [[ -z $SERVICE_VERIFICATION ]]
    then
      SERVICE_SELECTION "Please enter one of the following numbers:"
    else
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
      echo -e "\nWhat is your phone number?"
      read CUSTOMER_PHONE
      EXISTING_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE';")
      if [[ -z $EXISTING_PHONE ]]
      then
        echo -e "\nWhat is your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
      else
        CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
      fi
      
      echo -e "\nWhen would you like to come in?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');") 
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -E 's/^ *| *$//g'), $( echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    fi
  fi
}

SERVICE_SELECTION