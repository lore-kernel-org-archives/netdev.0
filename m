From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 01/31: xtables: use NFPROTO_ for xt_proto_init callsites
Date: Wed, 10 Jun 2009 21:46:24 +0200 (MEST)
Message-ID: <20090610194622.11112.85970.sendpatchset@x2.localnet>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194621.11112.72922.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 383ca5b874fad082a61af0f47610a1af83e6bb44
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Apr 14 14:24:21 2009 +0200

    netfilter: xtables: use NFPROTO_ for xt_proto_init callsites
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 2ec8d72..3051dda 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2201,12 +2201,12 @@ static struct xt_match icmp_matchstruct __read_mostly = {
 
 static int __net_init ip_tables_net_init(struct net *net)
 {
-	return xt_proto_init(net, AF_INET);
+	return xt_proto_init(net, NFPROTO_IPV4);
 }
 
 static void __net_exit ip_tables_net_exit(struct net *net)
 {
-	xt_proto_fini(net, AF_INET);
+	xt_proto_fini(net, NFPROTO_IPV4);
 }
 
 static struct pernet_operations ip_tables_net_ops = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 219e165..41fbc1e 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2234,12 +2234,12 @@ static struct xt_match icmp6_matchstruct __read_mostly = {
 
 static int __net_init ip6_tables_net_init(struct net *net)
 {
-	return xt_proto_init(net, AF_INET6);
+	return xt_proto_init(net, NFPROTO_IPV6);
 }
 
 static void __net_exit ip6_tables_net_exit(struct net *net)
 {
-	xt_proto_fini(net, AF_INET6);
+	xt_proto_fini(net, NFPROTO_IPV6);
 }
 
 static struct pernet_operations ip6_tables_net_ops = {
