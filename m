From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 3/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 15:44:14 +0800
Message-ID: <1387352656-860-4-git-send-email-chenweilong@huawei.com>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14073 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158Ab3LRHsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:48:21 -0500
In-Reply-To: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Space required.

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac80211/rc80211_minstrel.c | 4 ++--
 net/mac80211/trace.h            | 2 +-
 net/mac80211/util.c             | 2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 7fa1b36..781a1e2 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -135,7 +135,7 @@ minstrel_update_stats(struct minstrel_priv *mp, struct minstrel_sta_info *mi)
 	u32 usecs;
 	int i;
 
-	for (i=0; i < MAX_THR_RATES; i++)
+	for (i = 0; i < MAX_THR_RATES; i++)
 	    tmp_tp_rate[i] = 0;
 
 	for (i = 0; i < mi->n_rates; i++) {
@@ -190,7 +190,7 @@ minstrel_update_stats(struct minstrel_priv *mp, struct minstrel_sta_info *mi)
 		 * choose the maximum throughput rate as max_prob_rate
 		 * (2) if all success probabilities < 95%, the rate with
 		 * highest success probability is choosen as max_prob_rate */
-		if (mr->probability >= MINSTREL_FRAC(95,100)) {
+		if (mr->probability >= MINSTREL_FRAC(95, 100)) {
 			if (mr->cur_tp >= mi->r[tmp_prob_rate].cur_tp)
 				tmp_prob_rate = i;
 		} else {
diff --git a/net/mac80211/trace.h b/net/mac80211/trace.h
index d4cee98..bec7371 100644
--- a/net/mac80211/trace.h
+++ b/net/mac80211/trace.h
@@ -560,7 +560,7 @@ TRACE_EVENT(drv_update_tkip_key,
 
 	TP_printk(
 		LOCAL_PR_FMT VIF_PR_FMT STA_PR_FMT " iv32:%#x",
-		LOCAL_PR_ARG,VIF_PR_ARG,STA_PR_ARG, __entry->iv32
+		LOCAL_PR_ARG, VIF_PR_ARG, STA_PR_ARG, __entry->iv32
 	)
 );
 
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 9f9b9bd..0ec4d51 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -76,7 +76,7 @@ u8 *ieee80211_get_bssid(struct ieee80211_hdr *hdr, size_t len,
 	}
 
 	if (ieee80211_is_ctl(fc)) {
-		if(ieee80211_is_pspoll(fc))
+		if (ieee80211_is_pspoll(fc))
 			return hdr->addr1;
 
 		if (ieee80211_is_back_req(fc)) {
-- 
1.7.12
