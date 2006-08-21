From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 5/7] ieee80211: export symbol ieee80211_api_version
Date: Mon, 21 Aug 2006 11:33:40 +0800
Message-ID: <20060821033340.GA4802@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45139 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932549AbWHUDff (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:35:35 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export this symbol so that wireless drivers can check the running IEEE80211
API version dynamically.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/ieee80211.h          |    2 ++
 net/ieee80211/ieee80211_module.c |    3 +++
 2 files changed, 5 insertions(+), 0 deletions(-)

81634e488965fae232027e14a54c998ccb5b0c49
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 83e06aa..ee66681 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -1255,6 +1255,8 @@ static inline int ieee80211_is_cck_rate(
 	return 0;
 }
 
+extern const int ieee80211_api_version;
+
 /* ieee80211.c */
 extern void free_ieee80211(struct net_device *dev);
 extern struct net_device *alloc_ieee80211(int sizeof_priv);
diff --git a/net/ieee80211/ieee80211_module.c b/net/ieee80211/ieee80211_module.c
index 13b1e5f..02e730b 100644
--- a/net/ieee80211/ieee80211_module.c
+++ b/net/ieee80211/ieee80211_module.c
@@ -61,6 +61,9 @@ MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 
+const int ieee80211_api_version = IEEE80211_VERSION_API;
+EXPORT_SYMBOL(ieee80211_api_version);
+
 static int ieee80211_networks_allocate(struct ieee80211_device *ieee)
 {
 	if (ieee->networks)
-- 
1.2.6
