From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 7/7] netfilter: nfnetlink_queue: use network skb for sequence adjustment
Date: Wed, 18 Sep 2013 00:07:34 +0200
Message-ID: <1379455654-3905-8-git-send-email-pablo@netfilter.org>
References: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34680 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752689Ab3IQWIF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 18:08:05 -0400
In-Reply-To: <1379455654-3905-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

Instead of the netlink skb.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nfnetlink_queue_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nfnetlink_queue_core.c b/net/netfilter/nfnetlink_queue_core.c
index 95a98c8..ae2e5c1 100644
--- a/net/netfilter/nfnetlink_queue_core.c
+++ b/net/netfilter/nfnetlink_queue_core.c
@@ -1009,7 +1009,7 @@ nfqnl_recv_verdict(struct sock *ctnl, struct sk_buff *skb,
 			verdict = NF_DROP;
 
 		if (ct)
-			nfqnl_ct_seq_adjust(skb, ct, ctinfo, diff);
+			nfqnl_ct_seq_adjust(entry->skb, ct, ctinfo, diff);
 	}
 
 	if (nfqa[NFQA_MARK])
-- 
1.7.10.4
