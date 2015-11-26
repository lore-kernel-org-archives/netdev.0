From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 1/7] net: remove unnecessary mroute.h includes
Date: Thu, 26 Nov 2015 15:23:44 +0100
Message-ID: <1448547830-21716-2-git-send-email-razor@blackwall.org>
References: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:36607 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbbKZOYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:24:04 -0500
Received: by wmww144 with SMTP id w144so23481574wmw.1
        for <netdev@vger.kernel.org>; Thu, 26 Nov 2015 06:24:02 -0800 (PST)
In-Reply-To: <1448547830-21716-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

It looks like many files are including mroute.h unnecessarily, so remove
the include. Most importantly remove it from ipv6.

CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Steffen Klassert <steffen.klassert@secunet.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ip_gre.c         | 1 -
 net/ipv4/ip_output.c      | 1 -
 net/ipv4/ip_tunnel.c      | 1 -
 net/ipv4/ip_tunnel_core.c | 1 -
 net/ipv4/ip_vti.c         | 1 -
 net/ipv4/ipip.c           | 1 -
 net/ipv6/ip6_gre.c        | 1 -
 7 files changed, 7 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 614521437e30..04a48c0159cc 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -24,7 +24,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/if_vlan.h>
 #include <linux/init.h>
 #include <linux/in6.h>
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 4233cbe47052..e0b94cd843d7 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -76,7 +76,6 @@
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
-#include <linux/mroute.h>
 #include <linux/netlink.h>
 #include <linux/tcp.h>
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index cbb51f3fac06..0f6e9ee031c4 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -30,7 +30,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/in6.h>
 #include <linux/inetdevice.h>
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 6cb9009c3d96..1db8418aa62e 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -24,7 +24,6 @@
 #include <linux/netdevice.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/in6.h>
 #include <linux/inetdevice.h>
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 4d8f0b698777..02d9c21e2953 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -30,7 +30,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index f34c31defafe..1f067294cbc5 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -103,7 +103,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/if_ether.h>
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 3c7b9310b33f..938d03ce5e4b 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -24,7 +24,6 @@
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/if_arp.h>
-#include <linux/mroute.h>
 #include <linux/init.h>
 #include <linux/in6.h>
 #include <linux/inetdevice.h>
-- 
2.4.3
