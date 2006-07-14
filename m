From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] remove unused routines from d80211 version of bcm43xx
Date: Fri, 14 Jul 2006 16:04:26 -0500
Message-ID: <44B806DA.5010809@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:21958 "EHLO
	mtiwmhc11.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1161301AbWGNVEe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 17:04:34 -0400
To: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes some unused static inline routines from bcm43xx-d80211 version of bcm43xx_main.h.

Signed-Off-By: Larry Finger <Larry.Finger@lwfinger.net>

===========================================================

index e228833..04d8b91 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.h
@@ -112,30 +112,6 @@ int bcm43xx_channel_to_freq(struct bcm43
     return bcm43xx_channel_to_freq_bg(channel);
  }

-/* Lightweight function to check if a channel number is valid.
- * Note that this does _NOT_ check for geographical restrictions!
- */
-static inline
-int bcm43xx_is_valid_channel_a(u8 channel)
-{
-    return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
-           && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel_bg(u8 channel)
-{
-    return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
-           && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,
-                  u8 channel)
-{
-    if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
-        return bcm43xx_is_valid_channel_a(channel);
-    return bcm43xx_is_valid_channel_bg(channel);
-}
-
  void bcm43xx_tsf_read(struct bcm43xx_private *bcm, u64 *tsf);
  void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf);


===============================================================
