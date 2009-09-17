From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Subject: [PATCH 1/2 v2] wl12xx: switch to %pM to print the mac address
Date: Thu, 17 Sep 2009 08:15:36 +0200
Message-ID: <1253168136-4586-1-git-send-email-plagnioj@jcrosoft.com>
References: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Cc: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 30.mail-out.ovh.net ([213.186.62.213]:46193 "HELO
	30.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754129AbZIQGRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 02:17:03 -0400
In-Reply-To: <1253146059-4169-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
---
 drivers/net/wireless/wl12xx/wl1271_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

v2:
Fix correctly
diff --git a/drivers/net/wireless/wl12xx/wl1271_main.c b/drivers/net/wireless/wl12xx/wl1271_main.c
index d9169b4..27298b1 100644
--- a/drivers/net/wireless/wl12xx/wl1271_main.c
+++ b/drivers/net/wireless/wl12xx/wl1271_main.c
@@ -644,11 +644,10 @@ static int wl1271_op_config_interface(struct ieee80211_hw *hw,
 {
 	struct wl1271 *wl = hw->priv;
 	struct sk_buff *beacon;
-	DECLARE_MAC_BUF(mac);
 	int ret;
 
-	wl1271_debug(DEBUG_MAC80211, "mac80211 config_interface bssid %s",
-		     print_mac(mac, conf->bssid));
+	wl1271_debug(DEBUG_MAC80211, "mac80211 config_interface bssid %pM",
+		     conf->bssid);
 	wl1271_dump_ascii(DEBUG_MAC80211, "ssid: ", conf->ssid,
 			  conf->ssid_len);
 
-- 
1.6.4

