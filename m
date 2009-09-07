From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] headers: net/ipv[46]/protocol.c header trim
Date: Mon, 7 Sep 2009 16:38:25 +0400
Message-ID: <20090907123825.GB29858@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:49946 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077AbZIGMi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 08:38:26 -0400
Received: by fxm17 with SMTP id 17so1955682fxm.37
        for <netdev@vger.kernel.org>; Mon, 07 Sep 2009 05:38:27 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/ipv4/protocol.c |   19 ++-----------------
 net/ipv6/protocol.c |   15 ++-------------
 2 files changed, 4 insertions(+), 30 deletions(-)

--- a/net/ipv4/protocol.c
+++ b/net/ipv4/protocol.c
@@ -22,26 +22,11 @@
  *		as published by the Free Software Foundation; either version
  *		2 of the License, or (at your option) any later version.
  */
-
-#include <asm/uaccess.h>
-#include <asm/system.h>
+#include <linux/cache.h>
 #include <linux/module.h>
-#include <linux/types.h>
-#include <linux/kernel.h>
-#include <linux/string.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/inet.h>
 #include <linux/netdevice.h>
-#include <linux/timer.h>
-#include <net/ip.h>
+#include <linux/spinlock.h>
 #include <net/protocol.h>
-#include <linux/skbuff.h>
-#include <net/sock.h>
-#include <net/icmp.h>
-#include <net/udp.h>
-#include <net/ipip.h>
-#include <linux/igmp.h>
 
 struct net_protocol *inet_protos[MAX_INET_PROTOS] ____cacheline_aligned_in_smp;
 static DEFINE_SPINLOCK(inet_proto_lock);
--- a/net/ipv6/protocol.c
+++ b/net/ipv6/protocol.c
@@ -20,20 +20,9 @@
  *      - Removed unused variable 'inet6_protocol_base'
  *      - Modified inet6_del_protocol() to correctly maintain copy bit.
  */
-
-#include <linux/errno.h>
-#include <linux/types.h>
-#include <linux/socket.h>
-#include <linux/sockios.h>
-#include <linux/net.h>
-#include <linux/in6.h>
+#include <linux/module.h>
 #include <linux/netdevice.h>
-#include <linux/if_arp.h>
-
-#include <net/sock.h>
-#include <net/snmp.h>
-
-#include <net/ipv6.h>
+#include <linux/spinlock.h>
 #include <net/protocol.h>
 
 struct inet6_protocol *inet6_protos[MAX_INET_PROTOS];
