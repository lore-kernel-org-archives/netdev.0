From: Tobias Klauser <klto@zhaw.ch>
Subject: [PATCH 5/8] mac80211_hwsim: Remove unused DECLARE_MAC_BUF
Date: Thu, 16 Jul 2009 10:57:53 +0200
Message-ID: <1247734673-20955-1-git-send-email-klto@zhaw.ch>
Cc: Tobias Klauser <klto@zhaw.ch>
To: linville@tuxdriver.com, johannes@sipsolutions.net,
	jouni.malinen@atheros.com, lrodriguez@atheros.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.zhaw.ch ([160.85.104.51]:59445 "EHLO mx2.zhaw.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753808AbZGPI5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jul 2009 04:57:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is not needed anymore because of the %pM printk conversion specifier.

Signed-off-by: Tobias Klauser <klto@zhaw.ch>
---
 drivers/net/wireless/mac80211_hwsim.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index a111bda..08cfd4b 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -757,7 +757,6 @@ static void hwsim_send_ps_poll(void *dat, u8 *mac, struct ieee80211_vif *vif)
 {
 	struct mac80211_hwsim_data *data = dat;
 	struct hwsim_vif_priv *vp = (void *)vif->drv_priv;
-	DECLARE_MAC_BUF(buf);
 	struct sk_buff *skb;
 	struct ieee80211_pspoll *pspoll;
 
@@ -787,7 +786,6 @@ static void hwsim_send_nullfunc(struct mac80211_hwsim_data *data, u8 *mac,
 				struct ieee80211_vif *vif, int ps)
 {
 	struct hwsim_vif_priv *vp = (void *)vif->drv_priv;
-	DECLARE_MAC_BUF(buf);
 	struct sk_buff *skb;
 	struct ieee80211_hdr *hdr;
 
-- 
1.6.0.4

