From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 4/6] ethernet: Move Sun Happymeal sunhme.[ch]
Date: Sun, 12 Dec 2010 04:03:25 -0800
Message-ID: <d95e2675d60e5df1052911deec264cb56824767a.1292154142.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2519 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825Ab0LLMDl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:41 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move Sun Happymeal files to ethernet directory.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                 |   13 -------------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig.10-100 |   13 +++++++++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/sunhme.c |    0
 drivers/net/{ => ethernet}/sunhme.h |    0
 6 files changed, 14 insertions(+), 14 deletions(-)
 rename drivers/net/{ => ethernet}/sunhme.c (100%)
 rename drivers/net/{ => ethernet}/sunhme.h (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c0716d9..926f090 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -558,19 +558,6 @@ config SUNLANCE
 	  To compile this driver as a module, choose M here: the module
 	  will be called sunlance.
 
-config HAPPYMEAL
-	tristate "Sun Happy Meal 10/100baseT support"
-	depends on SBUS || PCI
-	select CRC32
-	help
-	  This driver supports the "hme" interface present on most Ultra
-	  systems and as an option on older Sbus systems. This driver supports
-	  both PCI and Sbus devices. This driver also supports the "qfe" quad
-	  100baseT device available in both PCI and Sbus configurations.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sunhme.
-
 config SUNBMAC
 	tristate "Sun BigMAC 10/100baseT support (EXPERIMENTAL)"
 	depends on SBUS && EXPERIMENTAL
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0379639..8f2c0ee 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -56,7 +56,6 @@ obj-$(CONFIG_PLIP) += plip.o
 
 obj-$(CONFIG_ROADRUNNER) += rrunner.o
 
-obj-$(CONFIG_HAPPYMEAL) += sunhme.o
 obj-$(CONFIG_SUNLANCE) += sunlance.o
 obj-$(CONFIG_SUNQE) += sunqe.o
 obj-$(CONFIG_SUNBMAC) += sunbmac.o
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
index e4fa897..dbb95d3 100644
--- a/drivers/net/ethernet/Kconfig.10-100
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -22,3 +22,16 @@ config ETHOC
 	select BITREVERSE
 	help
 	  Say Y here if you want to use the OpenCores 10/100 Mbps Ethernet MAC.
+
+config HAPPYMEAL
+	tristate "Sun Happy Meal 10/100baseT support"
+	depends on SBUS || PCI
+	select CRC32
+	help
+	  This driver supports the "hme" interface present on most Ultra
+	  systems and as an option on older Sbus systems. This driver supports
+	  both PCI and Sbus devices. This driver also supports the "qfe" quad
+	  100baseT device available in both PCI and Sbus configurations.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sunhme.
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6e419ed..0daa85c 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -4,3 +4,4 @@
 
 obj-$(CONFIG_DNET)		+= dnet.o
 obj-$(CONFIG_ETHOC)		+= ethoc.o
+obj-$(CONFIG_HAPPYMEAL)		+= sunhme.o
diff --git a/drivers/net/sunhme.c b/drivers/net/ethernet/sunhme.c
similarity index 100%
rename from drivers/net/sunhme.c
rename to drivers/net/ethernet/sunhme.c
diff --git a/drivers/net/sunhme.h b/drivers/net/ethernet/sunhme.h
similarity index 100%
rename from drivers/net/sunhme.h
rename to drivers/net/ethernet/sunhme.h
-- 
1.7.3.3.398.g0b0cd.dirty

