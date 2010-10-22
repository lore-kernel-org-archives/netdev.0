From: Simon Horman <horms@verge.net.au>
Subject: [rfc v2 05/10] ipvs: Add ipvs_skbnet
Date: Fri, 22 Oct 2010 22:09:39 +0200
Message-ID: <20101022202358.801407495@joe.akashicho.tokyo.vergenet.net>
References: <20101022200934.822223308@joe.akashicho.tokyo.vergenet.net>
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	Julian Anastasov <ja@ssi.bg>,
	Daniel Lezcano <daniel.lezcano@free.fr>,
	Wensong Zhang <wensong@linux-vs.org>
To: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:43371 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab0JWB1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 21:27:34 -0400
Content-Disposition: inline; filename=ipvs_skbnet.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As suggested by Julian Anastasov

Cc: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: lvs-test-2.6/include/net/ip_vs.h
===================================================================
--- lvs-test-2.6.orig/include/net/ip_vs.h	2010-10-22 21:16:52.000000000 +0200
+++ lvs-test-2.6/include/net/ip_vs.h	2010-10-22 21:16:56.000000000 +0200
@@ -1097,6 +1097,11 @@ static inline void ip_vs_conn_drop_connt
 /* CONFIG_IP_VS_NFCT */
 #endif
 
+static inline struct net *ipvs_skbnet(struct sk_buff *skb)
+{
+	return dev_net(skb->dev ? : skb_dst(skb)->dev);
+}
+
 #endif /* __KERNEL__ */
 
 #endif	/* _NET_IP_VS_H */

