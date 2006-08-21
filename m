From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 4/7] ieee80211: Add IEEE80211_API_VERSION macro
Date: Mon, 21 Aug 2006 11:33:22 +0800
Message-ID: <20060821033322.GA4793@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:25968 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932550AbWHUDfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:35:17 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add IEEE80211_API_VERSION macro so that drivers are able to check it
during compile time. This feature is useful to make backward IEEE80211
compatibilities for wireless drivers.

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 include/net/ieee80211.h |   12 +++++++++++-
 1 files changed, 11 insertions(+), 1 deletions(-)

29be0803256136011dd5c3b62e3eb9f782e57dbd
diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index b174ebb..83e06aa 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -29,7 +29,17 @@
 #include <linux/kernel.h>	/* ARRAY_SIZE */
 #include <linux/wireless.h>
 
-#define IEEE80211_VERSION "git-1.1.13"
+#define IEEE80211_VERSION_MAJOR 1
+#define IEEE80211_VERSION_API 2
+#define IEEE80211_VERSION_MINOR 15
+#define IEEE80211_VERSION_CODE IEEE80211_VERSION_MAJOR * 65536 + \
+			       IEEE80211_VERSION_API * 256 + \
+			       IEEE80211_VERSION_MINOR
+#define _STRX(x) #x
+#define _VERSION_STR(a,b,c) _STRX(a) "." _STRX(b) "." _STRX(c)
+#define IEEE80211_VERSION _VERSION_STR(IEEE80211_VERSION_MAJOR,\
+				       IEEE80211_VERSION_API, \
+				       IEEE80211_VERSION_MINOR)
 
 #define IEEE80211_DATA_LEN		2304
 /* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
-- 
1.2.6
