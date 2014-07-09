From: Varka Bhadram <varkabhadram@gmail.com>
Subject: [PATCH net-next 1/2] ieee802154: removed unwanted header files
Date: Wed,  9 Jul 2014 09:14:04 +0530
Message-ID: <1404877445-2757-2-git-send-email-varkab@cdac.in>
References: <1404877445-2757-1-git-send-email-varkab@cdac.in>
Cc: alex.aring@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	davem@davemloft.net, Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35439 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaGIDp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 23:45:28 -0400
Received: by mail-pd0-f178.google.com with SMTP id r10so8358995pdi.9
        for <netdev@vger.kernel.org>; Tue, 08 Jul 2014 20:45:28 -0700 (PDT)
In-Reply-To: <1404877445-2757-1-git-send-email-varkab@cdac.in>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 net/ieee802154/6lowpan_iphc.c  |    4 ----
 net/ieee802154/6lowpan_rtnl.c  |    7 -------
 net/ieee802154/af_ieee802154.c |   11 -----------
 net/ieee802154/dgram.c         |    6 ------
 net/ieee802154/header_ops.c    |    1 -
 net/ieee802154/netlink.c       |    2 --
 net/ieee802154/nl-mac.c        |    8 --------
 net/ieee802154/nl-phy.c        |    4 ----
 net/ieee802154/nl_policy.c     |    1 -
 net/ieee802154/raw.c           |    5 -----
 net/ieee802154/reassembly.c    |   11 -----------
 net/ieee802154/wpan-class.c    |    4 ----
 12 files changed, 64 deletions(-)

diff --git a/net/ieee802154/6lowpan_iphc.c b/net/ieee802154/6lowpan_iphc.c
index 511ddee..d85caa2 100644
--- a/net/ieee802154/6lowpan_iphc.c
+++ b/net/ieee802154/6lowpan_iphc.c
@@ -49,12 +49,8 @@
  * SUCH DAMAGE.
  */
 
-#include <linux/bitops.h>
-#include <linux/if_arp.h>
 #include <linux/module.h>
-#include <linux/netdevice.h>
 #include <net/6lowpan.h>
-#include <net/ipv6.h>
 #include <net/af_ieee802154.h>
 
 /* Uncompress address function for source and
diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 016b77e..54cf80b 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -44,16 +44,9 @@
  * SUCH DAMAGE.
  */
 
-#include <linux/bitops.h>
-#include <linux/if_arp.h>
 #include <linux/module.h>
-#include <linux/moduleparam.h>
-#include <linux/netdevice.h>
-#include <net/af_ieee802154.h>
-#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/6lowpan.h>
-#include <net/ipv6.h>
 
 #include "reassembly.h"
 
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index 29e0de6..d19fd25 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -21,21 +21,10 @@
  * Maxim Gorbachyov <maxim.gorbachev@siemens.com>
  */
 
-#include <linux/net.h>
-#include <linux/capability.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
-#include <linux/if.h>
-#include <linux/termios.h>	/* For TIOCOUTQ/INQ */
-#include <linux/list.h>
-#include <linux/slab.h>
-#include <net/datalink.h>
-#include <net/psnap.h>
-#include <net/sock.h>
-#include <net/tcp_states.h>
 #include <net/route.h>
 
-#include <net/af_ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 #include "af802154.h"
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
index ef2ad8a..7d929cd 100644
--- a/net/ieee802154/dgram.c
+++ b/net/ieee802154/dgram.c
@@ -21,15 +21,9 @@
  * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
  */
 
-#include <linux/capability.h>
-#include <linux/net.h>
 #include <linux/module.h>
 #include <linux/if_arp.h>
-#include <linux/list.h>
-#include <linux/slab.h>
 #include <net/sock.h>
-#include <net/af_ieee802154.h>
-#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 #include <asm/ioctls.h>
diff --git a/net/ieee802154/header_ops.c b/net/ieee802154/header_ops.c
index c09294e..959f56a 100644
--- a/net/ieee802154/header_ops.c
+++ b/net/ieee802154/header_ops.c
@@ -15,7 +15,6 @@
  */
 
 #include <net/mac802154.h>
