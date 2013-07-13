From: Daniel Baluta <dbaluta@ixiacom.com>
Subject: [PATCH] ndisc: bool initializations should use true and false
Date: Sat, 13 Jul 2013 11:26:51 +0300
Message-ID: <1373704011-2146-1-git-send-email-dbaluta@ixiacom.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Daniel Baluta <dbaluta@ixiacom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:43641 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757848Ab3GMI0n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 04:26:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Daniel Baluta <dbaluta@ixiacom.com>
---
 net/ipv6/ndisc.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index b3b5730..24c03396 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -479,7 +479,7 @@ static void ndisc_send_na(struct net_device *dev, struct neighbour *neigh,
 	if (ifp) {
 		src_addr = solicited_addr;
 		if (ifp->flags & IFA_F_OPTIMISTIC)
-			override = 0;
+			override = false;
 		inc_opt |= ifp->idev->cnf.force_tllao;
 		in6_ifa_put(ifp);
 	} else {
@@ -557,7 +557,7 @@ void ndisc_send_ns(struct net_device *dev, struct neighbour *neigh,
 	}
 
 	if (ipv6_addr_any(saddr))
-		inc_opt = 0;
+		inc_opt = false;
 	if (inc_opt)
 		optlen += ndisc_opt_addr_space(dev);
 
@@ -790,7 +790,7 @@ static void ndisc_recv_ns(struct sk_buff *skb)
 		     (is_router = pndisc_is_router(&msg->target, dev)) >= 0)) {
 			if (!(NEIGH_CB(skb)->flags & LOCALLY_ENQUEUED) &&
 			    skb->pkt_type != PACKET_HOST &&
-			    inc != 0 &&
+			    inc &&
 			    idev->nd_parms->proxy_delay != 0) {
 				/*
 				 * for anycast or proxy,
-- 
1.7.10.4
