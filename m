From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH] ipv4: mode 0555 in ipv4_skeleton
Date: Tue, 26 Aug 2008 20:00:03 +0100 (BST)
Message-ID: <Pine.LNX.4.64.0808261950390.4716@blonde.site>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from extu-mxob-2.symantec.com ([216.10.194.135]:53751 "EHLO
	extu-mxob-2.symantec.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758916AbYHZS74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 14:59:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vpnc on today's kernel says Cannot open "/proc/sys/net/ipv4/route/flush":
d--------- 0 root root 0 2008-08-26 11:32 /proc/sys/net/ipv4/route
d--------- 0 root root 0 2008-08-26 19:16 /proc/sys/net/ipv4/neigh

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 net/ipv4/route.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 2.6.27-rc4-git/net/ipv4/route.c	2008-08-26 10:08:51.000000000 +0100
+++ linux/net/ipv4/route.c	2008-08-26 19:35:40.000000000 +0100
@@ -3121,9 +3121,9 @@ static struct ctl_table empty[1];
 static struct ctl_table ipv4_skeleton[] =
 {
 	{ .procname = "route", .ctl_name = NET_IPV4_ROUTE,
-	  .child = ipv4_route_table},
+	  .mode = 0555, .child = ipv4_route_table},
 	{ .procname = "neigh", .ctl_name = NET_IPV4_NEIGH,
-	  .child = empty},
+	  .mode = 0555, .child = empty},
 	{ }
 };
 
