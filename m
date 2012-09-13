From: pablo@netfilter.org
Subject: [PATCH 3/5] netfilter: nfnetlink_queue: remove pointless conditional before kfree_skb()
Date: Thu, 13 Sep 2012 13:01:30 +0200
Message-ID: <1347534092-3579-4-git-send-email-pablo@netfilter.org>
References: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46325 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757548Ab2IMLDC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Sep 2012 07:03:02 -0400
In-Reply-To: <1347534092-3579-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index c0496a5..5c2d78d 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -406,8 +406,7 @@ nfqnl_build_packet_message(struct nfqnl_instance *queue,
 	return skb;
 
 nla_put_failure:
-	if (skb)
-		kfree_skb(skb);
+	kfree_skb(skb);
 	net_err_ratelimited("nf_queue: error creating packet message\n");
 	return NULL;
 }
-- 
1.7.10.4
