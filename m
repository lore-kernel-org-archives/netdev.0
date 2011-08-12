From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] s6gmac: Move the s6gmac drivers
Date: Fri, 12 Aug 2011 03:52:46 -0700
Message-ID: <1313146371-6562-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Oskar Schirmer <os@emlix.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54616 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab1HLKw5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 06:52:57 -0400
In-Reply-To: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the s6gmac driver to drivers/net/ethernet/ and
make the necessary Kconfig and Makefile changes.

CC: Oskar Schirmer <os@emlix.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                 |   11 -----------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |   12 ++++++++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/s6gmac.c |    0
 5 files changed, 13 insertions(+), 12 deletions(-)
 rename drivers/net/{ => ethernet}/s6gmac.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a96cf18..134c3a4 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -643,17 +643,6 @@ config JME
 	  To compile this driver as a module, choose M here. The module
 	  will be called jme.
 
-config S6GMAC
-	tristate "S6105 GMAC ethernet support"
-	depends on XTENSA_VARIANT_S6000
-	select PHYLIB
-	help
-	  This driver supports the on chip ethernet device on the
-	  S6105 xtensa processor.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called s6gmac.
-
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d7ac2f8..938484f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -83,7 +83,6 @@ obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
-obj-$(CONFIG_S6GMAC) += s6gmac.o
 
 obj-$(CONFIG_ARM) += arm/
 obj-$(CONFIG_DEV_APPLETALK) += appletalk/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 8f404ea..f53a4bc 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -43,6 +43,18 @@ source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
+
+config S6GMAC
+	tristate "S6105 GMAC ethernet support"
+	depends on XTENSA_VARIANT_S6000
+	select PHYLIB
+	---help---
+	  This driver supports the on chip ethernet device on the
+	  S6105 xtensa processor.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called s6gmac.
+
 source "drivers/net/ethernet/seeq/Kconfig"
 source "drivers/net/ethernet/sis/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 6cf7f99..4491d84 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -34,6 +34,7 @@ obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
+obj-$(CONFIG_S6GMAC) += s6gmac.o
 obj-$(CONFIG_NET_VENDOR_SEEQ) += seeq/
 obj-$(CONFIG_NET_VENDOR_SIS) += sis/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/s6gmac.c b/drivers/net/ethernet/s6gmac.c
similarity index 100%
rename from drivers/net/s6gmac.c
rename to drivers/net/ethernet/s6gmac.c
-- 
1.7.6

