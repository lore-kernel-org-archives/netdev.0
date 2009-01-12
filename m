From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 11/13] netxen: remove unnecessary header includes
Date: Mon, 12 Jan 2009 11:23:09 -0800
Message-ID: <1231788191-23794-12-git-send-email-dhananjay@netxen.com>
References: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:56016 "EHLO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756364AbZALTex (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jan 2009 14:34:53 -0500
In-Reply-To: <1231788191-23794-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic.h         |   24 ------------------------
 drivers/net/netxen/netxen_nic_ethtool.c |    6 ------
 drivers/net/netxen/netxen_nic_hdr.h     |   11 -----------
 drivers/net/netxen/netxen_nic_hw.c      |    2 +-
 drivers/net/netxen/netxen_nic_hw.h      |    1 +
 drivers/net/netxen/netxen_nic_init.c    |    2 --
 drivers/net/netxen/netxen_nic_main.c    |    7 +------
 7 files changed, 3 insertions(+), 50 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 42bf202..e028735 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -30,37 +30,13 @@
 #ifndef _NETXEN_NIC_H_
 #define _NETXEN_NIC_H_
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/types.h>
-#include <linux/compiler.h>
-#include <linux/slab.h>
-#include <linux/delay.h>
-#include <linux/init.h>
-#include <linux/ioport.h>
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/ip.h>
-#include <linux/in.h>
-#include <linux/tcp.h>
-#include <linux/skbuff.h>
 
-#include <linux/ethtool.h>
-#include <linux/mii.h>
-#include <linux/interrupt.h>
-#include <linux/timer.h>
-
-#include <linux/mm.h>
-#include <linux/mman.h>
 #include <linux/vmalloc.h>
 
-#include <asm/system.h>
-#include <asm/io.h>
-#include <asm/byteorder.h>
-#include <asm/uaccess.h>
-#include <asm/pgtable.h>
-
 #include "netxen_nic_hw.h"
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index daaa655..17bc4bc 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -31,12 +31,6 @@
  *
  */
 
-#include <linux/types.h>
-#include <linux/delay.h>
-#include <asm/uaccess.h>
-#include <linux/pci.h>
-#include <asm/io.h>
-#include <linux/netdevice.h>
 #include <linux/ethtool.h>
 
 #include "netxen_nic.h"
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index b9f6893..5fd9c6b 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -30,17 +30,6 @@
 #ifndef __NETXEN_NIC_HDR_H_
 #define __NETXEN_NIC_HDR_H_
 
-#include <linux/module.h>
-#include <linux/kernel.h>
-#include <linux/spinlock.h>
-#include <asm/irq.h>
-#include <linux/init.h>
-#include <linux/errno.h>
-#include <linux/pci.h>
-#include <linux/types.h>
-#include <asm/uaccess.h>
-#include <asm/string.h>		/* for memset */
-
 /*
  * The basic unit of access when reading/writing control registers.
  */
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 6ad189f..c866172 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -35,8 +35,8 @@
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
+#include <linux/ethtool.h>
 #include <linux/firmware.h>
-#include <net/ip.h>
 
 #define MASK(n) ((1ULL<<(n))-1)
 #define MN_WIN(addr) (((addr & 0x1fc0000) >> 1) | ((addr >> 25) & 0x3ff))
diff --git a/drivers/net/netxen/netxen_nic_hw.h b/drivers/net/netxen/netxen_nic_hw.h
index aae737d..a2cb2c8 100644
--- a/drivers/net/netxen/netxen_nic_hw.h
+++ b/drivers/net/netxen/netxen_nic_hw.h
@@ -34,6 +34,7 @@
 #ifndef __NETXEN_NIC_HW_H_
 #define __NETXEN_NIC_HW_H_
 
+#include <asm/io.h>
 #include "netxen_nic_hdr.h"
 
 /* Hardware memory size of 128 meg */
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 6e6d38e..d1dccd4 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -31,8 +31,6 @@
  *
  */
 
-#include <linux/netdevice.h>
-#include <linux/delay.h>
 #include "netxen_nic.h"
 #include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f413494..fc49459 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -31,15 +31,10 @@
  *
  */
 
-#include <linux/vmalloc.h>
-#include <linux/highmem.h>
-#include "netxen_nic_hw.h"
-
 #include "netxen_nic.h"
+#include "netxen_nic_hw.h"
 #include "netxen_nic_phan_reg.h"
 
-#include <linux/dma-mapping.h>
-#include <linux/if_vlan.h>
 #include <net/ip.h>
 
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
-- 
1.6.0.2

