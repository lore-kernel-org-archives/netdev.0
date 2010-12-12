From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 3/6] ethernet: Move dnet.[ch]
Date: Sun, 12 Dec 2010 04:03:24 -0800
Message-ID: <e692e136c6e0ac8fcd4c73b17942de1b6145d3c5.1292154142.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2515 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752762Ab0LLMDj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:39 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move dnet files to ethernet directory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                 |   11 -----------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig.10-100 |   11 +++++++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/dnet.c   |    0
 drivers/net/{ => ethernet}/dnet.h   |    0
 6 files changed, 12 insertions(+), 12 deletions(-)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ea9dbaf..c0716d9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1114,17 +1114,6 @@ config NI65
 	  To compile this driver as a module, choose M here. The module
 	  will be called ni65.
 
-config DNET
-	tristate "Dave ethernet support (DNET)"
-	depends on NET_ETHERNET && HAS_IOMEM
-	select PHYLIB
-	help
-	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
-	  Say Y to include support for the DNET chip.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called dnet.
-
 source "drivers/net/tulip/Kconfig"
 
 config AT1700
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 1265d0e..0379639 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -261,7 +261,6 @@ obj-$(CONFIG_GRETH) += greth.o
 
 obj-$(CONFIG_XTENSA_XT2000_SONIC) += xtsonic.o
 
-obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
 obj-$(CONFIG_S6GMAC) += s6gmac.o
 
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
index a5c62bc..e4fa897 100644
--- a/drivers/net/ethernet/Kconfig.10-100
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -2,6 +2,17 @@
 # 10 Mb and 100Mb ethernet device configuration
 #
 
+config DNET
+	tristate "Dave ethernet support (DNET)"
+	depends on NET_ETHERNET && HAS_IOMEM
+	select PHYLIB
+	help
+	  The Dave ethernet interface (DNET) is found on Qong Board FPGA.
+	  Say Y to include support for the DNET chip.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called dnet.
+
 config ETHOC
 	tristate "OpenCores 10/100 Mbps Ethernet MAC support"
 	depends on NET_ETHERNET && HAS_IOMEM && HAS_DMA
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index ad2afc1..6e419ed 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -2,4 +2,5 @@
 # Makefile for ethernet device drivers
 #
 
+obj-$(CONFIG_DNET)		+= dnet.o
 obj-$(CONFIG_ETHOC)		+= ethoc.o
diff --git a/drivers/net/dnet.c b/drivers/net/ethernet/dnet.c
similarity index 100%
rename from drivers/net/dnet.c
rename to drivers/net/ethernet/dnet.c
diff --git a/drivers/net/dnet.h b/drivers/net/ethernet/dnet.h
similarity index 100%
rename from drivers/net/dnet.h
rename to drivers/net/ethernet/dnet.h
-- 
1.7.3.3.398.g0b0cd.dirty

