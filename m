From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: [PATCH] net/core: use htons for skb->protocol
Date: Tue, 29 Jun 2010 18:32:46 +0200
Message-ID: <20100629163246.GA18647@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:43413 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756581Ab0F2Qcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 12:32:47 -0400
Received: id: bigeasy by Chamillionaire.breakpoint.cc with local
	(easymta 1.00 BETA 1)
	id 1OTdjq-0004vQ-FU
	for netdev@vger.kernel.org; Tue, 29 Jun 2010 18:32:46 +0200
Content-Disposition: inline
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
index 2b3bf53..78ad37c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1541,7 +1541,8 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 				if (net_ratelimit())
 					printk(KERN_CRIT "protocol %04x is "
 					       "buggy, dev %s\n",
-					       skb2->protocol, dev->name);
+					       htons(skb2->protocol),
+					       dev->name);
 				skb_reset_network_header(skb2);
 			}
 
-- 
1.7.0.4
