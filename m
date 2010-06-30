From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH v2] net/core: use ntohs for skb->protocol
Date: Wed, 30 Jun 2010 11:02:29 +0200
Message-ID: <20100630090229.GB25541@Chamillionaire.breakpoint.cc>
References: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
 <20100629.151740.135534374.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:50309 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752079Ab0F3JCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jun 2010 05:02:30 -0400
Content-Disposition: inline
In-Reply-To: <20100629.151740.135534374.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>

This is only noticed by people that are not doing everything correct in
the first place.

Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/core/dev.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index eb4be99..8e61dc5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1537,7 +1537,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 				if (net_ratelimit())
 					printk(KERN_CRIT "protocol %04x is "
 					       "buggy, dev %s\n",
-					       skb2->protocol, dev->name);
+					       ntohs(skb2->protocol),
+					       dev->name);
 				skb_reset_network_header(skb2);
 			}
 
-- 
1.6.6.1

