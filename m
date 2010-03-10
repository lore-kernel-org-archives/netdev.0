From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-2.6] ipv6 ip6_tunnel: eliminate unused recursion field from ip6_tnl{}.
Date: Wed, 10 Mar 2010 11:47:52 +0900
Message-ID: <201003100247.o2A2lqaX001898@94.43.138.210.xn.2iij.net>
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:37336 "EHLO
	94.43.138.210.xn.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755180Ab0CJCr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 21:47:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit a43912ab19... ("tunnel: eliminate recursion field") eliminated
use of recursion field from tunnel structures, but its definition
still exists in ip6_tnl{}.

Let's remove that unused field.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ip6_tunnel.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 83b4e00..fbf9d1c 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -15,7 +15,6 @@
 struct ip6_tnl {
 	struct ip6_tnl *next;	/* next tunnel in list */
 	struct net_device *dev;	/* virtual device associated with tunnel */
-	int recursion;		/* depth of hard_start_xmit recursion */
 	struct ip6_tnl_parm parms;	/* tunnel configuration parameters */
 	struct flowi fl;	/* flowi template for xmit */
 	struct dst_entry *dst_cache;    /* cached dst */
-- 
1.5.6.5

