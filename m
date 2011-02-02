From: kaber@trash.net
Subject: [PATCH 15/26] netfilter: ipset: remove unnecessary includes
Date: Thu,  3 Feb 2011 00:11:53 +0100
Message-ID: <1296688324-7830-16-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:44721 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755398Ab1BBXMe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Feb 2011 18:12:34 -0500
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

None of the set types need uaccess.h since this is handled centrally
in ip_set_core. Most set types additionally don't need bitops.h and
spinlock.h since they use neither. tcp.h is only needed by those
using before(), udp.h is not needed at all.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/ipset/ip_set_bitmap_ip.c      |    1 -
 net/netfilter/ipset/ip_set_bitmap_ipmac.c   |    3 ---
 net/netfilter/ipset/ip_set_bitmap_port.c    |    5 -----
 net/netfilter/ipset/ip_set_hash_ip.c        |    3 ---
 net/netfilter/ipset/ip_set_hash_ipport.c    |    3 ---
 net/netfilter/ipset/ip_set_hash_ipportip.c  |    3 ---
 net/netfilter/ipset/ip_set_hash_ipportnet.c |    3 ---
 net/netfilter/ipset/ip_set_hash_net.c       |    3 ---
 net/netfilter/ipset/ip_set_hash_netport.c   |    3 ---
 9 files changed, 0 insertions(+), 27 deletions(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_ip.c b/net/netfilter/ipset/ip_set_bitmap_ip.c
index 0474400..bca9699 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ip.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ip.c
@@ -13,7 +13,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
 #include <linux/bitops.h>
 #include <linux/spinlock.h>
 #include <linux/netlink.h>
diff --git a/net/netfilter/ipset/ip_set_bitmap_ipmac.c b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
index d826332..5e79017 100644
--- a/net/netfilter/ipset/ip_set_bitmap_ipmac.c
+++ b/net/netfilter/ipset/ip_set_bitmap_ipmac.c
@@ -15,9 +15,6 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/if_ether.h>
 #include <linux/netlink.h>
 #include <linux/jiffies.h>
diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index 92074bb..165f09b 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -9,13 +9,8 @@
 
 #include <linux/module.h>
 #include <linux/ip.h>
-#include <linux/tcp.h>
-#include <linux/udp.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/netlink.h>
 #include <linux/jiffies.h>
 #include <linux/timer.h>
diff --git a/net/netfilter/ipset/ip_set_hash_ip.c b/net/netfilter/ipset/ip_set_hash_ip.c
index 53964bc..43bcce2 100644
--- a/net/netfilter/ipset/ip_set_hash_ip.c
+++ b/net/netfilter/ipset/ip_set_hash_ip.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
diff --git a/net/netfilter/ipset/ip_set_hash_ipport.c b/net/netfilter/ipset/ip_set_hash_ipport.c
index d9b1928..adbe787 100644
--- a/net/netfilter/ipset/ip_set_hash_ipport.c
+++ b/net/netfilter/ipset/ip_set_hash_ipport.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
diff --git a/net/netfilter/ipset/ip_set_hash_ipportip.c b/net/netfilter/ipset/ip_set_hash_ipportip.c
index 80dae9d..22e23ab 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportip.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportip.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
diff --git a/net/netfilter/ipset/ip_set_hash_ipportnet.c b/net/netfilter/ipset/ip_set_hash_ipportnet.c
index 8eacd8a..6033e8b 100644
--- a/net/netfilter/ipset/ip_set_hash_ipportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_ipportnet.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <asm/uaccess.h>
-#include <asm/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
diff --git a/net/netfilter/ipset/ip_set_hash_net.c b/net/netfilter/ipset/ip_set_hash_net.c
index fb0e6a6..c4db202 100644
--- a/net/netfilter/ipset/ip_set_hash_net.c
+++ b/net/netfilter/ipset/ip_set_hash_net.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
diff --git a/net/netfilter/ipset/ip_set_hash_netport.c b/net/netfilter/ipset/ip_set_hash_netport.c
index 342250f..34a1656 100644
--- a/net/netfilter/ipset/ip_set_hash_netport.c
+++ b/net/netfilter/ipset/ip_set_hash_netport.c
@@ -12,9 +12,6 @@
 #include <linux/ip.h>
 #include <linux/skbuff.h>
 #include <linux/errno.h>
-#include <linux/uaccess.h>
-#include <linux/bitops.h>
-#include <linux/spinlock.h>
 #include <linux/random.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
-- 
1.7.2.3

