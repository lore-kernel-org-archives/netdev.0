From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 8/8 V4] rtlwifi: Remove all remaining references to variable 'noise' in rtl_stats struct
Date: Wed, 25 Sep 2013 12:57:49 -0500
Message-ID: <1380131869-19185-9-git-send-email-Larry.Finger@lwfinger.net>
References: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:64790 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992Ab3IYR6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 13:58:17 -0400
In-Reply-To: <1380131869-19185-1-git-send-email-Larry.Finger@lwfinger.net>
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

diff --git a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
index a8871d6..5e628ab 100644
--- a/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
@@ -477,7 +477,6 @@ bool rtl88ee_rx_query_desc(struct ieee80211_hw *hw,
 
 	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
-	/*rx_status->noise = -status->noise; */
 	if (status->packet_report_type == TX_REPORT2) {
 		status->macid_valid_entry[0] =
 			 GET_RX_RPT2_DESC_MACID_VALID_1(pdesc);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 6ad23b4..52abf0a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -420,7 +420,6 @@ bool rtl92ce_rx_query_desc(struct ieee80211_hw *hw,
 
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->recvsignalpower + 10;
-	/*rx_status->noise = -stats->noise; */
 
 	return true;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index c709511..222d2e7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -330,7 +330,6 @@ bool rtl92se_rx_query_desc(struct ieee80211_hw *hw, struct rtl_stats *stats,
 
 	/*rx_status->qual = stats->signal; */
 	rx_status->signal = stats->rssi + 10;
-	/*rx_status->noise = -stats->noise; */
 
 	return true;
 }
diff --git a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
index c72758d..e85ec21 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
@@ -359,7 +359,6 @@ bool rtl8723ae_rx_query_desc(struct ieee80211_hw *hw,
 
 	/*rx_status->qual = status->signal; */
 	rx_status->signal = status->recvsignalpower + 10;
-	/*rx_status->noise = -status->noise; */
 
 	return true;
 }
-- 
1.8.1.4
