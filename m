From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: [PATCH net-next] ipv6: remove some unused include in flowlabel
Date: Tue, 18 Feb 2014 14:45:42 +0100
Message-ID: <1392731142-3840-1-git-send-email-florent.fourcot@enst-bretagne.fr>
Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:58487 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbaBRNps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 08:45:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These include are here since kernel 2.2.7, but probably never used.

Signed-off-by: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
---
 net/ipv6/ip6_flowlabel.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index dfa41bb..0961b5e 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -15,9 +15,7 @@
 #include <linux/socket.h>
 #include <linux/net.h>
 #include <linux/netdevice.h>
-#include <linux/if_arp.h>
 #include <linux/in6.h>
-#include <linux/route.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/slab.h>
@@ -28,12 +26,8 @@
 #include <net/sock.h>
 
 #include <net/ipv6.h>
-#include <net/ndisc.h>
-#include <net/protocol.h>
-#include <net/ip6_route.h>
 #include <net/addrconf.h>
 #include <net/rawv6.h>
-#include <net/icmp.h>
 #include <net/transp_v6.h>
 
 #include <asm/uaccess.h>
-- 
1.8.5.3
