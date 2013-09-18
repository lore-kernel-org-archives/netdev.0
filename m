From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 8/8 V3] rtlwifi: Remove all remaining references to variable 'noise' in rtl_stats struct
Date: Wed, 18 Sep 2013 14:58:59 -0500
Message-ID: <1379534339-14895-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f179.google.com ([209.85.220.179]:58140 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496Ab3IRT7i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 15:59:38 -0400
In-Reply-To: <1379534339-14895-5-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This completes removal of all places that reference variable 'noise'
in the rtl_stats struct. The definition of the struct is unchanged.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c | 1 -
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c | 1 -
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c | 1 -
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c | 1 -
 4 files changed, 4 deletions(-)

Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -477,7 +477,6 @@ bool rtl88ee_rx_query_desc(struct ieee80
 
 	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
-	/*rx_status->noise = -status->noise; */
 	if (status->packet_report_type == TX_REPORT2) {
 		status->macid_valid_entry[0] =
 			 GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -420,7 +420,6 @@ bool rtl92ce_rx_query_desc(struct ieee80
 
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->recvsignalpower + 10;
-	/*rx_status->noise = -stats->noise; */
 
 	return true;
 }
Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -330,7 +330,6 @@ bool rtl92se_rx_query_desc(struct ieee80
 
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->rssi + 10;
-	/*rx_status->noise = -stats->noise; */
 
 	return true;
 }
Index: wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
===================================================================
--- wireless-testing-save.orig/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ wireless-testing-save/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -359,7 +359,6 @@ bool rtl8723ae_rx_query_desc(struct ieee
 
 	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
-	/*rx_status->noise = -status->noise; */
 
 	return true;
 }