-#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 static int
diff --git a/net/ieee802154/netlink.c b/net/ieee802154/netlink.c
index 9222966..90deb70 100644
--- a/net/ieee802154/netlink.c
+++ b/net/ieee802154/netlink.c
@@ -22,8 +22,6 @@
  * Maxim Osipov <maxim.osipov@siemens.com>
  */
 
-#include <linux/kernel.h>
-#include <linux/gfp.h>
 #include <net/genetlink.h>
 #include <linux/nl802154.h>
 
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index c6bfe22..17c53397 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -22,18 +22,10 @@
  * Maxim Osipov <maxim.osipov@siemens.com>
  */
 
-#include <linux/gfp.h>
-#include <linux/kernel.h>
 #include <linux/if_arp.h>
-#include <linux/netdevice.h>
-#include <net/netlink.h>
 #include <net/genetlink.h>
 #include <net/sock.h>
 #include <linux/nl802154.h>
-#include <linux/export.h>
-#include <net/af_ieee802154.h>
-#include <net/nl802154.h>
-#include <net/ieee802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/wpan-phy.h>
 
diff --git a/net/ieee802154/nl-phy.c b/net/ieee802154/nl-phy.c
index 972baf8..a685f14 100644
--- a/net/ieee802154/nl-phy.c
+++ b/net/ieee802154/nl-phy.c
@@ -22,13 +22,9 @@
  * Maxim Osipov <maxim.osipov@siemens.com>
  */
 
-#include <linux/kernel.h>
-#include <linux/slab.h>
 #include <linux/if_arp.h>
-#include <net/netlink.h>
 #include <net/genetlink.h>
 #include <net/wpan-phy.h>
-#include <net/af_ieee802154.h>
 #include <net/ieee802154_netdev.h>
 #include <net/rtnetlink.h> /* for rtnl_{un,}lock */
 #include <linux/nl802154.h>
diff --git a/net/ieee802154/nl_policy.c b/net/ieee802154/nl_policy.c
index 3a703ab8..71fb7b0 100644
--- a/net/ieee802154/nl_policy.c
+++ b/net/ieee802154/nl_policy.c
@@ -18,7 +18,6 @@
  *
  */
 
-#include <linux/kernel.h>
 #include <net/netlink.h>
 #include <linux/nl802154.h>
 
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
index 9d1f648..a5a448d 100644
--- a/net/ieee802154/raw.c
+++ b/net/ieee802154/raw.c
@@ -21,13 +21,8 @@
  * Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
  */
 
-#include <linux/net.h>
-#include <linux/module.h>
 #include <linux/if_arp.h>
-#include <linux/list.h>
-#include <linux/slab.h>
 #include <net/sock.h>
-#include <net/af_ieee802154.h>
 #include <net/ieee802154_netdev.h>
 
 #include "af802154.h"
diff --git a/net/ieee802154/reassembly.c b/net/ieee802154/reassembly.c
index b85bd3f..feff865 100644
--- a/net/ieee802154/reassembly.c
+++ b/net/ieee802154/reassembly.c
@@ -14,19 +14,8 @@
 
 #define pr_fmt(fmt) "6LoWPAN: " fmt
 
-#include <linux/net.h>
-#include <linux/list.h>
-#include <linux/netdevice.h>
-#include <linux/random.h>
-#include <linux/jhash.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
-#include <linux/export.h>
-
 #include <net/ieee802154_netdev.h>
 #include <net/6lowpan.h>
-#include <net/ipv6.h>
-#include <net/inet_frag.h>
 
 #include "reassembly.h"
 
diff --git a/net/ieee802154/wpan-class.c b/net/ieee802154/wpan-class.c
index 4955e0f..9afbedb 100644
--- a/net/ieee802154/wpan-class.c
+++ b/net/ieee802154/wpan-class.c
@@ -16,11 +16,7 @@
  *
  */
 
-#include <linux/slab.h>
-#include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/device.h>
-
 #include <net/wpan-phy.h>
 
 #include "ieee802154.h"
-- 
1.7.9.5
