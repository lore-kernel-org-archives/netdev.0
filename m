From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/31: xtables: use NFPROTO_ in standard targets
Date: Wed, 10 Jun 2009 21:46:26 +0200 (MEST)
Message-ID: <20090610194624.11112.34736.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33143 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759658AbZFJTqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jun 2009 15:46:25 -0400
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 4ba351cf866257de3da3fbc8d2bcc3907ee9460f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Apr 14 14:28:48 2009 +0200

    netfilter: xtables: use NFPROTO_ in standard targets
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 3051dda..5abc276 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2158,7 +2158,7 @@ static bool icmp_checkentry(const struct xt_mtchk_param *par)
 static struct xt_target ipt_standard_target __read_mostly = {
 	.name		= IPT_STANDARD_TARGET,
 	.targetsize	= sizeof(int),
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 #ifdef CONFIG_COMPAT
 	.compatsize	= sizeof(compat_int_t),
 	.compat_from_user = compat_standard_from_user,
@@ -2170,7 +2170,7 @@ static struct xt_target ipt_error_target __read_mostly = {
 	.name		= IPT_ERROR_TARGET,
 	.target		= ipt_error,
 	.targetsize	= IPT_FUNCTION_MAXNAMELEN,
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 };
 
 static struct nf_sockopt_ops ipt_sockopts = {
@@ -2196,7 +2196,7 @@ static struct xt_match icmp_matchstruct __read_mostly = {
 	.matchsize	= sizeof(struct ipt_icmp),
 	.checkentry	= icmp_checkentry,
 	.proto		= IPPROTO_ICMP,
-	.family		= AF_INET,
+	.family		= NFPROTO_IPV4,
 };
 
 static int __net_init ip_tables_net_init(struct net *net)
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 41fbc1e..37a850e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2191,7 +2191,7 @@ static bool icmp6_checkentry(const struct xt_mtchk_param *par)
 static struct xt_target ip6t_standard_target __read_mostly = {
 	.name		= IP6T_STANDARD_TARGET,
 	.targetsize	= sizeof(int),
-	.family		= AF_INET6,
+	.family		= NFPROTO_IPV6,
 #ifdef CONFIG_COMPAT
 	.compatsize	= sizeof(compat_int_t),
 	.compat_from_user = compat_standard_from_user,
@@ -2203,7 +2203,7 @@ static struct xt_target ip6t_error_target __read_mostly = {
 	.name		= IP6T_ERROR_TARGET,
 	.target		= ip6t_error,
 	.targetsize	= IP6T_FUNCTION_MAXNAMELEN,
-	.family		= AF_INET6,
+	.family		= NFPROTO_IPV6,
 };
 
 static struct nf_sockopt_ops ip6t_sockopts = {
@@ -2229,7 +2229,7 @@ static struct xt_match icmp6_matchstruct __read_mostly = {
 	.matchsize	= sizeof(struct ip6t_icmp),
 	.checkentry	= icmp6_checkentry,
 	.proto		= IPPROTO_ICMPV6,
-	.family		= AF_INET6,
+	.family		= NFPROTO_IPV6,
 };
 
 static int __net_init ip6_tables_net_init(struct net *net)
