From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 8/8] wl12xx: Use %pM conversion specifier
Date: Thu, 16 Jul 2009 11:01:15 +0200
Message-ID: <1247734875-21447-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: linville@tuxdriver.com, kalle.valo@nokia.com, me@bobcopeland.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:60281 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754388AbZGPJBP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 05:01:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the %pM conversion specifier for printk instead of print_mac.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/wl12xx/main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/main.c b/drivers/net/wireless/wl12xx/main.c
index 603d611..5962c4f 100644
--- a/drivers/net/wireless/wl12xx/main.c
+++ b/drivers/net/wireless/wl12xx/main.c
@@ -423,11 +423,10 @@ static int wl12xx_op_add_interface(struct ieee80211_hw *hw,
 				   struct ieee80211_if_init_conf *conf)
 {
 	struct wl12xx *wl = hw->priv;
-	DECLARE_MAC_BUF(mac);
 	int ret = 0;
 
-	wl12xx_debug(DEBUG_MAC80211, "mac80211 add interface type %d mac %s",
-		     conf->type, print_mac(mac, conf->mac_addr));
+	wl12xx_debug(DEBUG_MAC80211, "mac80211 add interface type %d mac %pM",
+		     conf->type, conf->mac_addr);
 
 	mutex_lock(&wl->mutex);
 
-- 
1.6.0.4

