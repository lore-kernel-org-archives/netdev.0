From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 05/72] broadcom: Move the Broadcom drivers
Date: Sat, 25 Jun 2011 06:58:16 -0700
Message-ID: <1309010363-22750-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	Gary Zambrano <zambrano@broadcom.com>,
	"Maciej W. Rozycki" <macro@linux-mips.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:46933 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751899Ab1FYN7c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:32 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the drivers for Broadcom devices into
drivers/net/ethernet/broadcom/ and the necessary Kconfig and Makefile
changes.

CC: Eilon Greenstein <eilong@broadcom.com>
CC: Michael Chan <mchan@broadcom.com>
CC: Matt Carlson <mcarlson@broadcom.com>
CC: Gary Zambrano <zambrano@broadcom.com>
CC: "Maciej W. Rozycki" <macro@linux-mips.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |   10 +-
 drivers/net/Kconfig                                |   99 -----------------
 drivers/net/Makefile                               |    7 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/broadcom/Kconfig              |  114 ++++++++++++++++++++
 drivers/net/ethernet/broadcom/Makefile             |   11 ++
 drivers/net/{ => ethernet/broadcom}/b44.c          |    0
 drivers/net/{ => ethernet/broadcom}/b44.h          |    0
 drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.c |    0
 drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.h |    0
 drivers/net/{ => ethernet/broadcom}/bnx2.c         |    0
 drivers/net/{ => ethernet/broadcom}/bnx2.h         |    0
 drivers/net/{ => ethernet/broadcom}/bnx2_fw.h      |    0
 drivers/net/{ => ethernet/broadcom}/bnx2x/Makefile |    0
 drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.c  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.c  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_dump.h |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_ethtool.c  |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h  |    0
 .../broadcom}/bnx2x/bnx2x_fw_file_hdr.h            |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_hsi.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_init.h |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_init_ops.h |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.c |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.h |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_main.c |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_reg.h  |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.c   |    0
 .../net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.h   |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_stats.c    |    0
 .../{ => ethernet/broadcom}/bnx2x/bnx2x_stats.h    |    0
 drivers/net/{ => ethernet/broadcom}/cnic.c         |    4 +-
 drivers/net/{ => ethernet/broadcom}/cnic.h         |    0
 drivers/net/{ => ethernet/broadcom}/cnic_defs.h    |    0
 drivers/net/{ => ethernet/broadcom}/cnic_if.h      |    0
 drivers/net/{ => ethernet/broadcom}/sb1250-mac.c   |    0
 drivers/net/{ => ethernet/broadcom}/tg3.c          |    0
 drivers/net/{ => ethernet/broadcom}/tg3.h          |    0
 drivers/scsi/bnx2fc/bnx2fc.h                       |    2 +-
 drivers/scsi/bnx2i/bnx2i.h                         |    2 +-
 44 files changed, 136 insertions(+), 115 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/Kconfig
 create mode 100644 drivers/net/ethernet/broadcom/Makefile
 rename drivers/net/{ => ethernet/broadcom}/b44.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/b44.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bcm63xx_enet.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2_fw.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/Makefile (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_cmn.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dcb.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_dump.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_ethtool.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_fw_defs.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_fw_file_hdr.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_hsi.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_init.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_init_ops.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_link.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_main.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_reg.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_sp.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_stats.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/bnx2x/bnx2x_stats.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic.c (99%)
 rename drivers/net/{ => ethernet/broadcom}/cnic.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic_defs.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/cnic_if.h (100%)
 rename drivers/net/{ => ethernet/broadcom}/sb1250-mac.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/tg3.c (100%)
 rename drivers/net/{ => ethernet/broadcom}/tg3.h (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 87e8a415..50696f8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1507,27 +1507,27 @@ BROADCOM B44 10/100 ETHERNET DRIVER
 M:	Gary Zambrano <zambrano@broadcom.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/b44.*
+F:	drivers/net/ethernet/broadcom/b44.*
 
 BROADCOM BNX2 GIGABIT ETHERNET DRIVER
 M:	Michael Chan <mchan@broadcom.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/bnx2.*
-F:	drivers/net/bnx2_*
+F:	drivers/net/ethernet/broadcom/bnx2.*
+F:	drivers/net/ethernet/broadcom/bnx2_*
 
 BROADCOM BNX2X 10 GIGABIT ETHERNET DRIVER
 M:	Eilon Greenstein <eilong@broadcom.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/bnx2x/
+F:	drivers/net/ethernet/broadcom/bnx2x/
 
 BROADCOM TG3 GIGABIT ETHERNET DRIVER
 M:	Matt Carlson <mcarlson@broadcom.com>
 M:	Michael Chan <mchan@broadcom.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/tg3.*
+F:	drivers/net/ethernet/broadcom/tg3.*
 
 BROADCOM BRCM80211 IEEE802.11n WIRELESS DRIVER
 M:	Brett Rudley <brudley@broadcom.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 7ed3025..2fbda69 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -994,38 +994,6 @@ config APRICOT
 	  To compile this driver as a module, choose M here. The module
 	  will be called apricot.
 
-config B44
-	tristate "Broadcom 440x/47xx ethernet support"
-	depends on SSB_POSSIBLE && HAS_DMA
-	select SSB
-	select MII
-	help
-	  If you have a network (Ethernet) controller of this type, say Y
-	  or M and read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called b44.
-
-# Auto-select SSB PCI-HOST support, if possible
-config B44_PCI_AUTOSELECT
-	bool
-	depends on B44 && SSB_PCIHOST_POSSIBLE
-	select SSB_PCIHOST
-	default y
-
-# Auto-select SSB PCICORE driver, if possible
-config B44_PCICORE_AUTOSELECT
-	bool
-	depends on B44 && SSB_DRIVER_PCICORE_POSSIBLE
-	select SSB_DRIVER_PCICORE
-	default y
-
-config B44_PCI
-	bool
-	depends on B44_PCI_AUTOSELECT && B44_PCICORE_AUTOSELECT
-	default y
-
 config FORCEDETH
 	tristate "nForce Ethernet support"
 	depends on NET_PCI && PCI
@@ -1469,15 +1437,6 @@ config XILINX_EMACLITE
 	help
 	  This driver supports the 10/100 Ethernet Lite from Xilinx.
 
-config BCM63XX_ENET
-	tristate "Broadcom 63xx internal mac support"
-	depends on BCM63XX
-	select MII
-	select PHYLIB
-	help
-	  This driver supports the ethernet MACs in the Broadcom 63xx
-	  MIPS chipset family (BCM63XX).
-
 config FTMAC100
 	tristate "Faraday FTMAC100 10/100 Ethernet support"
 	depends on ARM
@@ -1687,19 +1646,6 @@ config R8169
 	  To compile this driver as a module, choose M here: the module
 	  will be called r8169.  This is recommended.
 
-config SB1250_MAC
-	tristate "SB1250 Gigabit Ethernet support"
-	depends on SIBYTE_SB1xxx_SOC
-	select PHYLIB
-	---help---
-	  This driver supports Gigabit Ethernet interfaces based on the
-	  Broadcom SiByte family of System-On-a-Chip parts.  They include
-	  the BCM1120, BCM1125, BCM1125H, BCM1250, BCM1255, BCM1280, BCM1455
-	  and BCM1480 chips.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called sb1250-mac.
-
 config SIS190
 	tristate "SiS190/SiS191 gigabit ethernet support"
 	depends on PCI
@@ -1784,39 +1730,6 @@ config VIA_VELOCITY
 	  To compile this driver as a module, choose M here. The module
 	  will be called via-velocity.
 
-config TIGON3
-	tristate "Broadcom Tigon3 support"
-	depends on PCI
-	select PHYLIB
-	help
-	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called tg3.  This is recommended.
-
-config BNX2
-	tristate "Broadcom NetXtremeII support"
-	depends on PCI
-	select CRC32
-	select FW_LOADER
-	help
-	  This driver supports Broadcom NetXtremeII gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called bnx2.  This is recommended.
-
-config CNIC
-	tristate "Broadcom CNIC support"
-	depends on PCI
-	select BNX2
-	select UIO
-	help
-	  This driver supports offload features of Broadcom NetXtremeII
-	  gigabit Ethernet cards.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called cnic.  This is recommended.
-
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
 	depends on PCI && (PPC_IBM_CELL_BLADE || PPC_CELLEB)
@@ -2322,18 +2235,6 @@ config TEHUTI
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
-config BNX2X
-	tristate "Broadcom NetXtremeII 10Gb support"
-	depends on PCI
-	select FW_LOADER
-	select ZLIB_INFLATE
-	select LIBCRC32C
-	select MDIO
-	help
-	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
-	  To compile this driver as a module, choose M here: the module
-	  will be called bnx2x.  This is recommended.
-
 config QLCNIC
 	tristate "QLOGIC QLCNIC 1/10Gb Converged Ethernet NIC Support"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 2ad4579..de205dc 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -77,10 +77,6 @@ obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
 obj-$(CONFIG_FEALNX) += fealnx.o
-obj-$(CONFIG_TIGON3) += tg3.o
-obj-$(CONFIG_BNX2) += bnx2.o
-obj-$(CONFIG_CNIC) += cnic.o
-obj-$(CONFIG_BNX2X) += bnx2x/
 spidernet-y += spider_net.o spider_net_ethtool.o
 obj-$(CONFIG_SPIDER_NET) += spidernet.o sungem_phy.o
 obj-$(CONFIG_GELIC_NET) += ps3_gelic.o
@@ -118,10 +114,7 @@ ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
 	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
 endif
 obj-$(CONFIG_68360_ENET) += 68360enet.o
-obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
-obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
-obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
 obj-$(CONFIG_FTGMAC100) += ftgmac100.o
 obj-$(CONFIG_FTMAC100) += ftmac100.o
 
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 56ed5ec..772fb49 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -14,5 +14,6 @@ if ETHERNET
 source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
+source "drivers/net/ethernet/broadcom/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index fc82588..3ef49a2 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
+obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
new file mode 100644
index 0000000..55fd2cf
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -0,0 +1,114 @@
+#
+# Broadcom device configuration
+#
+
+config NET_VENDOR_BROADCOM
+	bool "Broadcom devices"
+	depends on (SSB_POSSIBLE && HAS_DMA) || PCI || BCM63XX || SIBYTE_SB1xxx_SOC
+	---help---
+	  If you have a network (Ethernet) chipset belonging to this class,
+	  say Y.
+
+	  Note that the answer to this question does not directly affect
+	  the kernel: saying N will just case the configurator to skip all
+	  the questions regarding AMD chipsets. If you say Y, you will be asked
+	  for your specific chipset/driver in the following questions.
+
+config B44
+	tristate "Broadcom 440x/47xx ethernet support"
+	depends on NET_VENDOR_BROADCOM && SSB_POSSIBLE && HAS_DMA
+	select SSB
+	select MII
+	---help---
+	  If you have a network (Ethernet) controller of this type, say Y
+	  or M and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called b44.
+
+# Auto-select SSB PCI-HOST support, if possible
+config B44_PCI_AUTOSELECT
+	bool
+	depends on B44 && SSB_PCIHOST_POSSIBLE
+	select SSB_PCIHOST
+	default y
+
+# Auto-select SSB PCICORE driver, if possible
+config B44_PCICORE_AUTOSELECT
+	bool
+	depends on B44 && SSB_DRIVER_PCICORE_POSSIBLE
+	select SSB_DRIVER_PCICORE
+	default y
+
+config B44_PCI
+	bool
+	depends on B44_PCI_AUTOSELECT && B44_PCICORE_AUTOSELECT
+	default y
+
+config BCM63XX_ENET
+	tristate "Broadcom 63xx internal mac support"
+	depends on NET_VENDOR_BROADCOM && BCM63XX
+	select MII
+	select PHYLIB
+	help
+	  This driver supports the ethernet MACs in the Broadcom 63xx
+	  MIPS chipset family (BCM63XX).
+
+config BNX2
+	tristate "Broadcom NetXtremeII support"
+	depends on NET_VENDOR_BROADCOM && PCI
+	select CRC32
+	select FW_LOADER
+	---help---
+	  This driver supports Broadcom NetXtremeII gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called bnx2.  This is recommended.
+
+config CNIC
+	tristate "Broadcom CNIC support"
+	depends on NET_VENDOR_BROADCOM && PCI
+	select BNX2
+	select UIO
+	---help---
+	  This driver supports offload features of Broadcom NetXtremeII
+	  gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called cnic.  This is recommended.
+
+config SB1250_MAC
+	tristate "SB1250 Gigabit Ethernet support"
+	depends on NET_VENDOR_BROADCOM && SIBYTE_SB1xxx_SOC
+	select PHYLIB
+	---help---
+	  This driver supports Gigabit Ethernet interfaces based on the
+	  Broadcom SiByte family of System-On-a-Chip parts.  They include
+	  the BCM1120, BCM1125, BCM1125H, BCM1250, BCM1255, BCM1280, BCM1455
+	  and BCM1480 chips.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called sb1250-mac.
+
+config TIGON3
+	tristate "Broadcom Tigon3 support"
+	depends on NET_VENDOR_BROADCOM && PCI
+	select PHYLIB
+	---help---
+	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called tg3.  This is recommended.
+
+config BNX2X
+	tristate "Broadcom NetXtremeII 10Gb support"
+	depends on NET_VENDOR_BROADCOM && PCI
+	select FW_LOADER
+	select ZLIB_INFLATE
+	select LIBCRC32C
+	select MDIO
+	---help---
+	  This driver supports Broadcom NetXtremeII 10 gigabit Ethernet cards.
+	  To compile this driver as a module, choose M here: the module
+	  will be called bnx2x.  This is recommended.
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ethernet/broadcom/Makefile
new file mode 100644
index 0000000..b789605
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -0,0 +1,11 @@
+#
+# Makefile for the Broadcom network device drivers.
+#
+
+obj-$(CONFIG_B44) += b44.o
+obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
+obj-$(CONFIG_BNX2) += bnx2.o
+obj-$(CONFIG_CNIC) += cnic.o
+obj-$(CONFIG_BNX2X) += bnx2x/
+obj-$(CONFIG_SB1250_MAC) += sb1250-mac.o
+obj-$(CONFIG_TIGON3) += tg3.o
diff --git a/drivers/net/b44.c b/drivers/net/ethernet/broadcom/b44.c
similarity index 100%
rename from drivers/net/b44.c
rename to drivers/net/ethernet/broadcom/b44.c
diff --git a/drivers/net/b44.h b/drivers/net/ethernet/broadcom/b44.h
similarity index 100%
rename from drivers/net/b44.h
rename to drivers/net/ethernet/broadcom/b44.h
diff --git a/drivers/net/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
similarity index 100%
rename from drivers/net/bcm63xx_enet.c
rename to drivers/net/ethernet/broadcom/bcm63xx_enet.c
diff --git a/drivers/net/bcm63xx_enet.h b/drivers/net/ethernet/broadcom/bcm63xx_enet.h
similarity index 100%
rename from drivers/net/bcm63xx_enet.h
rename to drivers/net/ethernet/broadcom/bcm63xx_enet.h
diff --git a/drivers/net/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
similarity index 100%
rename from drivers/net/bnx2.c
rename to drivers/net/ethernet/broadcom/bnx2.c
diff --git a/drivers/net/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
similarity index 100%
rename from drivers/net/bnx2.h
rename to drivers/net/ethernet/broadcom/bnx2.h
diff --git a/drivers/net/bnx2_fw.h b/drivers/net/ethernet/broadcom/bnx2_fw.h
similarity index 100%
rename from drivers/net/bnx2_fw.h
rename to drivers/net/ethernet/broadcom/bnx2_fw.h
diff --git a/drivers/net/bnx2x/Makefile b/drivers/net/ethernet/broadcom/bnx2x/Makefile
similarity index 100%
rename from drivers/net/bnx2x/Makefile
rename to drivers/net/ethernet/broadcom/bnx2x/Makefile
diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_cmn.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_cmn.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
diff --git a/drivers/net/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_dcb.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
diff --git a/drivers/net/bnx2x/bnx2x_dcb.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_dcb.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.h
diff --git a/drivers/net/bnx2x/bnx2x_dump.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_dump.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_dump.h
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_ethtool.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
diff --git a/drivers/net/bnx2x/bnx2x_fw_defs.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_fw_defs.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_defs.h
diff --git a/drivers/net/bnx2x/bnx2x_fw_file_hdr.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_fw_file_hdr.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_fw_file_hdr.h
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_hsi.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
diff --git a/drivers/net/bnx2x/bnx2x_init.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_init.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_init.h
diff --git a/drivers/net/bnx2x/bnx2x_init_ops.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_init_ops.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_init_ops.h
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_link.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_link.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_main.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_reg.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
diff --git a/drivers/net/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_sp.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
diff --git a/drivers/net/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_sp.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_stats.c
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
diff --git a/drivers/net/bnx2x/bnx2x_stats.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
similarity index 100%
rename from drivers/net/bnx2x/bnx2x_stats.h
rename to drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
diff --git a/drivers/net/cnic.c b/drivers/net/ethernet/broadcom/cnic.c
similarity index 99%
rename from drivers/net/cnic.c
rename to drivers/net/ethernet/broadcom/cnic.c
index 5533b15..81c2b82 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/ethernet/broadcom/cnic.c
@@ -44,8 +44,8 @@
 #include "bnx2x/bnx2x_reg.h"
 #include "bnx2x/bnx2x_fw_defs.h"
 #include "bnx2x/bnx2x_hsi.h"
-#include "../scsi/bnx2i/57xx_iscsi_constants.h"
-#include "../scsi/bnx2i/57xx_iscsi_hsi.h"
+#include "../../../scsi/bnx2i/57xx_iscsi_constants.h"
+#include "../../../scsi/bnx2i/57xx_iscsi_hsi.h"
 #include "cnic.h"
 #include "cnic_defs.h"
 
diff --git a/drivers/net/cnic.h b/drivers/net/ethernet/broadcom/cnic.h
similarity index 100%
rename from drivers/net/cnic.h
rename to drivers/net/ethernet/broadcom/cnic.h
diff --git a/drivers/net/cnic_defs.h b/drivers/net/ethernet/broadcom/cnic_defs.h
similarity index 100%
rename from drivers/net/cnic_defs.h
rename to drivers/net/ethernet/broadcom/cnic_defs.h
diff --git a/drivers/net/cnic_if.h b/drivers/net/ethernet/broadcom/cnic_if.h
similarity index 100%
rename from drivers/net/cnic_if.h
rename to drivers/net/ethernet/broadcom/cnic_if.h
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/ethernet/broadcom/sb1250-mac.c
similarity index 100%
rename from drivers/net/sb1250-mac.c
rename to drivers/net/ethernet/broadcom/sb1250-mac.c
diff --git a/drivers/net/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
similarity index 100%
rename from drivers/net/tg3.c
rename to drivers/net/ethernet/broadcom/tg3.c
diff --git a/drivers/net/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
similarity index 100%
rename from drivers/net/tg3.h
rename to drivers/net/ethernet/broadcom/tg3.h
diff --git a/drivers/scsi/bnx2fc/bnx2fc.h b/drivers/scsi/bnx2fc/bnx2fc.h
index 907672e..6f297bc 100644
--- a/drivers/scsi/bnx2fc/bnx2fc.h
+++ b/drivers/scsi/bnx2fc/bnx2fc.h
@@ -58,7 +58,7 @@
 
 #include "57xx_hsi_bnx2fc.h"
 #include "bnx2fc_debug.h"
-#include "../../net/cnic_if.h"
+#include "../../net/ethernet/broadcom/cnic_if.h"
 #include "bnx2fc_constants.h"
 
 #define BNX2FC_NAME		"bnx2fc"
diff --git a/drivers/scsi/bnx2i/bnx2i.h b/drivers/scsi/bnx2i/bnx2i.h
index e7cb7ec..9f680ab5 100644
--- a/drivers/scsi/bnx2i/bnx2i.h
+++ b/drivers/scsi/bnx2i/bnx2i.h
@@ -37,7 +37,7 @@
 #include <scsi/libiscsi.h>
 #include <scsi/scsi_transport_iscsi.h>
 
-#include "../../net/cnic_if.h"
+#include "../../net/ethernet/broadcom/cnic_if.h"
 #include "57xx_iscsi_hsi.h"
 #include "57xx_iscsi_constants.h"
 
-- 
1.7.5.4

