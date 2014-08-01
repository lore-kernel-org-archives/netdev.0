From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ipv6: data of fwmark_reflect sysctl needs to be updated on netns construction
Date: Fri,  1 Aug 2014 14:41:10 +0200
Message-ID: <8775e97335210450f3ed5a16e64e4d03df026713.1406896673.git.hannes@stressinduktion.org>
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59578 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755189AbaHAMlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 08:41:18 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway1.nyi.internal (Postfix) with ESMTP id 9754F2297B
	for <netdev@vger.kernel.org>; Fri,  1 Aug 2014 08:41:16 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: e110861f86094cd ("net: add a sysctl to reflect the fwmark on replies")
Cc: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Sorry, missed the correct patch on the earlier submission. This knob
needs to be renumbered to '4' when merged with net-next.

 net/ipv6/sysctl_net_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 058f3ec..8183346 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -74,6 +74,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
 	ipv6_table[2].data = &net->ipv6.sysctl.flowlabel_consistency;
+	ipv6_table[3].data = &net->ipv6.sysctl.fwmark_reflect;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.9.3
