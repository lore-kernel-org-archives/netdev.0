From: Joe Perches <joe@perches.com>
Subject: [PATCH] cfg80211: Update REG_DBG_PRINT macro and uses
Date: Fri, 29 Jul 2011 14:51:25 -0700
Message-ID: <01300ba58766070ab14137b8ba8a29fa78695a5c.1311976033.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Several uses were missing terminating newlines.
Typo fix and macro neatening.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wireless/reg.c |   16 +++++++---------
 1 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 1ad0f39..b22c324 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -49,10 +49,8 @@
 #include "nl80211.h"
 
 #ifdef CONFIG_CFG80211_REG_DEBUG
-#define REG_DBG_PRINT(format, args...) \
-	do { \
-		printk(KERN_DEBUG pr_fmt(format), ##args);	\
-	} while (0)
+#define REG_DBG_PRINT(format, args...)			\
+	printk(KERN_DEBUG pr_fmt(format), ##args)
 #else
 #define REG_DBG_PRINT(args...)
 #endif
@@ -890,7 +888,7 @@ static bool ignore_reg_update(struct wiphy *wiphy,
 	    wiphy->flags & WIPHY_FLAG_CUSTOM_REGULATORY) {
 		REG_DBG_PRINT("Ignoring regulatory request %s "
 			      "since the driver uses its own custom "
-			      "regulatory domain ",
+			      "regulatory domain\n",
 			      reg_initiator_name(initiator));
 		return true;
 	}
@@ -903,8 +901,8 @@ static bool ignore_reg_update(struct wiphy *wiphy,
 	    initiator != NL80211_REGDOM_SET_BY_COUNTRY_IE &&
 	    !is_world_regdom(last_request->alpha2)) {
 		REG_DBG_PRINT("Ignoring regulatory request %s "
-			      "since the driver requires its own regulaotry "
-			      "domain to be set first",
+			      "since the driver requires its own regulatory "
+			      "domain to be set first\n",
 			      reg_initiator_name(initiator));
 		return true;
 	}
@@ -1473,7 +1471,7 @@ static void reg_process_pending_hints(void)
 	/* When last_request->processed becomes true this will be rescheduled */
 	if (last_request && !last_request->processed) {
 		REG_DBG_PRINT("Pending regulatory request, waiting "
-			      "for it to be processed...");
+			      "for it to be processed...\n");
 		goto out;
 	}
 
@@ -2186,7 +2184,7 @@ out:
 static void reg_timeout_work(struct work_struct *work)
 {
 	REG_DBG_PRINT("Timeout while waiting for CRDA to reply, "
-		      "restoring regulatory settings");
+		      "restoring regulatory settings\n");
 	restore_regulatory_settings(true);
 }
 
-- 
1.7.6.131.g99019
