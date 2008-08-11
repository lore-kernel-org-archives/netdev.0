From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [NET]: remove unnecessary #include
Date: Mon, 11 Aug 2008 12:56:44 +0800
Message-ID: <20080811125623.03D5.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, jgarzik@redhat.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:12632 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739AbYHKE4u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2008 00:56:50 -0400
Received: by ti-out-0910.google.com with SMTP id b6so942402tic.23
        for <netdev@vger.kernel.org>; Sun, 10 Aug 2008 21:56:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The drivers below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
  drivers/net/acenic.c
  drivers/net/bnx2x_link.c
  drivers/net/bnx2x_main.c
  drivers/net/cpmac.c
  drivers/net/gianfar_sysfs.c
  drivers/net/ipg.h
  drivers/net/ppp_mppe.c
  drivers/net/pppol2tp.c
  drivers/net/r6040.c
  drivers/net/sh_eth.c
  drivers/net/sky2.c
  drivers/net/tehuti.h
  drivers/net/typhoon.c

This patch removes the said #include.

Signed-off-by: Huang Weiyi <hwy@cn.fujitsu.com>

diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index e4483de..66de80b 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -52,7 +52,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ff2743d..a116254 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -21,7 +21,6 @@
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/mutex.h>
-#include <linux/version.h>
 
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 272a4bd..5cf3865 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -44,7 +44,6 @@
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
-#include <linux/version.h>
 #include <net/ip6_checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index a7800e5..ec6b0af 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -26,7 +26,6 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/delay.h>
-#include <linux/version.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 5116f68..782c201 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -33,7 +33,6 @@
 
 #include <asm/uaccess.h>
 #include <linux/module.h>
-#include <linux/version.h>
 
 #include "gianfar.h"
 
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index e0e718a..dd9318f 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -7,7 +7,6 @@
 #ifndef __LINUX_IPG_H
 #define __LINUX_IPG_H
 
-#include <linux/version.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -21,7 +20,6 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 #include <asm/bitops.h>
 
 /*
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index b35d794..88f03c9 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -46,7 +46,6 @@
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/slab.h>
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index f929882..ff175e8 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -61,7 +61,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/string.h>
 #include <linux/list.h>
 #include <asm/uaccess.h>
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6531ff5..5d86281 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -24,7 +24,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/moduleparam.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 25e62cf..1c370e6 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -20,7 +20,6 @@
  *  the file called "COPYING".
  */
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7d29edc..06dfc95 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -24,7 +24,6 @@
 
 #include <linux/crc32.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/dma-mapping.h>
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index c66dfc9..7db48f1 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -27,7 +27,6 @@
 #include <linux/sched.h>
 #include <linux/tty.h>
 #include <linux/if_vlan.h>
-#include <linux/version.h>
 #include <linux/interrupt.h>
 #include <linux/vmalloc.h>
 #include <asm/byteorder.h>
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 8549f11..734ce09 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -128,7 +128,6 @@ static const int multicast_filter_limit = 32;
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <linux/in6.h>
-#include <linux/version.h>
 #include <linux/dma-mapping.h>
 
 #include "typhoon.h"

