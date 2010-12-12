From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 2/6] ethernet: Move ethoc.c
Date: Sun, 12 Dec 2010 04:03:23 -0800
Message-ID: <34c8ff604d6239d62c01e00b3732b9aeab3f2593.1292154142.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2511 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752747Ab0LLMDh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:37 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move ethernet Open Core file to ethernet directory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                 |   10 ----------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig.10-100 |   10 ++++++++++
 drivers/net/ethernet/Makefile       |    6 +-----
 drivers/net/{ => ethernet}/ethoc.c  |    0
 5 files changed, 11 insertions(+), 16 deletions(-)
 rename drivers/net/{ => ethernet}/ethoc.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c1d1be8..ea9dbaf 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1021,16 +1021,6 @@ config ENC28J60_WRITEVERIFY
 	  Enable the verify after the buffer write useful for debugging purpose.
 	  If unsure, say N.
 
-config ETHOC
-	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
-	depends on NET_ETHERNET && HAS_IOMEM && HAS_DMA
-	select MII
-	select PHYLIB
-	select CRC32
-	select BITREVERSE
-	help
-	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
-
 config GRETH
 	tristate "Aeroflex Gaisler GRETH Ethernet MAC support"
 	depends on SPARC
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index bfb5ade..1265d0e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -257,7 +257,6 @@ obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
 pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
 obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
-obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
index 8b1ee80..a5c62bc 100644
--- a/drivers/net/ethernet/Kconfig.10-100
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -1,3 +1,13 @@
 #
 # 10 Mb and 100Mb ethernet device configuration
 #
+
+config ETHOC
+	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
+	depends on NET_ETHERNET && HAS_IOMEM && HAS_DMA
+	select MII
+	select PHYLIB
+	select CRC32
+	select BITREVERSE
+	help
+	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index f2aebec..ad2afc1 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -2,8 +2,4 @@
 # Makefile for ethernet device drivers
 #
 
-# Dummy object just to avoid breaking build
-# These comments and the line below will be deleted on the
-# first addition to this file
-
-obj-$(CONFIG_ETHERNET_DUMMY_DRIVER) += /dev/null/dummy.o
+obj-$(CONFIG_ETHOC)		+= ethoc.o
diff --git a/drivers/net/ethoc.c b/drivers/net/ethernet/ethoc.c
similarity index 100%
rename from drivers/net/ethoc.c
rename to drivers/net/ethernet/ethoc.c
-- 
1.7.3.3.398.g0b0cd.dirty

