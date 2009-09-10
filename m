From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 14/31: xtables: switch table AFs to nfproto
Date: Thu, 10 Sep 2009 18:12:05 +0200 (MEST)
Message-ID: <20090910161200.31179.47856.sendpatchset@x2.localnet>
References: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64668 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752442AbZIJQMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 12:12:02 -0400
In-Reply-To: <20090910161142.31179.5256.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit f88e6a8a50a603f8347343e75d035889784a507c
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 06:25:44 2009 +0200

    netfilter: xtables: switch table AFs to nfproto
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index bef326c..97dbd94 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -57,7 +57,7 @@ static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET,
+	.af		= NFPROTO_IPV4,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index 1442df7..28647f1 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -68,7 +68,7 @@ static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET,
+	.af		= NFPROTO_IPV4,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 1d28df8..494784c 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -40,7 +40,7 @@ static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks =  RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
-	.af = AF_INET,
+	.af = NFPROTO_IPV4,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 8c5a250..8804e1a 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -61,7 +61,7 @@ static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET,
+	.af		= NFPROTO_IPV4,
 };
 
 static unsigned int
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 6348a79..6448a9b 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -62,7 +62,7 @@ static struct xt_table nat_table = {
 	.name		= "nat",
 	.valid_hooks	= NAT_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET,
+	.af		= NFPROTO_IPV4,
 };
 
 /* Source NAT */
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index b35c358..0a3ae48 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -55,7 +55,7 @@ static struct xt_table packet_filter = {
 	.name		= "filter",
 	.valid_hooks	= FILTER_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET6,
+	.af		= NFPROTO_IPV6,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index a98ced1..0f49e00 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -61,7 +61,7 @@ static struct xt_table packet_mangler = {
 	.name		= "mangle",
 	.valid_hooks	= MANGLE_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET6,
+	.af		= NFPROTO_IPV6,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index ec12540..679865e 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -39,7 +39,7 @@ static struct xt_table packet_raw = {
 	.name = "raw",
 	.valid_hooks = RAW_VALID_HOOKS,
 	.me = THIS_MODULE,
-	.af = AF_INET6,
+	.af = NFPROTO_IPV6,
 };
 
 /* The work comes in here from netfilter.c. */
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index d808507..822afab 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -60,7 +60,7 @@ static struct xt_table security_table = {
 	.name		= "security",
 	.valid_hooks	= SECURITY_VALID_HOOKS,
 	.me		= THIS_MODULE,
-	.af		= AF_INET6,
+	.af		= NFPROTO_IPV6,
 };
 
 static unsigned int
