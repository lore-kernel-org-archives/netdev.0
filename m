From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/10] freescale: Move the Freescale drivers
Date: Fri, 12 Aug 2011 00:33:02 -0700
Message-ID: <1313134384-7287-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Sandeep Gopalpet <sandeep.kumar@freescale.com>,
	Andy Fleming <afleming@freescale.com>,
	Shlomi Gridish <gridish@freescale.com>,
	Li Yang <leoli@freescale.com>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>,
	Dan Malek <dmalek@jlc.net>, Sylvain Munaut <tnt@246tNt.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:58632 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750890Ab1HLHdN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2011 03:33:13 -0400
In-Reply-To: <1313134384-7287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the Freescale drivers into drivers/net/ethernet/freescale/ and
make the necessary Kconfig and Makefile changes.

CC: Sandeep Gopalpet <sandeep.kumar@freescale.com>
CC: Andy Fleming <afleming@freescale.com>
CC: Shlomi Gridish <gridish@freescale.com>
CC: Li Yang <leoli@freescale.com>
CC: Pantelis Antoniou <pantelis.antoniou@gmail.com>
CC: Vitaly Bordug <vbordug@ru.mvista.com>
CC: Dan Malek <dmalek@jlc.net>
CC: Sylvain Munaut <tnt@246tNt.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    4 +-
 drivers/net/Kconfig                                |   66 ---------------
 drivers/net/Makefile                               |   18 ----
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/freescale/Kconfig             |   88 ++++++++++++++++++++
 drivers/net/ethernet/freescale/Makefile            |   18 ++++
 drivers/net/{ => ethernet/freescale}/fec.c         |    0
 drivers/net/{ => ethernet/freescale}/fec.h         |    0
 drivers/net/{ => ethernet/freescale}/fec_mpc52xx.c |    0
 drivers/net/{ => ethernet/freescale}/fec_mpc52xx.h |    0
 .../net/{ => ethernet/freescale}/fec_mpc52xx_phy.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/Kconfig   |    2 +-
 .../net/{ => ethernet/freescale}/fs_enet/Makefile  |    0
 drivers/net/{ => ethernet/freescale}/fs_enet/fec.h |    0
 .../freescale}/fs_enet/fs_enet-main.c              |    0
 .../net/{ => ethernet/freescale}/fs_enet/fs_enet.h |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fcc.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-fec.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mac-scc.c |    0
 .../{ => ethernet/freescale}/fs_enet/mii-bitbang.c |    0
 .../net/{ => ethernet/freescale}/fs_enet/mii-fec.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c |    0
 drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h |    0
 drivers/net/{ => ethernet/freescale}/gianfar.c     |    0
 drivers/net/{ => ethernet/freescale}/gianfar.h     |    0
 .../net/{ => ethernet/freescale}/gianfar_ethtool.c |    0
 drivers/net/{ => ethernet/freescale}/gianfar_ptp.c |    0
 .../net/{ => ethernet/freescale}/gianfar_sysfs.c   |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.c    |    0
 drivers/net/{ => ethernet/freescale}/ucc_geth.h    |    0
 .../{ => ethernet/freescale}/ucc_geth_ethtool.c    |    0
 32 files changed, 111 insertions(+), 87 deletions(-)
 create mode 100644 drivers/net/ethernet/freescale/Kconfig
 create mode 100644 drivers/net/ethernet/freescale/Makefile
 rename drivers/net/{ => ethernet/freescale}/fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fec.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fec_mpc52xx_phy.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Kconfig (91%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/Makefile (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fec.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet-main.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/fs_enet.h (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fcc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mac-scc.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-bitbang.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fs_enet/mii-fec.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.c (100%)
 rename drivers/net/{ => ethernet/freescale}/fsl_pq_mdio.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar.h (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ethtool.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_ptp.c (100%)
 rename drivers/net/{ => ethernet/freescale}/gianfar_sysfs.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.c (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth.h (100%)
 rename drivers/net/{ => ethernet/freescale}/ucc_geth_ethtool.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5b2ad6c..77ca430 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2689,7 +2689,7 @@ M:	Vitaly Bordug <vbordug@ru.mvista.com>
 L:	linuxppc-dev@lists.ozlabs.org
 L:	netdev@vger.kernel.org
 S:	Maintained
-F:	drivers/net/fs_enet/
+F:	drivers/net/ethernet/freescale/fs_enet/
 F:	include/linux/fs_enet_pd.h
 
 FREESCALE QUICC ENGINE LIBRARY
@@ -2711,7 +2711,7 @@ M:	Li Yang <leoli@freescale.com>
 L:	netdev@vger.kernel.org
 L:	linuxppc-dev@lists.ozlabs.org
 S:	Maintained
-F:	drivers/net/ucc_geth*
+F:	drivers/net/ethernet/freescale/ucc_geth*
 
 FREESCALE QUICC ENGINE UCC UART DRIVER
 M:	Timur Tabi <timur@freescale.com>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 27f97b4e..b645a73 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -605,39 +605,6 @@ config NET_POCKET
 	  the questions about this class of network devices. If you say Y, you
 	  will be asked for your specific device in the following questions.
 
-config FEC
-	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
-	depends on M523x || M527x || M5272 || M528x || M520x || M532x || \
-		IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC
-	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
-	select PHYLIB
-	help
-	  Say Y here if you want to use the built-in 10/100 Fast ethernet
-	  controller on some Motorola ColdFire and Freescale i.MX processors.
-
-config FEC_MPC52xx
-	tristate "MPC52xx FEC driver"
-	depends on PPC_MPC52xx && PPC_BESTCOMM
-	select CRC32
-	select PHYLIB
-	select PPC_BESTCOMM_FEC
-	---help---
-	  This option enables support for the MPC5200's on-chip
-	  Fast Ethernet Controller
-	  If compiled as module, it will be called fec_mpc52xx.
-
-config FEC_MPC52xx_MDIO
-	bool "MPC52xx FEC MDIO bus driver"
-	depends on FEC_MPC52xx
-	default y
-	---help---
-	  The MPC5200's FEC can connect to the Ethernet either with
-	  an external MII PHY chip or 10 Mbps 7-wire interface
-	  (Motorola? industry standard).
-	  If your board uses an external PHY connected to FEC, enable this.
-	  If not sure, enable.
-	  If compiled as module, it will be called fec_mpc52xx_phy.
-
 config XILINX_EMACLITE
 	tristate "Xilinx 10/100 Ethernet Lite support"
 	depends on PPC32 || MICROBLAZE
@@ -651,9 +618,6 @@ config LANTIQ_ETOP
 	help
 	  Support for the MII0 inside the Lantiq SoC
 
-
-source "drivers/net/fs_enet/Kconfig"
-
 source "drivers/net/octeon/Kconfig"
 
 endif # NET_ETHERNET
@@ -769,36 +733,6 @@ config GELIC_WIRELESS
 	  the driver automatically distinguishes the models, you can
 	  safely enable this option even if you have a wireless-less model.
 
-config FSL_PQ_MDIO
-	tristate "Freescale PQ MDIO"
-	depends on FSL_SOC
-	select PHYLIB
-	help
-	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
-
-config GIANFAR
-	tristate "Gianfar Ethernet"
-	depends on FSL_SOC
-	select FSL_PQ_MDIO
-	select PHYLIB
-	select CRC32
-	help
-	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
-	  and MPC86xx family of chips, and the FEC on the 8540.
-
-config UCC_GETH
-	tristate "Freescale QE Gigabit Ethernet"
-	depends on QUICC_ENGINE
-	select FSL_PQ_MDIO
-	select PHYLIB
-	help
-	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
-	  which is available on some Freescale SOCs.
-
-config UGETH_TX_ON_DEMAND
-	bool "Transmit on Demand support"
-	depends on UCC_GETH
-
 config XILINX_LL_TEMAC
 	tristate "Xilinx LL TEMAC (LocalLink Tri-mode Ethernet MAC) driver"
 	depends on PPC || MICROBLAZE
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 07cad1a..39fe730 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -13,20 +13,9 @@ obj-$(CONFIG_TI_DAVINCI_CPDMA) += davinci_cpdma.o
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-obj-$(CONFIG_GIANFAR) += gianfar_driver.o
-obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
 
-gianfar_driver-objs := gianfar.o \
-		gianfar_ethtool.o \
-		gianfar_sysfs.o
-
-obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
-ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
-
-obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
-
 #
 # link order important here
 #
@@ -63,11 +52,6 @@ obj-$(CONFIG_HAMACHI) += hamachi.o
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
 obj-$(CONFIG_HP100) += hp100.o
-obj-$(CONFIG_FEC) += fec.o
-obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
-ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
-	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
-endif
 obj-$(CONFIG_FORCEDETH) += forcedeth.o
 
 obj-$(CONFIG_TSI108_ETH) += tsi108_eth.o
@@ -139,8 +123,6 @@ obj-$(CONFIG_ETRAX_ETHERNET) += cris/
 
 obj-$(CONFIG_NETCONSOLE) += netconsole.o
 
-obj-$(CONFIG_FS_ENET) += fs_enet/
-
 obj-$(CONFIG_VIRTIO_NET) += virtio_net.o
 
 obj-$(CONFIG_WIMAX) += wimax/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index d3aff74..924c287 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -24,6 +24,7 @@ source "drivers/net/ethernet/dlink/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/neterion/Kconfig"
 source "drivers/net/ethernet/faraday/Kconfig"
+source "drivers/net/ethernet/freescale/Kconfig"
 source "drivers/net/ethernet/fujitsu/Kconfig"
 source "drivers/net/ethernet/ibm/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index b098c5e..025d7b7 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -16,6 +16,7 @@ obj-$(CONFIG_NET_VENDOR_DLINK) += dlink/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_EXAR) += neterion/
 obj-$(CONFIG_NET_VENDOR_FARADAY) += faraday/
+obj-$(CONFIG_NET_VENDOR_FREESCALE) += freescale/
 obj-$(CONFIG_NET_VENDOR_FUJITSU) += fujitsu/
 obj-$(CONFIG_NET_VENDOR_IBM) += ibm/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
diff --git a/drivers/net/ethernet/freescale/Kconfig b/drivers/net/ethernet/freescale/Kconfig
new file mode 100644
index 0000000..2fd2c61
--- /dev/null
+++ b/drivers/net/ethernet/freescale/Kconfig
@@ -0,0 +1,88 @@
+#
+# Freescale device configuration
+#
+
+config NET_VENDOR_FREESCALE
+	bool "Freescale devices"
+	depends on FSL_SOC || QUICC_ENGINE || CPM1 || CPM2 || PPC_MPC512x || \
+		   M523x || M527x || M5272 || M528x || M520x || M532x || \
+		   IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC || \
+		   (PPC_MPC52xx && PPC_BESTCOMM)
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
+if NET_VENDOR_FREESCALE
+
+config FEC
+	bool "FEC ethernet controller (of ColdFire and some i.MX CPUs)"
+	depends on (M523x || M527x || M5272 || M528x || M520x || M532x || \
+		    IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC)
+	default IMX_HAVE_PLATFORM_FEC || MXS_HAVE_PLATFORM_FEC if ARM
+	select PHYLIB
+	---help---
+	  Say Y here if you want to use the built-in 10/100 Fast ethernet
+	  controller on some Motorola ColdFire and Freescale i.MX processors.
+
+config FEC_MPC52xx
+	tristate "FEC MPC52xx driver"
+	depends on PPC_MPC52xx && PPC_BESTCOMM
+	select CRC32
+	select PHYLIB
+	select PPC_BESTCOMM_FEC
+	---help---
+	  This option enables support for the MPC5200's on-chip
+	  Fast Ethernet Controller
+	  If compiled as module, it will be called fec_mpc52xx.
+
+config FEC_MPC52xx_MDIO
+	bool "FEC MPC52xx MDIO bus driver"
+	depends on FEC_MPC52xx
+	default y
+	---help---
+	  The MPC5200's FEC can connect to the Ethernet either with
+	  an external MII PHY chip or 10 Mbps 7-wire interface
+	  (Motorola? industry standard).
+	  If your board uses an external PHY connected to FEC, enable this.
+	  If not sure, enable.
+	  If compiled as module, it will be called fec_mpc52xx_phy.
+
+source "drivers/net/ethernet/freescale/fs_enet/Kconfig"
+
+config FSL_PQ_MDIO
+	tristate "Freescale PQ MDIO"
+	depends on FSL_SOC
+	select PHYLIB
+	---help---
+	  This driver supports the MDIO bus used by the gianfar and UCC drivers.
+
+config UCC_GETH
+	tristate "Freescale QE Gigabit Ethernet"
+	depends on QUICC_ENGINE
+	select FSL_PQ_MDIO
+	select PHYLIB
+	---help---
+	  This driver supports the Gigabit Ethernet mode of the QUICC Engine,
+	  which is available on some Freescale SOCs.
+
+config UGETH_TX_ON_DEMAND
+	bool "Transmit on Demand support"
+	depends on UCC_GETH
+
+config GIANFAR
+	tristate "Gianfar Ethernet"
+	depends on FSL_SOC
+	select FSL_PQ_MDIO
+	select PHYLIB
+	select CRC32
+	---help---
+	  This driver supports the Gigabit TSEC on the MPC83xx, MPC85xx,
+	  and MPC86xx family of chips, and the FEC on the 8540.
+
+endif # NET_VENDOR_FREESCALE
diff --git a/drivers/net/ethernet/freescale/Makefile b/drivers/net/ethernet/freescale/Makefile
new file mode 100644
index 0000000..1752488
--- /dev/null
+++ b/drivers/net/ethernet/freescale/Makefile
@@ -0,0 +1,18 @@
+#
+# Makefile for the Freescale network device drivers.
+#
+
+obj-$(CONFIG_FEC) += fec.o
+obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx.o
+ifeq ($(CONFIG_FEC_MPC52xx_MDIO),y)
+	obj-$(CONFIG_FEC_MPC52xx) += fec_mpc52xx_phy.o
+endif
+obj-$(CONFIG_FS_ENET) += fs_enet/
+obj-$(CONFIG_FSL_PQ_MDIO) += fsl_pq_mdio.o
+obj-$(CONFIG_GIANFAR) += gianfar_driver.o
+obj-$(CONFIG_PTP_1588_CLOCK_GIANFAR) += gianfar_ptp.o
+gianfar_driver-objs := gianfar.o \
+		gianfar_ethtool.o \
+		gianfar_sysfs.o
+obj-$(CONFIG_UCC_GETH) += ucc_geth_driver.o
+ucc_geth_driver-objs := ucc_geth.o ucc_geth_ethtool.o
diff --git a/drivers/net/fec.c b/drivers/net/ethernet/freescale/fec.c
similarity index 100%
rename from drivers/net/fec.c
rename to drivers/net/ethernet/freescale/fec.c
diff --git a/drivers/net/fec.h b/drivers/net/ethernet/freescale/fec.h
similarity index 100%
rename from drivers/net/fec.h
rename to drivers/net/ethernet/freescale/fec.h
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
similarity index 100%
rename from drivers/net/fec_mpc52xx.c
rename to drivers/net/ethernet/freescale/fec_mpc52xx.c
diff --git a/drivers/net/fec_mpc52xx.h b/drivers/net/ethernet/freescale/fec_mpc52xx.h
similarity index 100%
rename from drivers/net/fec_mpc52xx.h
rename to drivers/net/ethernet/freescale/fec_mpc52xx.h
diff --git a/drivers/net/fec_mpc52xx_phy.c b/drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
similarity index 100%
rename from drivers/net/fec_mpc52xx_phy.c
rename to drivers/net/ethernet/freescale/fec_mpc52xx_phy.c
diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/ethernet/freescale/fs_enet/Kconfig
similarity index 91%
rename from drivers/net/fs_enet/Kconfig
rename to drivers/net/ethernet/freescale/fs_enet/Kconfig
index fc073b5..be92229 100644
--- a/drivers/net/fs_enet/Kconfig
+++ b/drivers/net/ethernet/freescale/fs_enet/Kconfig
@@ -1,6 +1,6 @@
 config FS_ENET
        tristate "Freescale Ethernet Driver"
-       depends on CPM1 || CPM2 || PPC_MPC512x
+       depends on NET_VENDOR_FREESCALE && (CPM1 || CPM2 || PPC_MPC512x)
        select MII
        select PHYLIB
 
diff --git a/drivers/net/fs_enet/Makefile b/drivers/net/ethernet/freescale/fs_enet/Makefile
similarity index 100%
rename from drivers/net/fs_enet/Makefile
rename to drivers/net/ethernet/freescale/fs_enet/Makefile
diff --git a/drivers/net/fs_enet/fec.h b/drivers/net/ethernet/freescale/fs_enet/fec.h
similarity index 100%
rename from drivers/net/fs_enet/fec.h
rename to drivers/net/ethernet/freescale/fs_enet/fec.h
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
similarity index 100%
rename from drivers/net/fs_enet/fs_enet-main.c
rename to drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/ethernet/freescale/fs_enet/fs_enet.h
similarity index 100%
rename from drivers/net/fs_enet/fs_enet.h
rename to drivers/net/ethernet/freescale/fs_enet/fs_enet.h
diff --git a/drivers/net/fs_enet/mac-fcc.c b/drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
similarity index 100%
rename from drivers/net/fs_enet/mac-fcc.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-fcc.c
diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/ethernet/freescale/fs_enet/mac-fec.c
similarity index 100%
rename from drivers/net/fs_enet/mac-fec.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-fec.c
diff --git a/drivers/net/fs_enet/mac-scc.c b/drivers/net/ethernet/freescale/fs_enet/mac-scc.c
similarity index 100%
rename from drivers/net/fs_enet/mac-scc.c
rename to drivers/net/ethernet/freescale/fs_enet/mac-scc.c
diff --git a/drivers/net/fs_enet/mii-bitbang.c b/drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
similarity index 100%
rename from drivers/net/fs_enet/mii-bitbang.c
rename to drivers/net/ethernet/freescale/fs_enet/mii-bitbang.c
diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/ethernet/freescale/fs_enet/mii-fec.c
similarity index 100%
rename from drivers/net/fs_enet/mii-fec.c
rename to drivers/net/ethernet/freescale/fs_enet/mii-fec.c
diff --git a/drivers/net/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
similarity index 100%
rename from drivers/net/fsl_pq_mdio.c
rename to drivers/net/ethernet/freescale/fsl_pq_mdio.c
diff --git a/drivers/net/fsl_pq_mdio.h b/drivers/net/ethernet/freescale/fsl_pq_mdio.h
similarity index 100%
rename from drivers/net/fsl_pq_mdio.h
rename to drivers/net/ethernet/freescale/fsl_pq_mdio.h
diff --git a/drivers/net/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
similarity index 100%
rename from drivers/net/gianfar.c
rename to drivers/net/ethernet/freescale/gianfar.c
diff --git a/drivers/net/gianfar.h b/drivers/net/ethernet/freescale/gianfar.h
similarity index 100%
rename from drivers/net/gianfar.h
rename to drivers/net/ethernet/freescale/gianfar.h
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
similarity index 100%
rename from drivers/net/gianfar_ethtool.c
rename to drivers/net/ethernet/freescale/gianfar_ethtool.c
diff --git a/drivers/net/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
similarity index 100%
rename from drivers/net/gianfar_ptp.c
rename to drivers/net/ethernet/freescale/gianfar_ptp.c
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/ethernet/freescale/gianfar_sysfs.c
similarity index 100%
rename from drivers/net/gianfar_sysfs.c
rename to drivers/net/ethernet/freescale/gianfar_sysfs.c
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
similarity index 100%
rename from drivers/net/ucc_geth.c
rename to drivers/net/ethernet/freescale/ucc_geth.c
diff --git a/drivers/net/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
similarity index 100%
rename from drivers/net/ucc_geth.h
rename to drivers/net/ethernet/freescale/ucc_geth.h
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
similarity index 100%
rename from drivers/net/ucc_geth_ethtool.c
rename to drivers/net/ethernet/freescale/ucc_geth_ethtool.c
-- 
1.7.6

