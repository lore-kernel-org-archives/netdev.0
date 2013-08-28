From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] ipv6: Remove redundant sk variable
Date: Wed, 28 Aug 2013 12:05:38 +0200
Message-ID: <71fe125646ec6160be05138696d312c050e8b813.1377684285.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:58832 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752423Ab3H1KFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 06:05:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A sk variable initialized to ndisc_sk is already available outside
of the branch.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/ndisc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 04d31c2..0f915b5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -428,7 +428,6 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	type = icmp6h->icmp6_type;
 
 	if (!dst) {
-		struct sock *sk = net->ipv6.ndisc_sk;
 		struct flowi6 fl6;
 
 		icmpv6_flow_init(sk, &fl6, type, saddr, daddr, skb->dev->ifindex);
-- 
1.8.3.1
