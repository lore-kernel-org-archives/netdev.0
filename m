From: Chen Weilong <chenweilong@huawei.com>
Subject: [patch net-next 2/5] mac80211: fix checkpatch error
Date: Wed, 18 Dec 2013 15:44:13 +0800
Message-ID: <1387352656-860-3-git-send-email-chenweilong@huawei.com>
References: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <linville@tuxdriver.com>,
	<johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [119.145.14.64] ([119.145.14.64]:10599 "EHLO
	szxga01-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab3LRHps (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 02:45:48 -0500
In-Reply-To: <1387352656-860-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weilong Chen <chenweilong@huawei.com>

"(foo*)" should be "(foo *)"

Signed-off-by: Weilong Chen <chenweilong@huawei.com>
---
 net/mac80211/tx.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c558b24..c616830 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -2136,7 +2136,7 @@ netdev_tx_t ieee80211_subif_start_xmit(struct sk_buff *skb,
 	if (ieee80211_is_data_qos(fc)) {
 		__le16 *qos_control;
 
-		qos_control = (__le16*) skb_push(skb, 2);
+		qos_control = (__le16 *) skb_push(skb, 2);
 		memcpy(skb_push(skb, hdrlen - 2), &hdr, hdrlen - 2);
 		/*
 		 * Maybe we could actually set some fields here, for now just
@@ -2298,7 +2298,7 @@ static void __ieee80211_beacon_add_tim(struct ieee80211_sub_if_data *sdata,
 	if (atomic_read(&ps->num_sta_ps) > 0)
 		/* in the hope that this is faster than
 		 * checking byte-for-byte */
-		have_bits = !bitmap_empty((unsigned long*)ps->tim,
+		have_bits = !bitmap_empty((unsigned long *)ps->tim,
 					  IEEE80211_MAX_AID+1);
 
 	if (ps->dtim_count == 0)
-- 
1.7.12
