From: "Daniel 'NebuchadnezzaR' Dehennin" <nebuchadnezzar@nerim.net>
Subject: [PATCH] 2.4.x USAGI mipv6_ha_ipsec
Date: Fri, 01 Aug 2003 19:53:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87n0etgt7w.fsf@zion.matrix>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

My 2.4.21 with USAGI 20030801 don't build
/net/ipv6/mobile_ip6/mipv6_ha_ipsec.c :
mipv6_ha_ipsec.c: In function `mipv6_change_sa_index':
mipv6_ha_ipsec.c:118: warning: implicit declaration of function `in6_ntop'
mipv6_ha_ipsec.c:118: warning: format argument is not a pointer (arg 4)
mipv6_ha_ipsec.c:119: warning: format argument is not a pointer (arg 4)
mipv6_ha_ipsec.c:126: warning: format argument is not a pointer (arg 4)
mipv6_ha_ipsec.c:127: warning: format argument is not a pointer (arg 4)
[...]

I search for the definition of in6_ntop, it in include/linux/inet.h
so I make that patch.

Thanks.

--- linux-2.4.21/net/ipv6/mobile_ip6/mipv6_ha_ipsec.c.orig	2003-08-01 19:37:22.000000000 +0200
+++ linux-2.4.21/net/ipv6/mobile_ip6/mipv6_ha_ipsec.c	2003-08-01 19:03:42.000000000 +0200
@@ -62,6 +62,7 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/socket.h>
+#include <linux/inet.h>
 #include <linux/in6.h>
 #include <linux/pfkeyv2.h>
 #include <net/spd.h>


-- 
Daniel 'NebuchadnezzaR' Dehennin
