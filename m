From: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Subject: [PATCH] openvswitch: conntrack: mark expected switch fall-through
Date: Thu, 19 Oct 2017 12:55:03 -0500
Message-ID: <20171019175503.GA28691@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <garsilva@embeddedor.com>
To: Pravin Shelar <pshelar@nicira.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway24.websitewelcome.com ([192.185.50.93]:41973 "EHLO
        gateway24.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751969AbdJSRzE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 13:55:04 -0400
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
        by gateway24.websitewelcome.com (Postfix) with ESMTP id A137B2D0D9E
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 12:55:04 -0500 (CDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Notice that in this particular case I placed a "fall through" comment on
its own line, which is what GCC is expecting to find.

Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
---
 net/openvswitch/conntrack.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index fe861e2..b27c5c6 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -752,6 +752,7 @@ static int ovs_ct_nat_execute(struct sk_buff *skb, struct nf_conn *ct,
 			}
 		}
 		/* Non-ICMP, fall thru to initialize if needed. */
+		/* fall through */
 	case IP_CT_NEW:
 		/* Seen it before?  This can happen for loopback, retrans,
 		 * or local packets.
-- 
2.7.4
