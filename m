From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 2/8] udp: ipv6 style cleanup
Date: Thu, 08 Mar 2007 12:52:16 -0800
Message-ID: <20070308205305.679324956@linux-foundation.org>
References: <20070308205214.580772044@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35782 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933326AbXCHUyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 15:54:40 -0500
Content-Disposition: inline; filename=udp-2
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix whitespace around keywords. Eliminate unnecessary ()'s on return
statements.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/ipv6/udp.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- net-2.6.22.orig/net/ipv6/udp.c	2007-03-07 10:18:04.000000000 -0800
+++ net-2.6.22/net/ipv6/udp.c	2007-03-07 10:27:56.000000000 -0800
@@ -93,10 +93,10 @@
 					continue;
 				score++;
 			}
-			if(score == 4) {
+			if (score == 4) {
 				result = sk;
 				break;
-			} else if(score > badness) {
+			} else if (score > badness) {
 				result = sk;
 				badness = score;
 			}
@@ -329,7 +329,7 @@
 				if (!ipv6_addr_equal(&np->rcv_saddr, loc_addr))
 					continue;
 			}
-			if(!inet6_mc_check(s, loc_addr, rmt_addr))
+			if (!inet6_mc_check(s, loc_addr, rmt_addr))
 				continue;
 			return s;
 		}
@@ -473,14 +473,14 @@
 		icmpv6_send(skb, ICMPV6_DEST_UNREACH, ICMPV6_PORT_UNREACH, 0, dev);
 
 		kfree_skb(skb);
-		return(0);
+		return 0;
 	}
 
 	/* deliver */
 
 	udpv6_queue_rcv_skb(sk, skb);
 	sock_put(sk);
-	return(0);
+	return 0;
 
 short_packet:
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%sv6: short packet: %d/%u\n",
@@ -490,7 +490,7 @@
 discard:
 	UDP6_INC_STATS_BH(UDP_MIB_INERRORS, proto == IPPROTO_UDPLITE);
 	kfree_skb(skb);
-	return(0);
+	return 0;
 }
 
 static __inline__ int udpv6_rcv(struct sk_buff **pskb)

--
Stephen Hemminger <shemminger@linux-foundation.org>

