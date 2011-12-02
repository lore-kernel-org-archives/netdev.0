From: David Miller <davem@davemloft.net>
Subject: [PATCH] atm: clip: Remove code commented out since eternity.
Date: Fri, 02 Dec 2011 14:27:43 -0500 (EST)
Message-ID: <20111202.142743.1810798623492596256.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab1LBT1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 14:27:47 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB2JRiIN022818
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 2 Dec 2011 11:27:46 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---

Saw this while auditing dst_set_neighbour() call sites.

 net/atm/clip.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index f3b3615..c84ce7f 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -340,15 +340,6 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	}
 	n = dst_get_neighbour(dst);
 	if (!n) {
-#if 0
-		n = clip_find_neighbour(skb_dst(skb), 1);
-		if (!n) {
-			dev_kfree_skb(skb);	/* lost that one */
-			dev->stats.tx_dropped++;
-			return 0;
-		}
-		dst_set_neighbour(dst, n);
-#endif
 		pr_err("NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
-- 
1.7.7.3
