From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 7/14] d80211: Fix type of prism2_hostapd_param crypt.alg
Date: Wed, 27 Sep 2006 17:50:52 +0200 (CEST)
Message-ID: <20060927155052.04E803BA24C@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50316 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964968AbWI0Ptr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:47 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Kimdon <david.kimdon@devicescape.com>

crypt.alg is a string, use the correct type.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/hostapd_ioctl.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

2c9c2aa6731a429574a987c26769466a19373359
diff --git a/net/d80211/hostapd_ioctl.h b/net/d80211/hostapd_ioctl.h
index 7c7305c..d302790 100644
--- a/net/d80211/hostapd_ioctl.h
+++ b/net/d80211/hostapd_ioctl.h
@@ -207,7 +207,7 @@ #define IEEE80211_STA_DYNAMIC_ENC BIT(0)
 			u32 last_ack_rssi;
 		} get_info_sta;
 		struct {
-			u8 alg[HOSTAP_CRYPT_ALG_NAME_LEN];
+			char alg[HOSTAP_CRYPT_ALG_NAME_LEN];
 			u32 flags;
 			u32 err;
 			u8 idx;
-- 
1.3.0

