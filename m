From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] include/net/ieee80211.h: "extern inline" -> "static inline"
Date: Mon, 22 Aug 2005 22:46:15 +0200
Message-ID: <20050822204615.GJ9927@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hostap@shmoo.com, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751193AbVHVUqZ@vger.kernel.org>
To: jkmaline@cc.hut.fi
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"extern inline" doesn't make much sense.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/net/ieee80211.h |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

--- linux-2.6.13-rc6-mm1-full/include/net/ieee80211.h.old	2005-08-22 02:48:16.000000000 +0200
+++ linux-2.6.13-rc6-mm1-full/include/net/ieee80211.h	2005-08-22 02:48:28.000000000 +0200
@@ -710,12 +710,12 @@
 #define IEEE_G            (1<<2)
 #define IEEE_MODE_MASK    (IEEE_A|IEEE_B|IEEE_G)
 
-extern inline void *ieee80211_priv(struct net_device *dev)
+static inline void *ieee80211_priv(struct net_device *dev)
 {
 	return ((struct ieee80211_device *)netdev_priv(dev))->priv;
 }
 
-extern inline int ieee80211_is_empty_essid(const char *essid, int essid_len)
+static inline int ieee80211_is_empty_essid(const char *essid, int essid_len)
 {
 	/* Single white space is for Linksys APs */
 	if (essid_len == 1 && essid[0] == ' ')
@@ -731,7 +731,7 @@
 	return 1;
 }
 
-extern inline int ieee80211_is_valid_mode(struct ieee80211_device *ieee, int mode)
+static inline int ieee80211_is_valid_mode(struct ieee80211_device *ieee, int mode)
 {
 	/*
 	 * It is possible for both access points and our device to support
@@ -757,7 +757,7 @@
 	return 0;
 }
 
-extern inline int ieee80211_get_hdrlen(u16 fc)
+static inline int ieee80211_get_hdrlen(u16 fc)
 {
 	int hdrlen = IEEE80211_3ADDR_LEN;
 
@@ -817,12 +817,12 @@
 				   union iwreq_data *wrqu, char *key);
 
 
-extern inline void ieee80211_increment_scans(struct ieee80211_device *ieee)
+static inline void ieee80211_increment_scans(struct ieee80211_device *ieee)
 {
 	ieee->scans++;
 }
 
-extern inline int ieee80211_get_scans(struct ieee80211_device *ieee)
+static inline int ieee80211_get_scans(struct ieee80211_device *ieee)
 {
 	return ieee->scans;
 }
