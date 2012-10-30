From: Ashwini Singh <asingh.engi@gmail.com>
Subject: [PATCH] Linus's tree: wireless: Spelling corrections
Date: Tue, 30 Oct 2012 17:18:21 +0530
Message-ID: <1351597701-18216-1-git-send-email-asingh.engi@gmail.com>
Cc: linville@tuxdriver.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Ashwini Singh <asingh.engi@gmail.com>
To: johannes@sipsolutions.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Few spelling corrections in wireless directory.

Signed-off-by: Ashwini Singh <asingh.engi@gmail.com>
---
 net/wireless/radiotap.c    |    2 +-
 net/wireless/reg.c         |    6 +++---
 net/wireless/wext-compat.c |    2 +-
 net/wireless/wext-core.c   |    2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/wireless/radiotap.c b/net/wireless/radiotap.c
index 7d604c0..eaf4282 100644
--- a/net/wireless/radiotap.c
+++ b/net/wireless/radiotap.c
@@ -190,7 +190,7 @@ static void find_ns(struct ieee80211_radiotap_iterator *iterator,
  * present fields.  @this_arg can be changed by the caller (eg,
  * incremented to move inside a compound argument like
  * IEEE80211_RADIOTAP_CHANNEL).  The args pointed to are in
- * little-endian format whatever the endianess of your CPU.
+ * little-endian format whatever the endianness of your CPU.
  *
  * Alignment Gotcha:
  * You must take care when dereferencing iterator.this_arg
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 3b8cbbc..b98ff98 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -718,7 +718,7 @@ static int freq_reg_info_regd(struct wiphy *wiphy,
 
 	/*
 	 * Follow the driver's regulatory domain, if present, unless a country
-	 * IE has been processed or a user wants to help complaince further
+	 * IE has been processed or a user wants to help compliance further
 	 */
 	if (!custom_regd &&
 	    last_request->initiator != NL80211_REGDOM_SET_BY_COUNTRY_IE &&
@@ -2133,7 +2133,7 @@ bool reg_supported_dfs_region(u8 dfs_region)
 	case NL80211_DFS_JP:
 		return true;
 	default:
-		REG_DBG_PRINT("Ignoring uknown DFS master region: %d\n",
+		REG_DBG_PRINT("Ignoring unknown DFS master region: %d\n",
 			      dfs_region);
 		return false;
 	}
@@ -2155,7 +2155,7 @@ static void print_dfs_region(u8 dfs_region)
 		pr_info(" DFS Master region JP");
 		break;
 	default:
-		pr_info(" DFS Master region Uknown");
+		pr_info(" DFS Master region Unknown");
 		break;
 	}
 }
diff --git a/net/wireless/wext-compat.c b/net/wireless/wext-compat.c
index 494379e..7642f60 100644
--- a/net/wireless/wext-compat.c
+++ b/net/wireless/wext-compat.c
@@ -1144,7 +1144,7 @@ static int cfg80211_wext_siwpower(struct net_device *dev,
 		switch (wrq->flags & IW_POWER_MODE) {
 		case IW_POWER_ON:       /* If not specified */
 		case IW_POWER_MODE:     /* If set all mask */
-		case IW_POWER_ALL_R:    /* If explicitely state all */
+		case IW_POWER_ALL_R:    /* If explicitly state all */
 			ps = true;
 			break;
 		default:                /* Otherwise we ignore */
diff --git a/net/wireless/wext-core.c b/net/wireless/wext-core.c
index c8717c1..c9514ce 100644
--- a/net/wireless/wext-core.c
+++ b/net/wireless/wext-core.c
@@ -849,7 +849,7 @@ out:
  *
  * Note : our current commit strategy is currently pretty dumb,
  * but we will be able to improve on that...
- * The goal is to try to agreagate as many changes as possible
+ * The goal is to try to aggregate as many changes as possible
  * before doing the commit. Drivers that will define a commit handler
  * are usually those that need a reset after changing parameters, so
  * we want to minimise the number of reset.
-- 
1.7.0.1
