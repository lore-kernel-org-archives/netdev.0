From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/8] [IPV6] route: kill some bloat
Date: Sat, 12 Jan 2008 11:40:13 +0200
Message-ID: <12001308171814-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12001308173969-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308171262-git-send-email-ilpo.jarvinen@helsinki.fi> <12001308173014-git-send-email-ilpo.jarvinen@helsinki.fi> <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:38124 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761114AbYALJkU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:40:20 -0500
In-Reply-To: <1200130817664-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv6/route.c:
  ip6_pkt_prohibit_out | -130
  ip6_pkt_discard      | -261
  ip6_pkt_discard_out  | -130
  ip6_pkt_prohibit     | -261
 4 functions changed, 782 bytes removed, diff: -782

net/ipv6/route.c:
  ip6_pkt_drop | +300
 1 function changed, 300 bytes added, diff: +300

net/ipv6/route.o:
 5 functions changed, 300 bytes added, 782 bytes removed, diff: -482

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv6/route.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 02354a7..d3b5811 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1762,8 +1762,7 @@ int ipv6_route_ioctl(unsigned int cmd, void __use=
r *arg)
  *	Drop the packet on the floor
  */
=20
-static inline int ip6_pkt_drop(struct sk_buff *skb, int code,
-			       int ipstats_mib_noroutes)
+static int ip6_pkt_drop(struct sk_buff *skb, int code, int ipstats_mib=
_noroutes)
 {
 	int type;
 	switch (ipstats_mib_noroutes) {
--=20
1.5.0.6

