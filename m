From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 12/12] ip{,6}tunnel: put spaces around non-unary operators
Date: Fri, 13 Nov 2015 18:09:05 +0100
Message-ID: <1447434545-32182-13-git-send-email-phil@nwl.cc>
References: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:47742 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933425AbbKMRJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Nov 2015 12:09:12 -0500
In-Reply-To: <1447434545-32182-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ip6tunnel.c | 16 ++++++++--------
 ip/iptunnel.c  | 40 ++++++++++++++++++++--------------------
 2 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index d8957f0..320d253 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -110,22 +110,22 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 		printf(" dscp inherit");
 
 	if (p->proto == IPPROTO_GRE) {
-		if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
+		if ((p->i_flags & GRE_KEY) && (p->o_flags & GRE_KEY) && p->o_key == p->i_key)
 			printf(" key %u", ntohl(p->i_key));
-		else if ((p->i_flags|p->o_flags)&GRE_KEY) {
-			if (p->i_flags&GRE_KEY)
+		else if ((p->i_flags | p->o_flags) & GRE_KEY) {
+			if (p->i_flags & GRE_KEY)
 				printf(" ikey %u", ntohl(p->i_key));
-			if (p->o_flags&GRE_KEY)
+			if (p->o_flags & GRE_KEY)
 				printf(" okey %u", ntohl(p->o_key));
 		}
 
-		if (p->i_flags&GRE_SEQ)
+		if (p->i_flags & GRE_SEQ)
 			printf("%s  Drop packets out of sequence.", _SL_);
-		if (p->i_flags&GRE_CSUM)
+		if (p->i_flags & GRE_CSUM)
 			printf("%s  Checksum in received packet is required.", _SL_);
-		if (p->o_flags&GRE_SEQ)
+		if (p->o_flags & GRE_SEQ)
 			printf("%s  Sequence packets on output.", _SL_);
-		if (p->o_flags&GRE_CSUM)
+		if (p->o_flags & GRE_CSUM)
 			printf("%s  Checksum output packets.", _SL_);
 	}
 }
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index b377a5b..b9552ed 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -139,7 +139,7 @@ static int parse_args(int argc, char **argv, int cmd, struct ip_tunnel_parm *p)
 				p->iph.saddr = htonl(INADDR_ANY);
 		} else if (strcmp(*argv, "dev") == 0) {
 			NEXT_ARG();
-			strncpy(medium, *argv, IFNAMSIZ-1);
+			strncpy(medium, *argv, IFNAMSIZ - 1);
 		} else if (strcmp(*argv, "ttl") == 0 ||
 			   strcmp(*argv, "hoplimit") == 0 ||
 			   strcmp(*argv, "hlim") == 0) {
@@ -336,14 +336,14 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	if (p->iph.tos) {
 		SPRINT_BUF(b1);
 		printf(" tos");
-		if (p->iph.tos&1)
+		if (p->iph.tos & 1)
 			printf(" inherit");
-		if (p->iph.tos&~1)
-			printf("%c%s ", p->iph.tos&1 ? '/' : ' ',
-			       rtnl_dsfield_n2a(p->iph.tos&~1, b1, sizeof(b1)));
+		if (p->iph.tos & ~1)
+			printf("%c%s ", p->iph.tos & 1 ? '/' : ' ',
+			       rtnl_dsfield_n2a(p->iph.tos & ~1, b1, sizeof(b1)));
 	}
 
-	if (!(p->iph.frag_off&htons(IP_DF)))
+	if (!(p->iph.frag_off & htons(IP_DF)))
 		printf(" nopmtudisc");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && !tnl_ioctl_get_6rd(p->name, &ip6rd) && ip6rd.prefixlen) {
@@ -357,22 +357,22 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 		}
 	}
 
-	if ((p->i_flags&GRE_KEY) && (p->o_flags&GRE_KEY) && p->o_key == p->i_key)
+	if ((p->i_flags & GRE_KEY) && (p->o_flags & GRE_KEY) && p->o_key == p->i_key)
 		printf(" key %u", ntohl(p->i_key));
-	else if ((p->i_flags|p->o_flags)&GRE_KEY) {
-		if (p->i_flags&GRE_KEY)
+	else if ((p->i_flags | p->o_flags) & GRE_KEY) {
+		if (p->i_flags & GRE_KEY)
 			printf(" ikey %u", ntohl(p->i_key));
-		if (p->o_flags&GRE_KEY)
+		if (p->o_flags & GRE_KEY)
 			printf(" okey %u", ntohl(p->o_key));
 	}
 
-	if (p->i_flags&GRE_SEQ)
+	if (p->i_flags & GRE_SEQ)
 		printf("%s  Drop packets out of sequence.", _SL_);
-	if (p->i_flags&GRE_CSUM)
+	if (p->i_flags & GRE_CSUM)
 		printf("%s  Checksum in received packet is required.", _SL_);
-	if (p->o_flags&GRE_SEQ)
+	if (p->o_flags & GRE_SEQ)
 		printf("%s  Sequence packets on output.", _SL_);
-	if (p->o_flags&GRE_CSUM)
+	if (p->o_flags & GRE_CSUM)
 		printf("%s  Checksum output packets.", _SL_);
 }
 
@@ -592,19 +592,19 @@ int do_iptunnel(int argc, char **argv)
 
 	if (argc > 0) {
 		if (matches(*argv, "add") == 0)
-			return do_add(SIOCADDTUNNEL, argc-1, argv+1);
+			return do_add(SIOCADDTUNNEL, argc - 1, argv + 1);
 		if (matches(*argv, "change") == 0)
-			return do_add(SIOCCHGTUNNEL, argc-1, argv+1);
+			return do_add(SIOCCHGTUNNEL, argc - 1, argv + 1);
 		if (matches(*argv, "delete") == 0)
-			return do_del(argc-1, argv+1);
+			return do_del(argc - 1, argv + 1);
 		if (matches(*argv, "show") == 0 ||
 		    matches(*argv, "lst") == 0 ||
 		    matches(*argv, "list") == 0)
-			return do_show(argc-1, argv+1);
+			return do_show(argc - 1, argv + 1);
 		if (matches(*argv, "prl") == 0)
-			return do_prl(argc-1, argv+1);
+			return do_prl(argc - 1, argv + 1);
 		if (matches(*argv, "6rd") == 0)
-			return do_6rd(argc-1, argv+1);
+			return do_6rd(argc - 1, argv + 1);
 		if (matches(*argv, "help") == 0)
 			usage();
 	} else
-- 
2.1.2
