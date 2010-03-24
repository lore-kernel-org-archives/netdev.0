From: Frans Pop <elendil@planet.nl>
Subject: [PATCH 1/7] wireless: remove trailing space in messages
Date: Wed, 24 Mar 2010 19:46:29 +0100
Message-ID: <1269456395-15343-1-git-send-email-elendil@planet.nl>
References: <201003241927.12434.elendil@planet.nl>
Cc: Frans Pop <elendil@planet.nl>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201003241927.12434.elendil@planet.nl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also correct indentation in net/wireless/reg.c.

Signed-off-by: Frans Pop <elendil@planet.nl>
---
 net/mac80211/agg-tx.c |    4 ++--
 net/wireless/reg.c    |    6 +++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/mac80211/agg-tx.c b/net/mac80211/agg-tx.c
index 5538e1b..bb4ac70 100644
--- a/net/mac80211/agg-tx.c
+++ b/net/mac80211/agg-tx.c
@@ -414,7 +414,7 @@ static void ieee80211_agg_tx_operational(struct ieee80211_local *local,
 					 struct sta_info *sta, u16 tid)
 {
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "Aggregation is on for tid %d \n", tid);
+	printk(KERN_DEBUG "Aggregation is on for tid %d\n", tid);
 #endif
 
 	spin_lock(&local->ampdu_lock);
@@ -674,7 +674,7 @@ void ieee80211_process_addba_resp(struct ieee80211_local *local,
 	del_timer(&sta->ampdu_mlme.tid_tx[tid]->addba_resp_timer);
 
 #ifdef CONFIG_MAC80211_HT_DEBUG
-	printk(KERN_DEBUG "switched off addBA timer for tid %d \n", tid);
+	printk(KERN_DEBUG "switched off addBA timer for tid %d\n", tid);
 #endif /* CONFIG_MAC80211_HT_DEBUG */
 
 	if (le16_to_cpu(mgmt->u.action.u.addba_resp.status)
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index ed89c59..e857d72 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -2357,10 +2357,10 @@ static void print_regdomain(const struct ieee80211_regdomain *rd)
 					rdev->country_ie_alpha2[1]);
 			} else
 				printk(KERN_INFO "cfg80211: Current regulatory "
-					"domain intersected: \n");
+					"domain intersected:\n");
 		} else
-				printk(KERN_INFO "cfg80211: Current regulatory "
-					"domain intersected: \n");
+			printk(KERN_INFO "cfg80211: Current regulatory "
+				"domain intersected:\n");
 	} else if (is_world_regdom(rd->alpha2))
 		printk(KERN_INFO "cfg80211: World regulatory "
 			"domain updated:\n");
-- 
1.6.6.1
