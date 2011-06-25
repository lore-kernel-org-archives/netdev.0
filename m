From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 06/72] chelsio: Move the Chelsio drivers
Date: Sat, 25 Jun 2011 06:58:17 -0700
Message-ID: <1309010363-22750-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Divy Le Ray <divy@chelsio.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751902Ab1FYN7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:33 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the drivers for the Chelsio chipsets into
drivers/net/ethernet/chelsio/ and the necessary Kconfig and Makefile
changes.

CC: Divy Le Ray <divy@chelsio.com>
CC: Dimitris Michailidis <dm@chelsio.com>
CC: Casey Leedom <leedom@chelsio.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    6 +-
 drivers/infiniband/hw/cxgb3/Makefile               |    2 +-
 drivers/infiniband/hw/cxgb4/Makefile               |    2 +-
 drivers/net/Kconfig                                |   86 ----------------
 drivers/net/Makefile                               |    4 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/chelsio/Kconfig               |  102 ++++++++++++++++++++
 drivers/net/ethernet/chelsio/Makefile              |    8 ++
 .../{chelsio => ethernet/chelsio/cxgb}/Makefile    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/common.h    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/cphy.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/cpl5_cmd.h  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/cxgb2.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/elmer0.h    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/espi.c  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/espi.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/fpga_defs.h |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/gmac.h  |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.h |    0
 .../{chelsio => ethernet/chelsio/cxgb}/mv88x201x.c |    0
 .../{chelsio => ethernet/chelsio/cxgb}/my3126.c    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/pm3393.c    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/regs.h  |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/sge.c   |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/sge.h   |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/subr.c  |    0
 .../chelsio/cxgb}/suni1x10gexp_regs.h              |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/tp.c    |    0
 .../net/{chelsio => ethernet/chelsio/cxgb}/tp.h    |    0
 .../{chelsio => ethernet/chelsio/cxgb}/vsc7326.c   |    0
 .../chelsio/cxgb}/vsc7326_reg.h                    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/Makefile  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/adapter.h |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/ael1002.c |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/aq100x.c  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/common.h  |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h  |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_defs.h  |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_ioctl.h |    0
 .../net/{ => ethernet/chelsio}/cxgb3/cxgb3_main.c  |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_offload.c   |    0
 .../{ => ethernet/chelsio}/cxgb3/cxgb3_offload.h   |    0
 .../chelsio}/cxgb3/firmware_exports.h              |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.h     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/mc5.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/regs.h    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/sge.c     |    0
 .../net/{ => ethernet/chelsio}/cxgb3/sge_defs.h    |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3_cpl.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3_hw.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/t3cdev.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/version.h |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/vsc8211.c |    0
 drivers/net/{ => ethernet/chelsio}/cxgb3/xgmac.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/Makefile  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4.h   |    0
 .../net/{ => ethernet/chelsio}/cxgb4/cxgb4_main.c  |    0
 .../net/{ => ethernet/chelsio}/cxgb4/cxgb4_uld.h   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.h     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/sge.c     |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.c   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.h   |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_msg.h  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4/t4_regs.h |    0
 .../net/{ => ethernet/chelsio}/cxgb4/t4fw_api.h    |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/Makefile    |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/adapter.h   |    0
 .../{ => ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c  |    0
 drivers/net/{ => ethernet/chelsio}/cxgb4vf/sge.c   |    0
 .../{ => ethernet/chelsio}/cxgb4vf/t4vf_common.h   |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/t4vf_defs.h |    0
 .../net/{ => ethernet/chelsio}/cxgb4vf/t4vf_hw.c   |    0
 drivers/scsi/cxgbi/cxgb3i/Kbuild                   |    2 +-
 drivers/scsi/cxgbi/cxgb4i/Kbuild                   |    2 +-
 78 files changed, 119 insertions(+), 97 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/Kconfig
 create mode 100644 drivers/net/ethernet/chelsio/Makefile
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/Makefile (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/common.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cphy.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cpl5_cmd.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/cxgb2.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/elmer0.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/espi.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/espi.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/fpga_defs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/gmac.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88e1xxx.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/mv88x201x.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/my3126.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/pm3393.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/regs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/sge.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/sge.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/subr.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/suni1x10gexp_regs.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/tp.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/tp.h (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/vsc7326.c (100%)
 rename drivers/net/{chelsio => ethernet/chelsio/cxgb}/vsc7326_reg.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/adapter.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/ael1002.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/aq100x.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/common.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_ctl_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_ioctl.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_offload.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/cxgb3_offload.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/firmware_exports.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/l2t.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/mc5.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/regs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/sge_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3_cpl.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3_hw.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/t3cdev.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/version.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/vsc8211.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb3/xgmac.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/cxgb4_uld.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/l2t.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_hw.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_msg.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4_regs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4/t4fw_api.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/Makefile (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/adapter.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/cxgb4vf_main.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/sge.c (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_common.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_defs.h (100%)
 rename drivers/net/{ => ethernet/chelsio}/cxgb4vf/t4vf_hw.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 50696f8..816bab8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1961,7 +1961,7 @@ M:	Divy Le Ray <divy@chelsio.com>
 L:	netdev@vger.kernel.org
 W:	http://www.chelsio.com
 S:	Supported
-F:	drivers/net/cxgb3/
+F:	drivers/net/ethernet/chelsio/cxgb3/
 
 CXGB3 IWARP RNIC DRIVER (IW_CXGB3)
 M:	Steve Wise <swise@chelsio.com>
@@ -1975,7 +1975,7 @@ M:	Dimitris Michailidis <dm@chelsio.com>
 L:	netdev@vger.kernel.org
 W:	http://www.chelsio.com
 S:	Supported
-F:	drivers/net/cxgb4/
+F:	drivers/net/ethernet/chelsio/cxgb4/
 
 CXGB4 IWARP RNIC DRIVER (IW_CXGB4)
 M:	Steve Wise <swise@chelsio.com>
@@ -1989,7 +1989,7 @@ M:	Casey Leedom <leedom@chelsio.com>
 L:	netdev@vger.kernel.org
 W:	http://www.chelsio.com
 S:	Supported
-F:	drivers/net/cxgb4vf/
+F:	drivers/net/ethernet/chelsio/cxgb4vf/
 
 STMMAC ETHERNET DRIVER
 M:	Giuseppe Cavallaro <peppe.cavallaro@st.com>
diff --git a/drivers/infiniband/hw/cxgb3/Makefile b/drivers/infiniband/hw/cxgb3/Makefile
index 621619c..2761364 100644
--- a/drivers/infiniband/hw/cxgb3/Makefile
+++ b/drivers/infiniband/hw/cxgb3/Makefile
@@ -1,4 +1,4 @@
-ccflags-y := -Idrivers/net/cxgb3
+ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb3
 
 obj-$(CONFIG_INFINIBAND_CXGB3) += iw_cxgb3.o
 
diff --git a/drivers/infiniband/hw/cxgb4/Makefile b/drivers/infiniband/hw/cxgb4/Makefile
index cd20b13..46b878c 100644
--- a/drivers/infiniband/hw/cxgb4/Makefile
+++ b/drivers/infiniband/hw/cxgb4/Makefile
@@ -1,4 +1,4 @@
-ccflags-y := -Idrivers/net/cxgb4
+ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
 
 obj-$(CONFIG_INFINIBAND_CXGB4) += iw_cxgb4.o
 
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 2fbda69..3e1b8bc 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1937,92 +1937,6 @@ if NETDEV_10000
 config MDIO
 	tristate
 
-config CHELSIO_T1
-	tristate "Chelsio 10Gb Ethernet support"
-	depends on PCI
-	select CRC32
-	select MDIO
-	help
-	  This driver supports Chelsio gigabit and 10-gigabit
-	  Ethernet cards. More information about adapter features and
-	  performance tuning is in <file:Documentation/networking/cxgb.txt>.
-
-	  For general information about Chelsio and our products, visit
-	  our website at <http://www.chelsio.com>.
-
-	  For customer support, please visit our customer support page at
-	  <http://www.chelsio.com/support.html>.
-
-	  Please send feedback to <linux-bugs@chelsio.com>.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called cxgb.
-
-config CHELSIO_T1_1G
-	bool "Chelsio gigabit Ethernet support"
-	depends on CHELSIO_T1
-	help
-	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
-	  are using only 10G cards say 'N' here.
-
-config CHELSIO_T3
-	tristate "Chelsio Communications T3 10Gb Ethernet support"
-	depends on PCI && INET
-	select FW_LOADER
-	select MDIO
-	help
-	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
-	  adapters.
-
-	  For general information about Chelsio and our products, visit
-	  our website at <http://www.chelsio.com>.
-
-	  For customer support, please visit our customer support page at
-	  <http://www.chelsio.com/support.html>.
-
-	  Please send feedback to <linux-bugs@chelsio.com>.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called cxgb3.
-
-config CHELSIO_T4
-	tristate "Chelsio Communications T4 Ethernet support"
-	depends on PCI
-	select FW_LOADER
-	select MDIO
-	help
-	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
-	  adapters.
-
-	  For general information about Chelsio and our products, visit
-	  our website at <http://www.chelsio.com>.
-
-	  For customer support, please visit our customer support page at
-	  <http://www.chelsio.com/support.html>.
-
-	  Please send feedback to <linux-bugs@chelsio.com>.
-
-	  To compile this driver as a module choose M here; the module
-	  will be called cxgb4.
-
-config CHELSIO_T4VF
-	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
-	depends on PCI
-	help
-	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
-	  adapters with PCI-E SR-IOV Virtual Functions.
-
-	  For general information about Chelsio and our products, visit
-	  our website at <http://www.chelsio.com>.
-
-	  For customer support, please visit our customer support page at
-	  <http://www.chelsio.com/support.html>.
-
-	  Please send feedback to <linux-bugs@chelsio.com>.
-
-	  To compile this driver as a module choose M here; the module
-	  will be called cxgb4vf.
-
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS && INET && SPARSEMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index de205dc..395878f 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,10 +19,6 @@ obj-$(CONFIG_IXGBE) += ixgbe/
 obj-$(CONFIG_IXGBEVF) += ixgbevf/
 obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_IP1000) += ipg.o
-obj-$(CONFIG_CHELSIO_T1) += chelsio/
-obj-$(CONFIG_CHELSIO_T3) += cxgb3/
-obj-$(CONFIG_CHELSIO_T4) += cxgb4/
-obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
 obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 772fb49..69d6403 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -15,5 +15,6 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
+source "drivers/net/ethernet/chelsio/Kconfig"
 
 endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 3ef49a2..470e5d8 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,3 +6,4 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
+obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
new file mode 100644
index 0000000..24fd964
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -0,0 +1,102 @@
+#
+# Chelsio device configuration
+#
+
+config NET_VENDOR_CHELSIO
+	bool "Chelsio devices"
+	depends on PCI || INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Chelsio devices. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+config CHELSIO_T1
+	tristate "Chelsio 10Gb Ethernet support"
+	depends on NET_VENDOR_CHELSIO && PCI
+	select CRC32
+	select MDIO
+	---help---
+	  This driver supports Chelsio gigabit and 10-gigabit
+	  Ethernet cards. More information about adapter features and
+	  performance tuning is in <file:Documentation/networking/cxgb.txt>.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called cxgb.
+
+config CHELSIO_T1_1G
+	bool "Chelsio gigabit Ethernet support"
+	depends on CHELSIO_T1
+	---help---
+	  Enables support for Chelsio's gigabit Ethernet PCI cards.  If you
+	  are using only 10G cards say 'N' here.
+
+config CHELSIO_T3
+	tristate "Chelsio Communications T3 10Gb Ethernet support"
+	depends on NET_VENDOR_CHELSIO && PCI && INET
+	select FW_LOADER
+	select MDIO
+	---help---
+	  This driver supports Chelsio T3-based gigabit and 10Gb Ethernet
+	  adapters.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called cxgb3.
+
+config CHELSIO_T4
+	tristate "Chelsio Communications T4 Ethernet support"
+	depends on NET_VENDOR_CHELSIO && PCI
+	select FW_LOADER
+	select MDIO
+	---help---
+	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
+	  adapters.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module choose M here; the module
+	  will be called cxgb4.
+
+config CHELSIO_T4VF
+	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
+	depends on NET_VENDOR_CHELSIO && PCI
+	---help---
+	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
+	  adapters with PCI-E SR-IOV Virtual Functions.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module choose M here; the module
+	  will be called cxgb4vf.
diff --git a/drivers/net/ethernet/chelsio/Makefile b/drivers/net/ethernet/chelsio/Makefile
new file mode 100644
index 0000000..390510b
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/Makefile
@@ -0,0 +1,8 @@
+#
+# Makefile for the Chelsio network device drivers.
+#
+
+obj-$(CONFIG_CHELSIO_T1) += cxgb/
+obj-$(CONFIG_CHELSIO_T3) += cxgb3/
+obj-$(CONFIG_CHELSIO_T4) += cxgb4/
+obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
diff --git a/drivers/net/chelsio/Makefile b/drivers/net/ethernet/chelsio/cxgb/Makefile
similarity index 100%
rename from drivers/net/chelsio/Makefile
rename to drivers/net/ethernet/chelsio/cxgb/Makefile
diff --git a/drivers/net/chelsio/common.h b/drivers/net/ethernet/chelsio/cxgb/common.h
similarity index 100%
rename from drivers/net/chelsio/common.h
rename to drivers/net/ethernet/chelsio/cxgb/common.h
diff --git a/drivers/net/chelsio/cphy.h b/drivers/net/ethernet/chelsio/cxgb/cphy.h
similarity index 100%
rename from drivers/net/chelsio/cphy.h
rename to drivers/net/ethernet/chelsio/cxgb/cphy.h
diff --git a/drivers/net/chelsio/cpl5_cmd.h b/drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
similarity index 100%
rename from drivers/net/chelsio/cpl5_cmd.h
rename to drivers/net/ethernet/chelsio/cxgb/cpl5_cmd.h
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
similarity index 100%
rename from drivers/net/chelsio/cxgb2.c
rename to drivers/net/ethernet/chelsio/cxgb/cxgb2.c
diff --git a/drivers/net/chelsio/elmer0.h b/drivers/net/ethernet/chelsio/cxgb/elmer0.h
similarity index 100%
rename from drivers/net/chelsio/elmer0.h
rename to drivers/net/ethernet/chelsio/cxgb/elmer0.h
diff --git a/drivers/net/chelsio/espi.c b/drivers/net/ethernet/chelsio/cxgb/espi.c
similarity index 100%
rename from drivers/net/chelsio/espi.c
rename to drivers/net/ethernet/chelsio/cxgb/espi.c
diff --git a/drivers/net/chelsio/espi.h b/drivers/net/ethernet/chelsio/cxgb/espi.h
similarity index 100%
rename from drivers/net/chelsio/espi.h
rename to drivers/net/ethernet/chelsio/cxgb/espi.h
diff --git a/drivers/net/chelsio/fpga_defs.h b/drivers/net/ethernet/chelsio/cxgb/fpga_defs.h
similarity index 100%
rename from drivers/net/chelsio/fpga_defs.h
rename to drivers/net/ethernet/chelsio/cxgb/fpga_defs.h
diff --git a/drivers/net/chelsio/gmac.h b/drivers/net/ethernet/chelsio/cxgb/gmac.h
similarity index 100%
rename from drivers/net/chelsio/gmac.h
rename to drivers/net/ethernet/chelsio/cxgb/gmac.h
diff --git a/drivers/net/chelsio/mv88e1xxx.c b/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
similarity index 100%
rename from drivers/net/chelsio/mv88e1xxx.c
rename to drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.c
diff --git a/drivers/net/chelsio/mv88e1xxx.h b/drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.h
similarity index 100%
rename from drivers/net/chelsio/mv88e1xxx.h
rename to drivers/net/ethernet/chelsio/cxgb/mv88e1xxx.h
diff --git a/drivers/net/chelsio/mv88x201x.c b/drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
similarity index 100%
rename from drivers/net/chelsio/mv88x201x.c
rename to drivers/net/ethernet/chelsio/cxgb/mv88x201x.c
diff --git a/drivers/net/chelsio/my3126.c b/drivers/net/ethernet/chelsio/cxgb/my3126.c
similarity index 100%
rename from drivers/net/chelsio/my3126.c
rename to drivers/net/ethernet/chelsio/cxgb/my3126.c
diff --git a/drivers/net/chelsio/pm3393.c b/drivers/net/ethernet/chelsio/cxgb/pm3393.c
similarity index 100%
rename from drivers/net/chelsio/pm3393.c
rename to drivers/net/ethernet/chelsio/cxgb/pm3393.c
diff --git a/drivers/net/chelsio/regs.h b/drivers/net/ethernet/chelsio/cxgb/regs.h
similarity index 100%
rename from drivers/net/chelsio/regs.h
rename to drivers/net/ethernet/chelsio/cxgb/regs.h
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/ethernet/chelsio/cxgb/sge.c
similarity index 100%
rename from drivers/net/chelsio/sge.c
rename to drivers/net/ethernet/chelsio/cxgb/sge.c
diff --git a/drivers/net/chelsio/sge.h b/drivers/net/ethernet/chelsio/cxgb/sge.h
similarity index 100%
rename from drivers/net/chelsio/sge.h
rename to drivers/net/ethernet/chelsio/cxgb/sge.h
diff --git a/drivers/net/chelsio/subr.c b/drivers/net/ethernet/chelsio/cxgb/subr.c
similarity index 100%
rename from drivers/net/chelsio/subr.c
rename to drivers/net/ethernet/chelsio/cxgb/subr.c
diff --git a/drivers/net/chelsio/suni1x10gexp_regs.h b/drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
similarity index 100%
rename from drivers/net/chelsio/suni1x10gexp_regs.h
rename to drivers/net/ethernet/chelsio/cxgb/suni1x10gexp_regs.h
diff --git a/drivers/net/chelsio/tp.c b/drivers/net/ethernet/chelsio/cxgb/tp.c
similarity index 100%
rename from drivers/net/chelsio/tp.c
rename to drivers/net/ethernet/chelsio/cxgb/tp.c
diff --git a/drivers/net/chelsio/tp.h b/drivers/net/ethernet/chelsio/cxgb/tp.h
similarity index 100%
rename from drivers/net/chelsio/tp.h
rename to drivers/net/ethernet/chelsio/cxgb/tp.h
diff --git a/drivers/net/chelsio/vsc7326.c b/drivers/net/ethernet/chelsio/cxgb/vsc7326.c
similarity index 100%
rename from drivers/net/chelsio/vsc7326.c
rename to drivers/net/ethernet/chelsio/cxgb/vsc7326.c
diff --git a/drivers/net/chelsio/vsc7326_reg.h b/drivers/net/ethernet/chelsio/cxgb/vsc7326_reg.h
similarity index 100%
rename from drivers/net/chelsio/vsc7326_reg.h
rename to drivers/net/ethernet/chelsio/cxgb/vsc7326_reg.h
diff --git a/drivers/net/cxgb3/Makefile b/drivers/net/ethernet/chelsio/cxgb3/Makefile
similarity index 100%
rename from drivers/net/cxgb3/Makefile
rename to drivers/net/ethernet/chelsio/cxgb3/Makefile
diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/ethernet/chelsio/cxgb3/adapter.h
similarity index 100%
rename from drivers/net/cxgb3/adapter.h
rename to drivers/net/ethernet/chelsio/cxgb3/adapter.h
diff --git a/drivers/net/cxgb3/ael1002.c b/drivers/net/ethernet/chelsio/cxgb3/ael1002.c
similarity index 100%
rename from drivers/net/cxgb3/ael1002.c
rename to drivers/net/ethernet/chelsio/cxgb3/ael1002.c
diff --git a/drivers/net/cxgb3/aq100x.c b/drivers/net/ethernet/chelsio/cxgb3/aq100x.c
similarity index 100%
rename from drivers/net/cxgb3/aq100x.c
rename to drivers/net/ethernet/chelsio/cxgb3/aq100x.c
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/ethernet/chelsio/cxgb3/common.h
similarity index 100%
rename from drivers/net/cxgb3/common.h
rename to drivers/net/ethernet/chelsio/cxgb3/common.h
diff --git a/drivers/net/cxgb3/cxgb3_ctl_defs.h b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_ctl_defs.h
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_ctl_defs.h
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_ctl_defs.h
diff --git a/drivers/net/cxgb3/cxgb3_defs.h b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_defs.h
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_defs.h
diff --git a/drivers/net/cxgb3/cxgb3_ioctl.h b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_ioctl.h
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_ioctl.h
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_ioctl.h
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_main.c
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_offload.c
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.c
diff --git a/drivers/net/cxgb3/cxgb3_offload.h b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.h
similarity index 100%
rename from drivers/net/cxgb3/cxgb3_offload.h
rename to drivers/net/ethernet/chelsio/cxgb3/cxgb3_offload.h
diff --git a/drivers/net/cxgb3/firmware_exports.h b/drivers/net/ethernet/chelsio/cxgb3/firmware_exports.h
similarity index 100%
rename from drivers/net/cxgb3/firmware_exports.h
rename to drivers/net/ethernet/chelsio/cxgb3/firmware_exports.h
diff --git a/drivers/net/cxgb3/l2t.c b/drivers/net/ethernet/chelsio/cxgb3/l2t.c
similarity index 100%
rename from drivers/net/cxgb3/l2t.c
rename to drivers/net/ethernet/chelsio/cxgb3/l2t.c
diff --git a/drivers/net/cxgb3/l2t.h b/drivers/net/ethernet/chelsio/cxgb3/l2t.h
similarity index 100%
rename from drivers/net/cxgb3/l2t.h
rename to drivers/net/ethernet/chelsio/cxgb3/l2t.h
diff --git a/drivers/net/cxgb3/mc5.c b/drivers/net/ethernet/chelsio/cxgb3/mc5.c
similarity index 100%
rename from drivers/net/cxgb3/mc5.c
rename to drivers/net/ethernet/chelsio/cxgb3/mc5.c
diff --git a/drivers/net/cxgb3/regs.h b/drivers/net/ethernet/chelsio/cxgb3/regs.h
similarity index 100%
rename from drivers/net/cxgb3/regs.h
rename to drivers/net/ethernet/chelsio/cxgb3/regs.h
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
similarity index 100%
rename from drivers/net/cxgb3/sge.c
rename to drivers/net/ethernet/chelsio/cxgb3/sge.c
diff --git a/drivers/net/cxgb3/sge_defs.h b/drivers/net/ethernet/chelsio/cxgb3/sge_defs.h
similarity index 100%
rename from drivers/net/cxgb3/sge_defs.h
rename to drivers/net/ethernet/chelsio/cxgb3/sge_defs.h
diff --git a/drivers/net/cxgb3/t3_cpl.h b/drivers/net/ethernet/chelsio/cxgb3/t3_cpl.h
similarity index 100%
rename from drivers/net/cxgb3/t3_cpl.h
rename to drivers/net/ethernet/chelsio/cxgb3/t3_cpl.h
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
similarity index 100%
rename from drivers/net/cxgb3/t3_hw.c
rename to drivers/net/ethernet/chelsio/cxgb3/t3_hw.c
diff --git a/drivers/net/cxgb3/t3cdev.h b/drivers/net/ethernet/chelsio/cxgb3/t3cdev.h
similarity index 100%
rename from drivers/net/cxgb3/t3cdev.h
rename to drivers/net/ethernet/chelsio/cxgb3/t3cdev.h
diff --git a/drivers/net/cxgb3/version.h b/drivers/net/ethernet/chelsio/cxgb3/version.h
similarity index 100%
rename from drivers/net/cxgb3/version.h
rename to drivers/net/ethernet/chelsio/cxgb3/version.h
diff --git a/drivers/net/cxgb3/vsc8211.c b/drivers/net/ethernet/chelsio/cxgb3/vsc8211.c
similarity index 100%
rename from drivers/net/cxgb3/vsc8211.c
rename to drivers/net/ethernet/chelsio/cxgb3/vsc8211.c
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/ethernet/chelsio/cxgb3/xgmac.c
similarity index 100%
rename from drivers/net/cxgb3/xgmac.c
rename to drivers/net/ethernet/chelsio/cxgb3/xgmac.c
diff --git a/drivers/net/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
similarity index 100%
rename from drivers/net/cxgb4/Makefile
rename to drivers/net/ethernet/chelsio/cxgb4/Makefile
diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
similarity index 100%
rename from drivers/net/cxgb4/cxgb4.h
rename to drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
similarity index 100%
rename from drivers/net/cxgb4/cxgb4_main.c
rename to drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
diff --git a/drivers/net/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
similarity index 100%
rename from drivers/net/cxgb4/cxgb4_uld.h
rename to drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
diff --git a/drivers/net/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
similarity index 100%
rename from drivers/net/cxgb4/l2t.c
rename to drivers/net/ethernet/chelsio/cxgb4/l2t.c
diff --git a/drivers/net/cxgb4/l2t.h b/drivers/net/ethernet/chelsio/cxgb4/l2t.h
similarity index 100%
rename from drivers/net/cxgb4/l2t.h
rename to drivers/net/ethernet/chelsio/cxgb4/l2t.h
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
similarity index 100%
rename from drivers/net/cxgb4/sge.c
rename to drivers/net/ethernet/chelsio/cxgb4/sge.c
diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
similarity index 100%
rename from drivers/net/cxgb4/t4_hw.c
rename to drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
diff --git a/drivers/net/cxgb4/t4_hw.h b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
similarity index 100%
rename from drivers/net/cxgb4/t4_hw.h
rename to drivers/net/ethernet/chelsio/cxgb4/t4_hw.h
diff --git a/drivers/net/cxgb4/t4_msg.h b/drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
similarity index 100%
rename from drivers/net/cxgb4/t4_msg.h
rename to drivers/net/ethernet/chelsio/cxgb4/t4_msg.h
diff --git a/drivers/net/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
similarity index 100%
rename from drivers/net/cxgb4/t4_regs.h
rename to drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
diff --git a/drivers/net/cxgb4/t4fw_api.h b/drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
similarity index 100%
rename from drivers/net/cxgb4/t4fw_api.h
rename to drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h
diff --git a/drivers/net/cxgb4vf/Makefile b/drivers/net/ethernet/chelsio/cxgb4vf/Makefile
similarity index 100%
rename from drivers/net/cxgb4vf/Makefile
rename to drivers/net/ethernet/chelsio/cxgb4vf/Makefile
diff --git a/drivers/net/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
similarity index 100%
rename from drivers/net/cxgb4vf/adapter.h
rename to drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
similarity index 100%
rename from drivers/net/cxgb4vf/cxgb4vf_main.c
rename to drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/ethernet/chelsio/cxgb4vf/sge.c
similarity index 100%
rename from drivers/net/cxgb4vf/sge.c
rename to drivers/net/ethernet/chelsio/cxgb4vf/sge.c
diff --git a/drivers/net/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
similarity index 100%
rename from drivers/net/cxgb4vf/t4vf_common.h
rename to drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
diff --git a/drivers/net/cxgb4vf/t4vf_defs.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
similarity index 100%
rename from drivers/net/cxgb4vf/t4vf_defs.h
rename to drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
similarity index 100%
rename from drivers/net/cxgb4vf/t4vf_hw.c
rename to drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
diff --git a/drivers/scsi/cxgbi/cxgb3i/Kbuild b/drivers/scsi/cxgbi/cxgb3i/Kbuild
index 09dbf9e..6f095e2 100644
--- a/drivers/scsi/cxgbi/cxgb3i/Kbuild
+++ b/drivers/scsi/cxgbi/cxgb3i/Kbuild
@@ -1,3 +1,3 @@
-EXTRA_CFLAGS += -I$(srctree)/drivers/net/cxgb3
+EXTRA_CFLAGS += -I$(srctree)/drivers/net/ethernet/chelsio/cxgb3
 
 obj-$(CONFIG_SCSI_CXGB3_ISCSI) += cxgb3i.o
diff --git a/drivers/scsi/cxgbi/cxgb4i/Kbuild b/drivers/scsi/cxgbi/cxgb4i/Kbuild
index b9f4af7..8290cda 100644
--- a/drivers/scsi/cxgbi/cxgb4i/Kbuild
+++ b/drivers/scsi/cxgbi/cxgb4i/Kbuild
@@ -1,3 +1,3 @@
-EXTRA_CFLAGS += -I$(srctree)/drivers/net/cxgb4
+EXTRA_CFLAGS += -I$(srctree)/drivers/net/ethernet/chelsio/cxgb4
 
 obj-$(CONFIG_SCSI_CXGB4_ISCSI) += cxgb4i.o
-- 
1.7.5.4

