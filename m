From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: [2.4 PATCH] netfilter broken and unused macro removal
Date: Mon, 4 Dec 2006 10:50:43 +0100
Message-ID: <200612041050.43646.m.kozlowski@tuxland.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Willy Tarreau <wtarreau@hera.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:63236 "EHLO
	tuxland.pl") by vger.kernel.org with ESMTP id S935292AbWLDJvD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 04:51:03 -0500
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

=A0=A0=A0=A0=A0=A0=A0=A0This patch removes broken and unused macro from=
 netfilter code.

Signed-off-by: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

=A0net/ipv4/netfilter/ip_nat_standalone.c | =A0 =A06 ------
=A01 file changed, 6 deletions(-)

--- linux-2.4.34-pre6-a/net/ipv4/netfilter/ip_nat_standalone.c	2005-11-=
16 20:12:54.000000000 +0100
+++ linux-2.4.34-pre6-b/net/ipv4/netfilter/ip_nat_standalone.c	2006-12-=
01 12:10:42.000000000 +0100
@@ -43,12 +43,6 @@
 #define DEBUGP(format, args...)
 #endif
=20
-#define HOOKNAME(hooknum) ((hooknum) =3D=3D NF_IP_POST_ROUTING ? "POST=
_ROUTING"  \
-			   : ((hooknum) =3D=3D NF_IP_PRE_ROUTING ? "PRE_ROUTING" \
-			      : ((hooknum) =3D=3D NF_IP_LOCAL_OUT ? "LOCAL_OUT"  \
-			         : ((hooknum) =3D=3D NF_IP_LOCAL_IN ? "LOCAL_IN"  \
-				    : "*ERROR*")))
-
 static inline int call_expect(struct ip_conntrack *master,
 			      struct sk_buff **pskb,
 			      unsigned int hooknum,


--=20
Regards,

	Mariusz Kozlowski
