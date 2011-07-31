From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 19/71] ehea/ibm*: Move the IBM drivers
Date: Sat, 30 Jul 2011 20:26:38 -0700
Message-ID: <1312082850-24914-20-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Christoph Raisch <raisch@de.ibm.com>,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	David Gibson <dwg@au1.ibm.com>, Kyle Lucke <klucke@us.ibm.com>,
	Michael Ellerman <michael@ellerman.id.au>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:2242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751Ab1GaD1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:51 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the IBM drivers into drivers/net/ethernet/ibm/ and make the
necessary Kconfig and Makefile changes.

- Renamed ibm_new_emac to emac
- Cleaned up Makefile and Kconfig options which referred to
  IBM_NEW_EMAC to IBM_EMAC

CC: Christoph Raisch <raisch@de.ibm.com>
CC: Alfred Arnold <alfred.arnold@lancom.de>
CC: Santiago Leon <santil@linux.vnet.ibm.com>
CC: Benjamin Herrenschmidt <benh@kernel.crashing.org>
CC: David Gibson <dwg@au1.ibm.com>
CC: Kyle Lucke <klucke@us.ibm.com>
CC: Michael Ellerman <michael@ellerman.id.au>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   41 --------------
 drivers/net/Makefile                               |    5 --
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/ibm/Kconfig                   |   58 ++++++++++++++++++++
 drivers/net/ethernet/ibm/Makefile                  |    9 +++
 drivers/net/{ => ethernet/ibm}/ehea/Makefile       |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea.h         |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h      |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h    |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c     |    0
 drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h     |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/Kconfig |   42 +++++++-------
 .../{ibm_newemac => ethernet/ibm/emac}/Makefile    |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/core.c  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/core.h  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/debug.c |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/debug.h |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/emac.h  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/mal.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/mal.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/phy.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/phy.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/rgmii.c |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/rgmii.h |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/tah.c   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/tah.h   |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/zmii.c  |    0
 .../net/{ibm_newemac => ethernet/ibm/emac}/zmii.h  |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmlana.h           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.c           |    0
 drivers/net/{ => ethernet/ibm}/ibmveth.h           |    0
 drivers/net/{ => ethernet/ibm}/iseries_veth.c      |    0
 38 files changed, 92 insertions(+), 69 deletions(-)
 create mode 100644 drivers/net/ethernet/ibm/Kconfig
 create mode 100644 drivers/net/ethernet/ibm/Makefile
 rename drivers/net/{ => ethernet/ibm}/ehea/Makefile (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_ethtool.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_hw.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_main.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_phyp.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ehea/ehea_qmr.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/Kconfig (61%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/Makefile (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/core.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/core.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/debug.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/debug.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/emac.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/mal.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/mal.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/phy.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/phy.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/rgmii.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/rgmii.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/tah.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/tah.h (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/zmii.c (100%)
 rename drivers/net/{ibm_newemac => ethernet/ibm/emac}/zmii.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmlana.h (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.c (100%)
 rename drivers/net/{ => ethernet/ibm}/ibmveth.h (100%)
 rename drivers/net/{ => ethernet/ibm}/iseries_veth.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index dc83dd9..900c8ff 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2452,7 +2452,7 @@ EHEA (IBM pSeries eHEA 10Gb ethernet adapter) DRIVER
 M:	Breno Leitao <leitao@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/ehea/
+F:	drivers/net/ethernet/ibm/ehea/
 
 EMBEDDED LINUX
 M:	Paul Gortmaker <paul.gortmaker@windriver.com>
@@ -3151,7 +3151,7 @@ IBM Power Virtual Ethernet Device Driver
 M:	Santiago Leon <santil@linux.vnet.ibm.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/ibmveth.*
+F:	drivers/net/ethernet/ibm/ibmveth.*
 
 IBM ServeRAID RAID DRIVER
 P:	Jack Hammer
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 3e216b3..f66b921 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -612,33 +612,6 @@ config SEEQ8005
 	  To compile this driver as a module, choose M here. The module
 	  will be called seeq8005.
 
-config IBMLANA
-	tristate "IBM LAN Adapter/A support"
-	depends on MCA
-	---help---
-	  This is a Micro Channel Ethernet adapter.  You need to set
-	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
-	  driver and as a module.
-
-	  To compile this driver as a module, choose M here. The only
-	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
-	  will both support 16K and 32K memory windows, however a 32K window
-	  gives a better security against packet losses.  Usage of multiple
-	  boards with this driver should be possible, but has not been tested
-	  up to now due to lack of hardware.
-
-config IBMVETH
-	tristate "IBM LAN Virtual Ethernet support"
-	depends on PPC_PSERIES
-	---help---
-	  This driver supports virtual ethernet adapters on newer IBM iSeries
-	  and pSeries systems.
-
-	  To compile this driver as a module, choose M here. The module will
-	  be called ibmveth.
-
-source "drivers/net/ibm_newemac/Kconfig"
-
 config NET_PCI
 	bool "EISA, VLB, PCI and on board controllers"
 	depends on ISA || EISA || PCI
@@ -1469,16 +1442,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config EHEA
-	tristate "eHEA Ethernet support"
-	depends on IBMEBUS && INET && SPARSEMEM
-	select INET_LRO
-	---help---
-	  This driver supports the IBM pSeries eHEA ethernet adapter.
-
-	  To compile the driver as a module, choose M here. The module
-	  will be called ehea.
-
 config ENIC
 	tristate "Cisco VIC Ethernet NIC Support"
 	depends on PCI && INET
@@ -1573,10 +1536,6 @@ config XEN_NETDEV_BACKEND
 	  compile this driver as a module, chose M here: the module
 	  will be called xen-netback.
 
-config ISERIES_VETH
-	tristate "iSeries Virtual Ethernet driver support"
-	depends on PPC_ISERIES
-
 config RIONET
 	tristate "RapidIO Ethernet over messaging driver support"
 	depends on RAPIDIO
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index d28c153e..60d821a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -10,9 +10,7 @@ obj-$(CONFIG_TI_DAVINCI_EMAC) += davinci_emac.o
 obj-$(CONFIG_TI_DAVINCI_MDIO) += davinci_mdio.o
 obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 
-obj-$(CONFIG_IBM_NEW_EMAC) += ibm_newemac/
 obj-$(CONFIG_IP1000) += ipg.o
-obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atlx/
@@ -50,7 +48,6 @@ obj-$(CONFIG_SIS190) += sis190.o
 obj-$(CONFIG_SIS900) += sis900.o
 obj-$(CONFIG_R6040) += r6040.o
 obj-$(CONFIG_YELLOWFIN) += yellowfin.o
-obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
 obj-$(CONFIG_NATSEMI) += natsemi.o
 obj-$(CONFIG_NS83820) += ns83820.o
 obj-$(CONFIG_FEALNX) += fealnx.o
@@ -125,7 +122,6 @@ obj-$(CONFIG_DEFXX) += defxx.o
 obj-$(CONFIG_SGISEEQ) += sgiseeq.o
 obj-$(CONFIG_SGI_O2MACE_ETH) += meth.o
 obj-$(CONFIG_AT1700) += at1700.o
-obj-$(CONFIG_IBMLANA) += ibmlana.o
 obj-$(CONFIG_8139CP) += 8139cp.o
 obj-$(CONFIG_8139TOO) += 8139too.o
 obj-$(CONFIG_CPMAC) += cpmac.o
@@ -148,7 +144,6 @@ obj-$(CONFIG_VETH) += veth.o
 obj-$(CONFIG_NET_NETX) += netx-eth.o
 obj-$(CONFIG_DL2K) += dl2k.o
 obj-$(CONFIG_R8169) += r8169.o
-obj-$(CONFIG_IBMVETH) += ibmveth.o
 obj-$(CONFIG_PXA168_ETH) += pxa168_eth.o
 obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 1a39ec0..f23f1b2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
+source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
 source "drivers/net/ethernet/i825xx/Kconfig"
 source "drivers/net/ethernet/mellanox/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 4c21e8f..27e4da6 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
+obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
 obj-$(CONFIG_NET_VENDOR_I825XX) += i825xx/
 obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
diff --git a/drivers/net/ethernet/ibm/Kconfig b/drivers/net/ethernet/ibm/Kconfig
new file mode 100644
index 0000000..3e3bd4c
--- /dev/null
+++ b/drivers/net/ethernet/ibm/Kconfig
@@ -0,0 +1,58 @@
+#
+# IBM device configuration.
+#
+
+config NET_VENDOR_IBM
+	bool "IBM devices"
+	depends on MCA || PPC_PSERIES || PPC_PSERIES || PPC_DCR || \
+		   (IBMEBUS && INET && SPARSEMEM)
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about IBM devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config IBMLANA
+	tristate "IBM LAN Adapter/A support"
+	depends on NET_VENDOR_IBM && MCA
+	---help---
+	  This is a Micro Channel Ethernet adapter.  You need to set
+	  CONFIG_MCA to use this driver.  It is both available as an in-kernel
+	  driver and as a module.
+
+	  To compile this driver as a module, choose M here. The only
+	  currently supported card is the IBM LAN Adapter/A for Ethernet.  It
+	  will both support 16K and 32K memory windows, however a 32K window
+	  gives a better security against packet losses.  Usage of multiple
+	  boards with this driver should be possible, but has not been tested
+	  up to now due to lack of hardware.
+
+config IBMVETH
+	tristate "IBM LAN Virtual Ethernet support"
+	depends on NET_VENDOR_IBM && PPC_PSERIES
+	---help---
+	  This driver supports virtual ethernet adapters on newer IBM iSeries
+	  and pSeries systems.
+
+	  To compile this driver as a module, choose M here. The module will
+	  be called ibmveth.
+
+config ISERIES_VETH
+	tristate "iSeries Virtual Ethernet driver support"
+	depends on NET_VENDOR_IBM && PPC_ISERIES
+
+source "drivers/net/ethernet/ibm/emac/Kconfig"
+
+config EHEA
+	tristate "eHEA Ethernet support"
+	depends on NET_VENDOR_IBM && IBMEBUS && INET && SPARSEMEM
+	select INET_LRO
+	---help---
+	  This driver supports the IBM pSeries eHEA ethernet adapter.
+
+	  To compile the driver as a module, choose M here. The module
+	  will be called ehea.
diff --git a/drivers/net/ethernet/ibm/Makefile b/drivers/net/ethernet/ibm/Makefile
new file mode 100644
index 0000000..7ee87d9
--- /dev/null
+++ b/drivers/net/ethernet/ibm/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for th IBM network device drivers.
+#
+
+obj-$(CONFIG_IBMLANA) += ibmlana.o
+obj-$(CONFIG_IBMVETH) += ibmveth.o
+obj-$(CONFIG_ISERIES_VETH) += iseries_veth.o
+obj-$(CONFIG_IBM_EMAC) += emac/
+obj-$(CONFIG_EHEA) += ehea/
diff --git a/drivers/net/ehea/Makefile b/drivers/net/ethernet/ibm/ehea/Makefile
similarity index 100%
rename from drivers/net/ehea/Makefile
rename to drivers/net/ethernet/ibm/ehea/Makefile
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
similarity index 100%
rename from drivers/net/ehea/ehea.h
rename to drivers/net/ethernet/ibm/ehea/ehea.h
diff --git a/drivers/net/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
similarity index 100%
rename from drivers/net/ehea/ehea_ethtool.c
rename to drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
diff --git a/drivers/net/ehea/ehea_hw.h b/drivers/net/ethernet/ibm/ehea/ehea_hw.h
similarity index 100%
rename from drivers/net/ehea/ehea_hw.h
rename to drivers/net/ethernet/ibm/ehea/ehea_hw.h
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
similarity index 100%
rename from drivers/net/ehea/ehea_main.c
rename to drivers/net/ethernet/ibm/ehea/ehea_main.c
diff --git a/drivers/net/ehea/ehea_phyp.c b/drivers/net/ethernet/ibm/ehea/ehea_phyp.c
similarity index 100%
rename from drivers/net/ehea/ehea_phyp.c
rename to drivers/net/ethernet/ibm/ehea/ehea_phyp.c
diff --git a/drivers/net/ehea/ehea_phyp.h b/drivers/net/ethernet/ibm/ehea/ehea_phyp.h
similarity index 100%
rename from drivers/net/ehea/ehea_phyp.h
rename to drivers/net/ethernet/ibm/ehea/ehea_phyp.h
diff --git a/drivers/net/ehea/ehea_qmr.c b/drivers/net/ethernet/ibm/ehea/ehea_qmr.c
similarity index 100%
rename from drivers/net/ehea/ehea_qmr.c
rename to drivers/net/ethernet/ibm/ehea/ehea_qmr.c
diff --git a/drivers/net/ehea/ehea_qmr.h b/drivers/net/ethernet/ibm/ehea/ehea_qmr.h
similarity index 100%
rename from drivers/net/ehea/ehea_qmr.h
rename to drivers/net/ethernet/ibm/ehea/ehea_qmr.h
diff --git a/drivers/net/ibm_newemac/Kconfig b/drivers/net/ethernet/ibm/emac/Kconfig
similarity index 61%
rename from drivers/net/ibm_newemac/Kconfig
rename to drivers/net/ethernet/ibm/emac/Kconfig
index 78a1628..3c0bf84 100644
--- a/drivers/net/ibm_newemac/Kconfig
+++ b/drivers/net/ethernet/ibm/emac/Kconfig
@@ -1,35 +1,35 @@
-config IBM_NEW_EMAC
+config IBM_EMAC
 	tristate "IBM EMAC Ethernet support"
-	depends on PPC_DCR
+	depends on NET_VENDOR_IBM && PPC_DCR
 	select CRC32
 	help
 	  This driver supports the IBM EMAC family of Ethernet controllers
 	  typically found on 4xx embedded PowerPC chips, but also on the
 	  Axon southbridge for Cell.
 
-config IBM_NEW_EMAC_RXB
+config IBM_EMAC_RXB
 	int "Number of receive buffers"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default "128"
 
-config IBM_NEW_EMAC_TXB
+config IBM_EMAC_TXB
 	int "Number of transmit buffers"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default "64"
 
-config IBM_NEW_EMAC_POLL_WEIGHT
+config IBM_EMAC_POLL_WEIGHT
 	int "MAL NAPI polling weight"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default "32"
 
-config IBM_NEW_EMAC_RX_COPY_THRESHOLD
+config IBM_EMAC_RX_COPY_THRESHOLD
 	int "RX skb copy threshold (bytes)"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default "256"
 
-config IBM_NEW_EMAC_RX_SKB_HEADROOM
+config IBM_EMAC_RX_SKB_HEADROOM
 	int "Additional RX skb headroom (bytes)"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default "0"
 	help
 	  Additional receive skb headroom. Note, that driver
@@ -39,38 +39,38 @@ config IBM_NEW_EMAC_RX_SKB_HEADROOM
 
 	  If unsure, set to 0.
 
-config IBM_NEW_EMAC_DEBUG
+config IBM_EMAC_DEBUG
 	bool "Debugging"
-	depends on IBM_NEW_EMAC
+	depends on IBM_EMAC
 	default n
 
 # The options below has to be select'ed by the respective
 # processor types or platforms
 
-config IBM_NEW_EMAC_ZMII
+config IBM_EMAC_ZMII
 	bool
 	default n
 
-config IBM_NEW_EMAC_RGMII
+config IBM_EMAC_RGMII
 	bool
 	default n
 
-config IBM_NEW_EMAC_TAH
+config IBM_EMAC_TAH
 	bool
 	default n
 
-config IBM_NEW_EMAC_EMAC4
+config IBM_EMAC_EMAC4
 	bool
 	default n
 
-config IBM_NEW_EMAC_NO_FLOW_CTRL
+config IBM_EMAC_NO_FLOW_CTRL
 	bool
 	default n
 
-config IBM_NEW_EMAC_MAL_CLR_ICINTSTAT
+config IBM_EMAC_MAL_CLR_ICINTSTAT
 	bool
 	default n
 
-config IBM_NEW_EMAC_MAL_COMMON_ERR
+config IBM_EMAC_MAL_COMMON_ERR
 	bool
 	default n
diff --git a/drivers/net/ibm_newemac/Makefile b/drivers/net/ethernet/ibm/emac/Makefile
similarity index 100%
rename from drivers/net/ibm_newemac/Makefile
rename to drivers/net/ethernet/ibm/emac/Makefile
diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ethernet/ibm/emac/core.c
similarity index 100%
rename from drivers/net/ibm_newemac/core.c
rename to drivers/net/ethernet/ibm/emac/core.c
diff --git a/drivers/net/ibm_newemac/core.h b/drivers/net/ethernet/ibm/emac/core.h
similarity index 100%
rename from drivers/net/ibm_newemac/core.h
rename to drivers/net/ethernet/ibm/emac/core.h
diff --git a/drivers/net/ibm_newemac/debug.c b/drivers/net/ethernet/ibm/emac/debug.c
similarity index 100%
rename from drivers/net/ibm_newemac/debug.c
rename to drivers/net/ethernet/ibm/emac/debug.c
diff --git a/drivers/net/ibm_newemac/debug.h b/drivers/net/ethernet/ibm/emac/debug.h
similarity index 100%
rename from drivers/net/ibm_newemac/debug.h
rename to drivers/net/ethernet/ibm/emac/debug.h
diff --git a/drivers/net/ibm_newemac/emac.h b/drivers/net/ethernet/ibm/emac/emac.h
similarity index 100%
rename from drivers/net/ibm_newemac/emac.h
rename to drivers/net/ethernet/ibm/emac/emac.h
diff --git a/drivers/net/ibm_newemac/mal.c b/drivers/net/ethernet/ibm/emac/mal.c
similarity index 100%
rename from drivers/net/ibm_newemac/mal.c
rename to drivers/net/ethernet/ibm/emac/mal.c
diff --git a/drivers/net/ibm_newemac/mal.h b/drivers/net/ethernet/ibm/emac/mal.h
similarity index 100%
rename from drivers/net/ibm_newemac/mal.h
rename to drivers/net/ethernet/ibm/emac/mal.h
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
similarity index 100%
rename from drivers/net/ibm_newemac/phy.c
rename to drivers/net/ethernet/ibm/emac/phy.c
diff --git a/drivers/net/ibm_newemac/phy.h b/drivers/net/ethernet/ibm/emac/phy.h
similarity index 100%
rename from drivers/net/ibm_newemac/phy.h
rename to drivers/net/ethernet/ibm/emac/phy.h
diff --git a/drivers/net/ibm_newemac/rgmii.c b/drivers/net/ethernet/ibm/emac/rgmii.c
similarity index 100%
rename from drivers/net/ibm_newemac/rgmii.c
rename to drivers/net/ethernet/ibm/emac/rgmii.c
diff --git a/drivers/net/ibm_newemac/rgmii.h b/drivers/net/ethernet/ibm/emac/rgmii.h
similarity index 100%
rename from drivers/net/ibm_newemac/rgmii.h
rename to drivers/net/ethernet/ibm/emac/rgmii.h
diff --git a/drivers/net/ibm_newemac/tah.c b/drivers/net/ethernet/ibm/emac/tah.c
similarity index 100%
rename from drivers/net/ibm_newemac/tah.c
rename to drivers/net/ethernet/ibm/emac/tah.c
diff --git a/drivers/net/ibm_newemac/tah.h b/drivers/net/ethernet/ibm/emac/tah.h
similarity index 100%
rename from drivers/net/ibm_newemac/tah.h
rename to drivers/net/ethernet/ibm/emac/tah.h
diff --git a/drivers/net/ibm_newemac/zmii.c b/drivers/net/ethernet/ibm/emac/zmii.c
similarity index 100%
rename from drivers/net/ibm_newemac/zmii.c
rename to drivers/net/ethernet/ibm/emac/zmii.c
diff --git a/drivers/net/ibm_newemac/zmii.h b/drivers/net/ethernet/ibm/emac/zmii.h
similarity index 100%
rename from drivers/net/ibm_newemac/zmii.h
rename to drivers/net/ethernet/ibm/emac/zmii.h
diff --git a/drivers/net/ibmlana.c b/drivers/net/ethernet/ibm/ibmlana.c
similarity index 100%
rename from drivers/net/ibmlana.c
rename to drivers/net/ethernet/ibm/ibmlana.c
diff --git a/drivers/net/ibmlana.h b/drivers/net/ethernet/ibm/ibmlana.h
similarity index 100%
rename from drivers/net/ibmlana.h
rename to drivers/net/ethernet/ibm/ibmlana.h
diff --git a/drivers/net/ibmveth.c b/drivers/net/ethernet/ibm/ibmveth.c
similarity index 100%
rename from drivers/net/ibmveth.c
rename to drivers/net/ethernet/ibm/ibmveth.c
diff --git a/drivers/net/ibmveth.h b/drivers/net/ethernet/ibm/ibmveth.h
similarity index 100%
rename from drivers/net/ibmveth.h
rename to drivers/net/ethernet/ibm/ibmveth.h
diff --git a/drivers/net/iseries_veth.c b/drivers/net/ethernet/ibm/iseries_veth.c
similarity index 100%
rename from drivers/net/iseries_veth.c
rename to drivers/net/ethernet/ibm/iseries_veth.c
-- 
1.7.6

