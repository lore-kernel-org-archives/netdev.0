From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] ipv6: data of fwmark_reflect needs to be updated on netns construction
Date: Thu, 31 Jul 2014 14:34:55 +0200
Message-ID: <2a80411c2242306dde7de22d4446717362e082d6.1406809674.git.hannes@stressinduktion.org>
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:36263 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751277AbaGaMfE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2014 08:35:04 -0400
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by gateway1.nyi.internal (Postfix) with ESMTP id DCE4821F22
	for <netdev@vger.kernel.org>; Thu, 31 Jul 2014 08:35:03 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: e110861f86094cd ("net: add a sysctl to reflect the fwmark on replies")
Cc: Lorenzo Colitti <lorenzo@google.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sysctl_net_ipv6.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 5bf7b61..0c56c93 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -82,6 +82,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
 	ipv6_table[2].data = &net->ipv6.sysctl.flowlabel_consistency;
 	ipv6_table[3].data = &net->ipv6.sysctl.auto_flowlabels;
+	ipv6_table[4].data = &net->ipv6.sysctl.fwmark_reflect;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)
-- 
1.9.3
