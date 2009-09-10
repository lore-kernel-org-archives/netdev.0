From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 12/31: conntrack: switch hook PFs to nfproto
Date: Thu, 10 Sep 2009 18:12:02 +0200 (MEST)
Message-ID: <20090910161157.31179.16007.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64661 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752414AbZIJQL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:11:59 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 57750a22ed022ed6fcdcc5bc58d16011ccfe575f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 06:22:18 2009 +0200

    netfilter: conntrack: switch hook PFs to nfproto
    
    Simple substitution to indicate that the fields indeed use the
    NFPROTO_ space.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 7d2ead7..8905cc7 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -158,28 +158,28 @@ static struct nf_hook_ops ipv4_conntrack_ops[] __read_mostly = {
 	{
 		.hook		= ipv4_conntrack_in,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv4_conntrack_local,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
 	{
 		.hook		= ipv4_confirm,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET,
+		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_CONNTRACK_CONFIRM,
 	},
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 2a15c2d..a7f4cd6 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -265,42 +265,42 @@ static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
 	{
 		.hook		= ipv6_defrag,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv6_conntrack_in,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_conntrack_local,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK,
 	},
 	{
 		.hook		= ipv6_defrag,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_CONNTRACK_DEFRAG,
 	},
 	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
 		.priority	= NF_IP6_PRI_LAST,
 	},
 	{
 		.hook		= ipv6_confirm,
 		.owner		= THIS_MODULE,
-		.pf		= PF_INET6,
+		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_LAST-1,
 	},
