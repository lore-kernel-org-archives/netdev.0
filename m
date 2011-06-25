From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 14/72] bna: Move the Brocade driver
Date: Sat, 25 Jun 2011 06:58:25 -0700
Message-ID: <1309010363-22750-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:2034 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752070Ab1FYOAA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 10:00:00 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Brocade driver into drivers/net/ethernet/brocade/ and make
the necessary Kconfig and Makefile changes.

CC: Rasesh Mody <rmody@brocade.com>
CC: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 MAINTAINERS                                        |    2 +-
 drivers/net/Kconfig                                |   14 --------------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/brocade/Kconfig               |   18 ++++++++++++++++++
 drivers/net/ethernet/brocade/Makefile              |    5 +++++
 drivers/net/ethernet/brocade/bna/Kconfig           |   17 +++++++++++++++++
 drivers/net/{ => ethernet/brocade}/bna/Makefile    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h  |    0
 .../net/{ => ethernet/brocade}/bna/bfa_defs_cna.h  |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h |    0
 .../{ => ethernet/brocade}/bna/bfa_defs_status.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h   |    0
 .../net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_sm.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfa_wc.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h   |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_ctreg.h |    0
 drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_hw.h    |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/bna_types.h |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.c      |    0
 drivers/net/{ => ethernet/brocade}/bna/bnad.h      |    0
 .../net/{ => ethernet/brocade}/bna/bnad_ethtool.c  |    0
 drivers/net/{ => ethernet/brocade}/bna/cna.h       |    0
 drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c |    0
 34 files changed, 43 insertions(+), 16 deletions(-)
 create mode 100644 drivers/net/ethernet/brocade/Kconfig
 create mode 100644 drivers/net/ethernet/brocade/Makefile
 create mode 100644 drivers/net/ethernet/brocade/bna/Kconfig
 rename drivers/net/{ => ethernet/brocade}/bna/Makefile (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_cee.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_mfg_comm.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_defs_status.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_ioc_ct.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_sm.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfa_wc.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_ctreg.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bfi_ll.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_ctrl.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_hw.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_txrx.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bna_types.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/bnad_ethtool.c (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna.h (100%)
 rename drivers/net/{ => ethernet/brocade}/bna/cna_fwimg.c (100%)

diff --git a/MAINTAINERS b/MAINTAINERS
index 5bf6ae2..b73e10b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1550,7 +1550,7 @@ M:	Rasesh Mody <rmody@brocade.com>
 M:	Debashis Dutt <ddutt@brocade.com>
 L:	netdev@vger.kernel.org
 S:	Supported
-F:	drivers/net/bna/
+F:	drivers/net/ethernet/brocade/bna/
 
 BSG (block layer generic sg v4 driver)
 M:	FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 5218303..c3ab3e7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1767,20 +1767,6 @@ config TEHUTI
 	help
 	  Tehuti Networks 10G Ethernet NIC
 
-config BNA
-	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
-	depends on PCI
-	---help---
-	  This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
-	  cards.
-	  To compile this driver as a module, choose M here: the module
-	  will be called bna.
-
-	  For general information and support, go to the Brocade support
-	  website at:
-
-	  <http://support.brocade.com>
-
 endif # NETDEV_10000
 
 source "drivers/net/tokenring/Kconfig"
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 5e1ccb5..f480771 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -25,7 +25,6 @@ obj-$(CONFIG_TEHUTI) += tehuti.o
 obj-$(CONFIG_ENIC) += enic/
 obj-$(CONFIG_JME) += jme.o
 obj-$(CONFIG_VMXNET3) += vmxnet3/
-obj-$(CONFIG_BNA) += bna/
 
 gianfar_driver-objs := gianfar.o \
 		gianfar_ethtool.o \
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index 97a4b57..aae207a 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -15,6 +15,7 @@ source "drivers/net/ethernet/3com/Kconfig"
 source "drivers/net/ethernet/8390/Kconfig"
 source "drivers/net/ethernet/amd/Kconfig"
 source "drivers/net/ethernet/broadcom/Kconfig"
+source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index bf9b2e9..9494827 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -6,6 +6,7 @@ obj-$(CONFIG_NET_VENDOR_3COM) += 3com/
 obj-$(CONFIG_NET_VENDOR_8390) += 8390/
 obj-$(CONFIG_NET_VENDOR_AMD) += amd/
 obj-$(CONFIG_NET_VENDOR_BROADCOM) += broadcom/
+obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
diff --git a/drivers/net/ethernet/brocade/Kconfig b/drivers/net/ethernet/brocade/Kconfig
new file mode 100644
index 0000000..8d8bff7
--- /dev/null
+++ b/drivers/net/ethernet/brocade/Kconfig
@@ -0,0 +1,18 @@
+#
+# Brocade device configuration
+#
+
+config NET_VENDOR_BROCADE
+	bool "Brocade devices"
+	depends on PCI
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Brocade cards. If you say Y, you will be asked for
+	  your specific card in the following questions.
+
+source "drivers/net/ethernet/brocade/bna/Kconfig"
diff --git a/drivers/net/ethernet/brocade/Makefile b/drivers/net/ethernet/brocade/Makefile
new file mode 100644
index 0000000..b58238d
--- /dev/null
+++ b/drivers/net/ethernet/brocade/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Brocade device drivers.
+#
+
+obj-$(CONFIG_BNA) += bna/
diff --git a/drivers/net/ethernet/brocade/bna/Kconfig b/drivers/net/ethernet/brocade/bna/Kconfig
new file mode 100644
index 0000000..ba37af2
--- /dev/null
+++ b/drivers/net/ethernet/brocade/bna/Kconfig
@@ -0,0 +1,17 @@
+#
+# Brocade network device configuration
+#
+
+config BNA
+	tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
+	depends on NET_VENDOR_BROCADE && PCI
+	---help---
+	  This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
+	  cards.
+	  To compile this driver as a module, choose M here: the module
+	  will be called bna.
+
+	  For general information and support, go to the Brocade support
+	  website at:
+
+	  <http://support.brocade.com>
diff --git a/drivers/net/bna/Makefile b/drivers/net/ethernet/brocade/bna/Makefile
similarity index 100%
rename from drivers/net/bna/Makefile
rename to drivers/net/ethernet/brocade/bna/Makefile
diff --git a/drivers/net/bna/bfa_cee.c b/drivers/net/ethernet/brocade/bna/bfa_cee.c
similarity index 100%
rename from drivers/net/bna/bfa_cee.c
rename to drivers/net/ethernet/brocade/bna/bfa_cee.c
diff --git a/drivers/net/bna/bfa_cee.h b/drivers/net/ethernet/brocade/bna/bfa_cee.h
similarity index 100%
rename from drivers/net/bna/bfa_cee.h
rename to drivers/net/ethernet/brocade/bna/bfa_cee.h
diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
similarity index 100%
rename from drivers/net/bna/bfa_defs.h
rename to drivers/net/ethernet/brocade/bna/bfa_defs.h
diff --git a/drivers/net/bna/bfa_defs_cna.h b/drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
similarity index 100%
rename from drivers/net/bna/bfa_defs_cna.h
rename to drivers/net/ethernet/brocade/bna/bfa_defs_cna.h
diff --git a/drivers/net/bna/bfa_defs_mfg_comm.h b/drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
similarity index 100%
rename from drivers/net/bna/bfa_defs_mfg_comm.h
rename to drivers/net/ethernet/brocade/bna/bfa_defs_mfg_comm.h
diff --git a/drivers/net/bna/bfa_defs_status.h b/drivers/net/ethernet/brocade/bna/bfa_defs_status.h
similarity index 100%
rename from drivers/net/bna/bfa_defs_status.h
rename to drivers/net/ethernet/brocade/bna/bfa_defs_status.h
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/ethernet/brocade/bna/bfa_ioc.c
similarity index 100%
rename from drivers/net/bna/bfa_ioc.c
rename to drivers/net/ethernet/brocade/bna/bfa_ioc.c
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/ethernet/brocade/bna/bfa_ioc.h
similarity index 100%
rename from drivers/net/bna/bfa_ioc.h
rename to drivers/net/ethernet/brocade/bna/bfa_ioc.h
diff --git a/drivers/net/bna/bfa_ioc_ct.c b/drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
similarity index 100%
rename from drivers/net/bna/bfa_ioc_ct.c
rename to drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c
diff --git a/drivers/net/bna/bfa_sm.h b/drivers/net/ethernet/brocade/bna/bfa_sm.h
similarity index 100%
rename from drivers/net/bna/bfa_sm.h
rename to drivers/net/ethernet/brocade/bna/bfa_sm.h
diff --git a/drivers/net/bna/bfa_wc.h b/drivers/net/ethernet/brocade/bna/bfa_wc.h
similarity index 100%
rename from drivers/net/bna/bfa_wc.h
rename to drivers/net/ethernet/brocade/bna/bfa_wc.h
diff --git a/drivers/net/bna/bfi.h b/drivers/net/ethernet/brocade/bna/bfi.h
similarity index 100%
rename from drivers/net/bna/bfi.h
rename to drivers/net/ethernet/brocade/bna/bfi.h
diff --git a/drivers/net/bna/bfi_cna.h b/drivers/net/ethernet/brocade/bna/bfi_cna.h
similarity index 100%
rename from drivers/net/bna/bfi_cna.h
rename to drivers/net/ethernet/brocade/bna/bfi_cna.h
diff --git a/drivers/net/bna/bfi_ctreg.h b/drivers/net/ethernet/brocade/bna/bfi_ctreg.h
similarity index 100%
rename from drivers/net/bna/bfi_ctreg.h
rename to drivers/net/ethernet/brocade/bna/bfi_ctreg.h
diff --git a/drivers/net/bna/bfi_ll.h b/drivers/net/ethernet/brocade/bna/bfi_ll.h
similarity index 100%
rename from drivers/net/bna/bfi_ll.h
rename to drivers/net/ethernet/brocade/bna/bfi_ll.h
diff --git a/drivers/net/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
similarity index 100%
rename from drivers/net/bna/bna.h
rename to drivers/net/ethernet/brocade/bna/bna.h
diff --git a/drivers/net/bna/bna_ctrl.c b/drivers/net/ethernet/brocade/bna/bna_ctrl.c
similarity index 100%
rename from drivers/net/bna/bna_ctrl.c
rename to drivers/net/ethernet/brocade/bna/bna_ctrl.c
diff --git a/drivers/net/bna/bna_hw.h b/drivers/net/ethernet/brocade/bna/bna_hw.h
similarity index 100%
rename from drivers/net/bna/bna_hw.h
rename to drivers/net/ethernet/brocade/bna/bna_hw.h
diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/ethernet/brocade/bna/bna_txrx.c
similarity index 100%
rename from drivers/net/bna/bna_txrx.c
rename to drivers/net/ethernet/brocade/bna/bna_txrx.c
diff --git a/drivers/net/bna/bna_types.h b/drivers/net/ethernet/brocade/bna/bna_types.h
similarity index 100%
rename from drivers/net/bna/bna_types.h
rename to drivers/net/ethernet/brocade/bna/bna_types.h
diff --git a/drivers/net/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
similarity index 100%
rename from drivers/net/bna/bnad.c
rename to drivers/net/ethernet/brocade/bna/bnad.c
diff --git a/drivers/net/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
similarity index 100%
rename from drivers/net/bna/bnad.h
rename to drivers/net/ethernet/brocade/bna/bnad.h
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
similarity index 100%
rename from drivers/net/bna/bnad_ethtool.c
rename to drivers/net/ethernet/brocade/bna/bnad_ethtool.c
diff --git a/drivers/net/bna/cna.h b/drivers/net/ethernet/brocade/bna/cna.h
similarity index 100%
rename from drivers/net/bna/cna.h
rename to drivers/net/ethernet/brocade/bna/cna.h
diff --git a/drivers/net/bna/cna_fwimg.c b/drivers/net/ethernet/brocade/bna/cna_fwimg.c
similarity index 100%
rename from drivers/net/bna/cna_fwimg.c
rename to drivers/net/ethernet/brocade/bna/cna_fwimg.c
-- 
1.7.5.4

