From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 4/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 15:44:15 +0800
Message-ID: <1387352656-860-5-git-send-email-chenweilong@huawei.com>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:20152 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593Ab3LRHqb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:46:31 -0500
In-Reply-To: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

Code indent should use tabs where possible

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac80211/rc80211_minstrel.c | 4 ++--
 net/mac80211/tkip.c             | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/rc80211_minstrel.c b/net/mac80211/rc80211_minstrel.c
index 781a1e2..5fa66be 100644
--- a/net/mac80211/rc80211_minstrel.c
+++ b/net/mac80211/rc80211_minstrel.c
@@ -220,7 +220,7 @@ minstrel_update_stats(struct minstrel_priv *mp, struct minstrel_sta_info *mi)
 
 static void
 minstrel_tx_status(void *priv, struct ieee80211_supported_band *sband,
-                   struct ieee80211_sta *sta, void *priv_sta,
+		   struct ieee80211_sta *sta, void *priv_sta,
 		   struct sk_buff *skb)
 {
 	struct minstrel_priv *mp = priv;
@@ -260,7 +260,7 @@ minstrel_tx_status(void *priv, struct ieee80211_supported_band *sband,
 
 static inline unsigned int
 minstrel_get_retry_count(struct minstrel_rate *mr,
-                         struct ieee80211_tx_info *info)
+			 struct ieee80211_tx_info *info)
 {
 	unsigned int retry = mr->adjusted_retry_count;
 
diff --git a/net/mac80211/tkip.c b/net/mac80211/tkip.c
index 124b1fd..0ae2077 100644
--- a/net/mac80211/tkip.c
+++ b/net/mac80211/tkip.c
@@ -186,7 +186,7 @@ void ieee80211_get_tkip_p1k_iv(struct ieee80211_key_conf *keyconf,
 EXPORT_SYMBOL(ieee80211_get_tkip_p1k_iv);
 
 void ieee80211_get_tkip_rx_p1k(struct ieee80211_key_conf *keyconf,
-                               const u8 *ta, u32 iv32, u16 *p1k)
+			       const u8 *ta, u32 iv32, u16 *p1k)
 {
 	const u8 *tk = &keyconf->key[NL80211_TKIP_DATA_OFFSET_ENCR_KEY];
 	struct tkip_ctx ctx;
-- 
1.7.12
