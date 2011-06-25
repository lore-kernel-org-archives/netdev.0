From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 21/72] tehuti: Move the Tehuti driver
Date: Sat, 25 Jun 2011 06:58:32 -0700
Message-ID: <1309010363-22750-22-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Alexander Indenbaum <baum@tehutinetworks.net>,
	Andy Gospodarek <andy@greyhouse.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:13697 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751933Ab1FYOAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:13 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Tehuti driver into drivers/net/ethernet/ and make the
necessary Kconfig and Makefile changes.

CC: Alexander Indenbaum <baum@tehutinetworks.net>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                         |    2 +-
 drivers/net/Kconfig                 |    6 ------
 drivers/net/Makefile                |    1 -
 drivers/net/ethernet/Kconfig        |    6 ++++++
 drivers/net/ethernet/Makefile       |    1 +
 drivers/net/{ => ethernet}/tehuti.c |    0
 drivers/net/{ => ethernet}/tehuti.h |    0
 7 files changed, 8 insertions(+), 8 deletions(-)
 rename drivers/net/{ => ethernet}/tehuti.c (100%)
 rename drivers/net/{ => ethernet}/tehuti.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 65f1282..015e658 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6129,7 +6129,7 @@ M:	Alexander Indenbaum <baum@tehutinetworks.net>
 M:	Andy Gospodarek <andy@greyhouse.net>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/tehuti*
+F:	drivers/net/ethernet/tehuti*
 
 Telecom Clock Driver for MCPL0010
 M:	Mark Gross <mark.gross@intel.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index de6ff15..1e157e7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1625,12 +1625,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config TEHUTI
-	tristate "Tehuti Networks 10G Ethernet"
-	depends on PCI
-	help
-	  Tehuti Networks 10G Ethernet NIC
-
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index a7bbf98..2c90508 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,7 +19,6 @@ obj-$(CONFIG_ATL1E) += atl1e/
 obj-$(CONFIG_ATL1C) += atl1c/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
 obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
-obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 3174234..74573fa 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -40,4 +40,10 @@ source "drivers/net/ethernet/sfc/Kconfig"
 source "drivers/net/ethernet/smc/Kconfig"
 source "drivers/net/ethernet/sun/Kconfig"
 
+config TEHUTI
+	tristate "Tehuti Networks 10G Ethernet"
+	depends on PCI
+	---help---
+	  Tehuti Networks 10G Ethernet NIC
+
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index a7eee02..d98ae32 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -21,3 +21,4 @@ obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
 obj-$(CONFIG_NET_VENDOR_SMC) += smc/
 obj-$(CONFIG_NET_VENDOR_SUN) += sun/
+obj-$(CONFIG_TEHUTI) += tehuti.o
diff --git a/drivers/net/tehuti.c b/drivers/net/ethernet/tehuti.c
similarity index 100%
rename from drivers/net/tehuti.c
rename to drivers/net/ethernet/tehuti.c
diff --git a/drivers/net/tehuti.h b/drivers/net/ethernet/tehuti.h
similarity index 100%
rename from drivers/net/tehuti.h
rename to drivers/net/ethernet/tehuti.h
-- 
1.7.5.4

