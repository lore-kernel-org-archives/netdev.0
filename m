From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 54/71] lantiq: Move the Lantiq SoC driver
Date: Sat, 30 Jul 2011 20:27:13 -0700
Message-ID: <1312082850-24914-55-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	John Crispin <blogic@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39387 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753385Ab1GaD2f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:28:35 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Lantiq driver into drivers/net/ethernet/ and the
necessary Kconfig and Makefile changes.

CC: John Crispin <blogic@openwrt.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                      |    6 ------
 drivers/net/Makefile                     |    1 -
 drivers/net/ethernet/Kconfig             |    6 ++++++
 drivers/net/ethernet/Makefile            |    1 +
 drivers/net/{ => ethernet}/lantiq_etop.c |    0
 5 files changed, 7 insertions(+), 7 deletions(-)
 rename drivers/net/{ => ethernet}/lantiq_etop.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index beee9a2..61e71d0 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -478,12 +478,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config LANTIQ_ETOP
-	tristate "Lantiq SoC ETOP driver"
-	depends on SOC_TYPE_XWAY
-	help
-	  Support for the MII0 inside the Lantiq SoC
-
 endif # NET_ETHERNET
 
 #
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 389c268..8e6dbd7 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -62,7 +62,6 @@ obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
-obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 
 obj-$(CONFIG_DNET) += dnet.o
 obj-$(CONFIG_MACB) += macb.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index f1509a5..6b3b3dc 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -52,6 +52,12 @@ config KORINA
 	  If you have a Mikrotik RouterBoard 500 or IDT RC32434
 	  based system say Y. Otherwise say N.
 
+config LANTIQ_ETOP
+	tristate "Lantiq SoC ETOP driver"
+	depends on SOC_TYPE_XWAY
+	---help---
+	  Support for the MII0 inside the Lantiq SoC
+
 source "drivers/net/ethernet/marvell/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/micrel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 50fc50a..2a1cbce 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -26,6 +26,7 @@ obj-$(CONFIG_NET_VENDOR_XSCALE) += xscale/
 obj-$(CONFIG_IP1000) += icplus/
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_KORINA) += korina.o
+obj-$(CONFIG_LANTIQ_ETOP) += lantiq_etop.o
 obj-$(CONFIG_NET_VENDOR_MARVELL) += marvell/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_MICREL) += micrel/
diff --git a/drivers/net/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
similarity index 100%
rename from drivers/net/lantiq_etop.c
rename to drivers/net/ethernet/lantiq_etop.c
-- 
1.7.6

