From: akpm@linux-foundation.org
Subject: [patch 09/18] Clean up duplicate includes in drivers/net/
Date: Fri, 10 Aug 2007 14:05:20 -0700
Message-ID: <200708102105.l7AL5Ko8008971@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com, linville@tuxdriver.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:47637 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752247AbXHJVRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:17:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	 drivers/net/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Acked-by: "John W. Linville" <linville@tuxdriver.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/atl1/atl1_main.c           |    1 -
 drivers/net/bfin_mac.c                 |    5 -----
 drivers/net/bonding/bond_sysfs.c       |    1 -
 drivers/net/fs_enet/fs_enet-main.c     |    2 --
 drivers/net/gianfar.h                  |    1 -
 drivers/net/gianfar_ethtool.c          |    1 -
 drivers/net/irda/kingsun-sir.c         |    1 -
 drivers/net/irda/mcs7780.c             |    1 -
 drivers/net/mipsnet.c                  |    1 -
 drivers/net/netxen/netxen_nic_main.c   |    1 -
 drivers/net/qla3xxx.c                  |    1 -
 drivers/net/tsi108_eth.c               |    1 -
 drivers/net/wireless/ipw2200.h         |    1 -
 drivers/net/wireless/zd1211rw/zd_def.h |    1 -
 14 files changed, 19 deletions(-)

diff -puN drivers/net/atl1/atl1_main.c~clean-up-duplicate-includes-in-drivers-net drivers/net/atl1/atl1_main.c
--- a/drivers/net/atl1/atl1_main.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/atl1/atl1_main.c
@@ -76,7 +76,6 @@
 #include <linux/compiler.h>
 #include <linux/delay.h>
 #include <linux/mii.h>
-#include <linux/interrupt.h>
 #include <net/checksum.h>
 
 #include <asm/atomic.h>
diff -puN drivers/net/bfin_mac.c~clean-up-duplicate-includes-in-drivers-net drivers/net/bfin_mac.c
--- a/drivers/net/bfin_mac.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/bfin_mac.c
@@ -47,15 +47,10 @@
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-
 #include <linux/platform_device.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/skbuff.h>
 
 #include <asm/dma.h>
 #include <linux/dma-mapping.h>
diff -puN drivers/net/bonding/bond_sysfs.c~clean-up-duplicate-includes-in-drivers-net drivers/net/bonding/bond_sysfs.c
--- a/drivers/net/bonding/bond_sysfs.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/bonding/bond_sysfs.c
@@ -31,7 +31,6 @@
 #include <linux/inetdevice.h>
 #include <linux/in.h>
 #include <linux/sysfs.h>
-#include <linux/string.h>
 #include <linux/ctype.h>
 #include <linux/inet.h>
 #include <linux/rtnetlink.h>
diff -puN drivers/net/fs_enet/fs_enet-main.c~clean-up-duplicate-includes-in-drivers-net drivers/net/fs_enet/fs_enet-main.c
--- a/drivers/net/fs_enet/fs_enet-main.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/fs_enet/fs_enet-main.c
@@ -39,8 +39,6 @@
 
 #include <linux/vmalloc.h>
 #include <asm/pgtable.h>
-
-#include <asm/pgtable.h>
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 
diff -puN drivers/net/gianfar.h~clean-up-duplicate-includes-in-drivers-net drivers/net/gianfar.h
--- a/drivers/net/gianfar.h~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/gianfar.h
@@ -45,7 +45,6 @@
 #include <linux/crc32.h>
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
-#include <linux/netdevice.h>
 #include <linux/fsl_devices.h>
 #include "gianfar_mii.h"
 
diff -puN drivers/net/gianfar_ethtool.c~clean-up-duplicate-includes-in-drivers-net drivers/net/gianfar_ethtool.c
--- a/drivers/net/gianfar_ethtool.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/gianfar_ethtool.c
@@ -34,7 +34,6 @@
 #include <linux/module.h>
 #include <linux/crc32.h>
 #include <asm/types.h>
-#include <asm/uaccess.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
 #include <linux/phy.h>
diff -puN drivers/net/irda/kingsun-sir.c~clean-up-duplicate-includes-in-drivers-net drivers/net/irda/kingsun-sir.c
--- a/drivers/net/irda/kingsun-sir.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/irda/kingsun-sir.c
@@ -66,7 +66,6 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/slab.h>
-#include <linux/module.h>
 #include <linux/kref.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff -puN drivers/net/irda/mcs7780.c~clean-up-duplicate-includes-in-drivers-net drivers/net/irda/mcs7780.c
--- a/drivers/net/irda/mcs7780.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/irda/mcs7780.c
@@ -50,7 +50,6 @@
 #include <linux/errno.h>
 #include <linux/init.h>
 #include <linux/slab.h>
-#include <linux/module.h>
 #include <linux/kref.h>
 #include <linux/usb.h>
 #include <linux/device.h>
diff -puN drivers/net/mipsnet.c~clean-up-duplicate-includes-in-drivers-net drivers/net/mipsnet.c
--- a/drivers/net/mipsnet.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/mipsnet.c
@@ -11,7 +11,6 @@
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
-#include <linux/netdevice.h>
 #include <linux/platform_device.h>
 #include <asm/io.h>
 #include <asm/mips-boards/simint.h>
diff -puN drivers/net/netxen/netxen_nic_main.c~clean-up-duplicate-includes-in-drivers-net drivers/net/netxen/netxen_nic_main.c
--- a/drivers/net/netxen/netxen_nic_main.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/netxen/netxen_nic_main.c
@@ -39,7 +39,6 @@
 #include "netxen_nic_phan_reg.h"
 
 #include <linux/dma-mapping.h>
-#include <linux/vmalloc.h>
 #include <net/ip.h>
 
 MODULE_DESCRIPTION("NetXen Multi port (1/10) Gigabit Network Driver");
diff -puN drivers/net/qla3xxx.c~clean-up-duplicate-includes-in-drivers-net drivers/net/qla3xxx.c
--- a/drivers/net/qla3xxx.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/qla3xxx.c
@@ -31,7 +31,6 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 
diff -puN drivers/net/tsi108_eth.c~clean-up-duplicate-includes-in-drivers-net drivers/net/tsi108_eth.c
--- a/drivers/net/tsi108_eth.c~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/tsi108_eth.c
@@ -47,7 +47,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/timer.h>
 #include <linux/platform_device.h>
-#include <linux/etherdevice.h>
 
 #include <asm/system.h>
 #include <asm/io.h>
diff -puN drivers/net/wireless/ipw2200.h~clean-up-duplicate-includes-in-drivers-net drivers/net/wireless/ipw2200.h
--- a/drivers/net/wireless/ipw2200.h~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/wireless/ipw2200.h
@@ -45,7 +45,6 @@
 
 #include <linux/firmware.h>
 #include <linux/wireless.h>
-#include <linux/dma-mapping.h>
 #include <linux/jiffies.h>
 #include <asm/io.h>
 
diff -puN drivers/net/wireless/zd1211rw/zd_def.h~clean-up-duplicate-includes-in-drivers-net drivers/net/wireless/zd1211rw/zd_def.h
--- a/drivers/net/wireless/zd1211rw/zd_def.h~clean-up-duplicate-includes-in-drivers-net
+++ a/drivers/net/wireless/zd1211rw/zd_def.h
@@ -21,7 +21,6 @@
 #include <linux/kernel.h>
 #include <linux/stringify.h>
 #include <linux/device.h>
-#include <linux/kernel.h>
 
 typedef u16 __nocast zd_addr_t;
 
_
