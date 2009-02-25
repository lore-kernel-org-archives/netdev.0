From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 5/5] drivers/isdn/hardware/eicon: fix sparse warnings: Should
	it be static?
Date: Thu, 26 Feb 2009 00:11:37 +0100
Message-ID: <20090225231131.5377.81409.stgit@localhost.localdomain>
References: <20090225230737.5377.31370.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f178.google.com ([209.85.218.178]:49403 "EHLO
	mail-bw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763612AbZBYXLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 18:11:44 -0500
In-Reply-To: <20090225230737.5377.31370.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Make symbols static.

Fix this sparse warnings:
  drivers/isdn/hardware/eicon/message.c:1197:6: warning: symbol 'connect_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1414:6: warning: symbol 'connect_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1570:6: warning: symbol 'connect_a_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1576:6: warning: symbol 'disconnect_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1631:6: warning: symbol 'disconnect_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1658:6: warning: symbol 'listen_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1707:6: warning: symbol 'info_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1816:6: warning: symbol 'info_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1822:6: warning: symbol 'alert_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:1852:6: warning: symbol 'facility_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:2602:6: warning: symbol 'facility_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:2608:6: warning: symbol 'connect_b3_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:2842:6: warning: symbol 'connect_b3_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:2957:6: warning: symbol 'connect_b3_a_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:2977:6: warning: symbol 'disconnect_b3_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3033:6: warning: symbol 'disconnect_b3_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3089:6: warning: symbol 'data_b3_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3166:6: warning: symbol 'data_b3_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3199:6: warning: symbol 'reset_b3_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3240:6: warning: symbol 'reset_b3_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3264:6: warning: symbol 'connect_b3_t90_a_res' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:3298:6: warning: symbol 'select_b_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:8692:6: warning: symbol 'sig_req' was not declared. Should it be static?
  drivers/isdn/hardware/eicon/message.c:8792:6: warning: symbol 'send_data' was not declared. Should it be static?

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/isdn/hardware/eicon/message.c |   70 ++++++++++++++++++++++-----------
 1 files changed, 46 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/hardware/eicon/message.c b/drivers/isdn/hardware/eicon/message.c
index 4cc94f2..31f91c1 100644
--- a/drivers/isdn/hardware/eicon/message.c
+++ b/drivers/isdn/hardware/eicon/message.c
@@ -1194,7 +1194,8 @@ static char hex_digit_table[0x10] =
 /* translation function for each message                            */
 /*------------------------------------------------------------------*/
 
-byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ch;
   word i;
@@ -1411,7 +1412,8 @@ byte connect_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return 2;
 }
 
-byte connect_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word i, Info;
   word Reject;
@@ -1567,13 +1569,15 @@ byte connect_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return 1;
 }
 
-byte connect_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte connect_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			  PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   dbug(1,dprintf("connect_a_res"));
   return false;
 }
 
-byte disconnect_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte disconnect_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			   PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   word Info;
   word i;
@@ -1628,7 +1632,8 @@ byte disconnect_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plc
   return false;
 }
 
-byte disconnect_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte disconnect_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			   PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   dbug(1,dprintf("disconnect_res"));
   if(plci)
@@ -1655,7 +1660,8 @@ byte disconnect_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plc
   return 0;
 }
 
-byte listen_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte listen_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+		       PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word Info;
   byte i;
@@ -1704,7 +1710,8 @@ byte listen_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, A
   return false;
 }
 
-byte info_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte info_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+		     PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   word i;
   API_PARSE * ai;
@@ -1813,13 +1820,15 @@ byte info_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APP
   return false;
 }
 
-byte info_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte info_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+		     PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   dbug(1,dprintf("info_res"));
   return false;
 }
 
-byte alert_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte alert_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+		      PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   word Info;
   byte ret;
@@ -1849,7 +1858,8 @@ byte alert_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, AP
   return ret;
 }
 
-byte facility_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte facility_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			 PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   word Info = 0;
   word i    = 0;
@@ -2599,13 +2609,15 @@ byte facility_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return false;
 }
 
-byte facility_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte facility_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			 PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   dbug(1,dprintf("facility_res"));
   return false;
 }
 
-byte connect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			   PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word Info = 0;
   byte req;
@@ -2839,7 +2851,8 @@ byte connect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plc
   return false;
 }
 
-byte connect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			   PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ncci;
   API_PARSE * ncpi;
@@ -2954,7 +2967,8 @@ byte connect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plc
   return false;
 }
 
-byte connect_b3_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_b3_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			     PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ncci;
 
@@ -2974,7 +2988,8 @@ byte connect_b3_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * p
   return false;
 }
 
-byte disconnect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte disconnect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			      PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word Info;
   word ncci;
@@ -3030,7 +3045,8 @@ byte disconnect_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   *
   return false;
 }
 
-byte disconnect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte disconnect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			      PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ncci;
   word i;
@@ -3086,7 +3102,8 @@ byte disconnect_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   *
   return false;
 }
 
-byte data_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte data_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   NCCI   *ncci_ptr;
   DATA_B3_DESC   *data;
@@ -3163,7 +3180,8 @@ byte data_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return false;
 }
 
-byte data_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte data_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word n;
   word ncci;
@@ -3196,7 +3214,8 @@ byte data_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return false;
 }
 
-byte reset_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte reset_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			 PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word Info;
   word ncci;
@@ -3237,7 +3256,8 @@ byte reset_b3_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return false;
 }
 
-byte reset_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte reset_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			 PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ncci;
 
@@ -3261,7 +3281,8 @@ byte reset_b3_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci,
   return false;
 }
 
-byte connect_b3_t90_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * parms)
+static byte connect_b3_t90_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+				 PLCI *plci, APPL *appl, API_PARSE *parms)
 {
   word ncci;
   API_PARSE * ncpi;
@@ -3295,7 +3316,8 @@ byte connect_b3_t90_a_res(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI
 }
 
 
-byte select_b_req(dword Id, word Number, DIVA_CAPI_ADAPTER   * a, PLCI   * plci, APPL   * appl, API_PARSE * msg)
+static byte select_b_req(dword Id, word Number, DIVA_CAPI_ADAPTER *a,
+			 PLCI *plci, APPL *appl, API_PARSE *msg)
 {
   word Info=0;
   word i;
@@ -8689,7 +8711,7 @@ static word add_modem_b23 (PLCI  * plci, API_PARSE* bp_parms)
 /* send a request for the signaling entity                          */
 /*------------------------------------------------------------------*/
 
-void sig_req(PLCI   * plci, byte req, byte Id)
+static void sig_req(PLCI *plci, byte req, byte Id)
 {
   if(!plci) return;
   if(plci->adapter->adapter_disabled) return;
@@ -8789,7 +8811,7 @@ static void send_req(PLCI *plci)
   dbug(1,dprintf("send_ok"));
 }
 
-void send_data(PLCI   * plci)
+static void send_data(PLCI *plci)
 {
   DIVA_CAPI_ADAPTER   * a;
   DATA_B3_DESC   * data;

