From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/4] [IPVS]: Kill some bloat
Date: Sat,  5 Jan 2008 15:39:06 +0200
Message-ID: <11995403483512-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11995403482366-git-send-email-ilpo.jarvinen@helsinki.fi> <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57459 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbYAENjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2008 08:39:11 -0500
In-Reply-To: <11995403481730-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

net/ipv4/ipvs/ip_vs_xmit.c:
  ip_vs_icmp_xmit   | -638
  ip_vs_tunnel_xmit | -674
  ip_vs_nat_xmit    | -716
  ip_vs_dr_xmit     | -682
 4 functions changed, 2710 bytes removed, diff: -2710

net/ipv4/ipvs/ip_vs_xmit.c:
  __ip_vs_get_out_rt | +595
 1 function changed, 595 bytes added, diff: +595

net/ipv4/ipvs/ip_vs_xmit.o:
 5 functions changed, 595 bytes added, 2710 bytes removed, diff: -2115

Without some CONFIG.*DEBUGs:

net/ipv4/ipvs/ip_vs_xmit.o:
 5 functions changed, 383 bytes added, 1513 bytes removed, diff: -1130

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/ipvs/ip_vs_xmit.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipvs/ip_vs_xmit.c b/net/ipv4/ipvs/ip_vs_xmit.c
index 1e96bf8..8436bf8 100644
--- a/net/ipv4/ipvs/ip_vs_xmit.c
+++ b/net/ipv4/ipvs/ip_vs_xmit.c
@@ -59,7 +59,7 @@ __ip_vs_dst_check(struct ip_vs_dest *dest, u32 rtos, =
u32 cookie)
 	return dst;
 }
=20
-static inline struct rtable *
+static struct rtable *
 __ip_vs_get_out_rt(struct ip_vs_conn *cp, u32 rtos)
 {
 	struct rtable *rt;			/* Route to the other host */
--=20
1.5.0.6

