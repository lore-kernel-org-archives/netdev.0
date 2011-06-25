From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 15/72] mlx4: Move the Mellanox driver
Date: Sat, 25 Jun 2011 06:58:26 -0700
Message-ID: <1309010363-22750-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	Roland Dreier <roland@kernel.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752059Ab1FYN77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:59 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moves the Mellanox driver into drivers/net/ethernet/mellanox/ and
make the necessary Kconfig and Makefile changes.

CC: Roland Dreier <roland@kernel.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig                                |   24 -----------------
 drivers/net/Makefile                               |    1 -
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/mellanox/Kconfig              |   18 +++++++++++++
 drivers/net/ethernet/mellanox/Makefile             |    5 +++
 drivers/net/ethernet/mellanox/mlx4/Kconfig         |   27 ++++++++++++++++++++
 drivers/net/{ => ethernet/mellanox}/mlx4/Makefile  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/catas.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/cq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_ethtool.c  |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_netdev.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h |    0
 .../{ => ethernet/mellanox}/mlx4/en_resources.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c   |    0
 .../net/{ => ethernet/mellanox}/mlx4/en_selftest.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/eq.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/fw.h      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/icm.h     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/intf.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/main.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c     |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/mr.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/pd.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/port.c    |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/profile.c |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/qp.c      |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/reset.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/sense.c   |    0
 drivers/net/{ => ethernet/mellanox}/mlx4/srq.c     |    0
 40 files changed, 52 insertions(+), 25 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/Kconfig
 create mode 100644 drivers/net/ethernet/mellanox/Makefile
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/Kconfig
 rename drivers/net/{ => ethernet/mellanox}/mlx4/Makefile (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/alloc.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/catas.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cmd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_cq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_ethtool.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_netdev.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_port.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_resources.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_rx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_selftest.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/en_tx.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/eq.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/fw.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/icm.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/intf.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/main.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mcg.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mlx4_en.h (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/mr.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/pd.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/port.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/profile.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/qp.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/reset.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/sense.c (100%)
 rename drivers/net/{ => ethernet/mellanox}/mlx4/srq.c (100%)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c3ab3e7..4e8b6c3 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1737,30 +1737,6 @@ config PASEMI_MAC
 	  This driver supports the on-chip 1/10Gbit Ethernet controller on
 	  PA Semi's PWRficient line of chips.
 
-config MLX4_EN
-	tristate "Mellanox Technologies 10Gbit Ethernet support"
-	depends on PCI && INET
-	select MLX4_CORE
-	select INET_LRO
-	help
-	  This driver supports Mellanox Technologies ConnectX Ethernet
-	  devices.
-
-config MLX4_CORE
-	tristate
-	depends on PCI
-	default n
-
-config MLX4_DEBUG
-	bool "Verbose debugging output" if (MLX4_CORE && EXPERT)
-	depends on MLX4_CORE
-	default y
-	---help---
-	  This option causes debugging code to be compiled into the
-	  mlx4_core driver.  The output can be turned on via the
-	  debug_level module parameter (which can also be set after
-	  the driver is loaded through sysfs).
-
 config TEHUTI
 	tristate "Tehuti Networks 10G Ethernet"
 	depends on PCI
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index f480771..6c2eb60 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -176,7 +176,6 @@ obj-$(CONFIG_BFIN_MAC) += bfin_mac.o
 obj-$(CONFIG_DM9000) += dm9000.o
 obj-$(CONFIG_PASEMI_MAC) += pasemi_mac_driver.o
 pasemi_mac_driver-objs := pasemi_mac.o pasemi_mac_ethtool.o
-obj-$(CONFIG_MLX4_CORE) += mlx4/
 obj-$(CONFIG_ENC28J60) += enc28j60.o
 obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_GRETH) += greth.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index aae207a..67b06b2 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -19,6 +19,7 @@ source "drivers/net/ethernet/brocade/Kconfig"
 source "drivers/net/ethernet/chelsio/Kconfig"
 source "drivers/net/ethernet/emulex/Kconfig"
 source "drivers/net/ethernet/intel/Kconfig"
+source "drivers/net/ethernet/mellanox/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
 source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/sfc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index 9494827..ecbe7fa 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_NET_VENDOR_BROCADE) += brocade/
 obj-$(CONFIG_NET_VENDOR_CHELSIO) += chelsio/
 obj-$(CONFIG_NET_VENDOR_EMULEX) += emulex/
 obj-$(CONFIG_NET_VENDOR_INTEL) += intel/
+obj-$(CONFIG_NET_VENDOR_MELLANOX) += mellanox/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
 obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_SFC) += sfc/
diff --git a/drivers/net/ethernet/mellanox/Kconfig b/drivers/net/ethernet/mellanox/Kconfig
new file mode 100644
index 0000000..ba0524a
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/Kconfig
@@ -0,0 +1,18 @@
+#
+# Mellanox driver configuration
+#
+
+config NET_VENDOR_MELLANOX
+	bool "Mellanox devices"
+	depends on PCI || INET
+	---help---
+	  If you have a network (Ethernet) card belonging to this class, say Y
+	  and read the Ethernet-HOWTO, available from
+	  <http://www.tldp.org/docs.html#howto>.
+
+	  Note that the answer to this question doesn't directly affect the
+	  kernel: saying N will just cause the configurator to skip all
+	  the questions about Mellanox cards. If you say Y, you will be asked
+	  for your specific card in the following questions.
+
+source "drivers/net/ethernet/mellanox/mlx4/Kconfig"
diff --git a/drivers/net/ethernet/mellanox/Makefile b/drivers/net/ethernet/mellanox/Makefile
new file mode 100644
index 0000000..37afb96
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/Makefile
@@ -0,0 +1,5 @@
+#
+# Makefile for the Mellanox device drivers.
+#
+
+obj-$(CONFIG_MLX4_CORE) += mlx4/
diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/ethernet/mellanox/mlx4/Kconfig
new file mode 100644
index 0000000..67df67a
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -0,0 +1,27 @@
+#
+# Mellanox driver configuration
+#
+
+config MLX4_EN
+	tristate "Mellanox Technologies 10Gbit Ethernet support"
+	depends on NET_VENDOR_MELLANOX && PCI && INET
+	select MLX4_CORE
+	select INET_LRO
+	---help---
+	  This driver supports Mellanox Technologies ConnectX Ethernet
+	  devices.
+
+config MLX4_CORE
+	tristate
+	depends on PCI
+	default n
+
+config MLX4_DEBUG
+	bool "Verbose debugging output" if (MLX4_CORE && EXPERT)
+	depends on MLX4_CORE
+	default y
+	---help---
+	  This option causes debugging code to be compiled into the
+	  mlx4_core driver.  The output can be turned on via the
+	  debug_level module parameter (which can also be set after
+	  the driver is loaded through sysfs).
diff --git a/drivers/net/mlx4/Makefile b/drivers/net/ethernet/mellanox/mlx4/Makefile
similarity index 100%
rename from drivers/net/mlx4/Makefile
rename to drivers/net/ethernet/mellanox/mlx4/Makefile
diff --git a/drivers/net/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
similarity index 100%
rename from drivers/net/mlx4/alloc.c
rename to drivers/net/ethernet/mellanox/mlx4/alloc.c
diff --git a/drivers/net/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
similarity index 100%
rename from drivers/net/mlx4/catas.c
rename to drivers/net/ethernet/mellanox/mlx4/catas.c
diff --git a/drivers/net/mlx4/cmd.c b/drivers/net/ethernet/mellanox/mlx4/cmd.c
similarity index 100%
rename from drivers/net/mlx4/cmd.c
rename to drivers/net/ethernet/mellanox/mlx4/cmd.c
diff --git a/drivers/net/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
similarity index 100%
rename from drivers/net/mlx4/cq.c
rename to drivers/net/ethernet/mellanox/mlx4/cq.c
diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
similarity index 100%
rename from drivers/net/mlx4/en_cq.c
rename to drivers/net/ethernet/mellanox/mlx4/en_cq.c
diff --git a/drivers/net/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
similarity index 100%
rename from drivers/net/mlx4/en_ethtool.c
rename to drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
diff --git a/drivers/net/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
similarity index 100%
rename from drivers/net/mlx4/en_main.c
rename to drivers/net/ethernet/mellanox/mlx4/en_main.c
diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
similarity index 100%
rename from drivers/net/mlx4/en_netdev.c
rename to drivers/net/ethernet/mellanox/mlx4/en_netdev.c
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/ethernet/mellanox/mlx4/en_port.c
similarity index 100%
rename from drivers/net/mlx4/en_port.c
rename to drivers/net/ethernet/mellanox/mlx4/en_port.c
diff --git a/drivers/net/mlx4/en_port.h b/drivers/net/ethernet/mellanox/mlx4/en_port.h
similarity index 100%
rename from drivers/net/mlx4/en_port.h
rename to drivers/net/ethernet/mellanox/mlx4/en_port.h
diff --git a/drivers/net/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
similarity index 100%
rename from drivers/net/mlx4/en_resources.c
rename to drivers/net/ethernet/mellanox/mlx4/en_resources.c
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
similarity index 100%
rename from drivers/net/mlx4/en_rx.c
rename to drivers/net/ethernet/mellanox/mlx4/en_rx.c
diff --git a/drivers/net/mlx4/en_selftest.c b/drivers/net/ethernet/mellanox/mlx4/en_selftest.c
similarity index 100%
rename from drivers/net/mlx4/en_selftest.c
rename to drivers/net/ethernet/mellanox/mlx4/en_selftest.c
diff --git a/drivers/net/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
similarity index 100%
rename from drivers/net/mlx4/en_tx.c
rename to drivers/net/ethernet/mellanox/mlx4/en_tx.c
diff --git a/drivers/net/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
similarity index 100%
rename from drivers/net/mlx4/eq.c
rename to drivers/net/ethernet/mellanox/mlx4/eq.c
diff --git a/drivers/net/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
similarity index 100%
rename from drivers/net/mlx4/fw.c
rename to drivers/net/ethernet/mellanox/mlx4/fw.c
diff --git a/drivers/net/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
similarity index 100%
rename from drivers/net/mlx4/fw.h
rename to drivers/net/ethernet/mellanox/mlx4/fw.h
diff --git a/drivers/net/mlx4/icm.c b/drivers/net/ethernet/mellanox/mlx4/icm.c
similarity index 100%
rename from drivers/net/mlx4/icm.c
rename to drivers/net/ethernet/mellanox/mlx4/icm.c
diff --git a/drivers/net/mlx4/icm.h b/drivers/net/ethernet/mellanox/mlx4/icm.h
similarity index 100%
rename from drivers/net/mlx4/icm.h
rename to drivers/net/ethernet/mellanox/mlx4/icm.h
diff --git a/drivers/net/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
similarity index 100%
rename from drivers/net/mlx4/intf.c
rename to drivers/net/ethernet/mellanox/mlx4/intf.c
diff --git a/drivers/net/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
similarity index 100%
rename from drivers/net/mlx4/main.c
rename to drivers/net/ethernet/mellanox/mlx4/main.c
diff --git a/drivers/net/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
similarity index 100%
rename from drivers/net/mlx4/mcg.c
rename to drivers/net/ethernet/mellanox/mlx4/mcg.c
diff --git a/drivers/net/mlx4/mlx4.h b/drivers/net/ethernet/mellanox/mlx4/mlx4.h
similarity index 100%
rename from drivers/net/mlx4/mlx4.h
rename to drivers/net/ethernet/mellanox/mlx4/mlx4.h
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
similarity index 100%
rename from drivers/net/mlx4/mlx4_en.h
rename to drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
diff --git a/drivers/net/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
similarity index 100%
rename from drivers/net/mlx4/mr.c
rename to drivers/net/ethernet/mellanox/mlx4/mr.c
diff --git a/drivers/net/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
similarity index 100%
rename from drivers/net/mlx4/pd.c
rename to drivers/net/ethernet/mellanox/mlx4/pd.c
diff --git a/drivers/net/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
similarity index 100%
rename from drivers/net/mlx4/port.c
rename to drivers/net/ethernet/mellanox/mlx4/port.c
diff --git a/drivers/net/mlx4/profile.c b/drivers/net/ethernet/mellanox/mlx4/profile.c
similarity index 100%
rename from drivers/net/mlx4/profile.c
rename to drivers/net/ethernet/mellanox/mlx4/profile.c
diff --git a/drivers/net/mlx4/qp.c b/drivers/net/ethernet/mellanox/mlx4/qp.c
similarity index 100%
rename from drivers/net/mlx4/qp.c
rename to drivers/net/ethernet/mellanox/mlx4/qp.c
diff --git a/drivers/net/mlx4/reset.c b/drivers/net/ethernet/mellanox/mlx4/reset.c
similarity index 100%
rename from drivers/net/mlx4/reset.c
rename to drivers/net/ethernet/mellanox/mlx4/reset.c
diff --git a/drivers/net/mlx4/sense.c b/drivers/net/ethernet/mellanox/mlx4/sense.c
similarity index 100%
rename from drivers/net/mlx4/sense.c
rename to drivers/net/ethernet/mellanox/mlx4/sense.c
diff --git a/drivers/net/mlx4/srq.c b/drivers/net/ethernet/mellanox/mlx4/srq.c
similarity index 100%
rename from drivers/net/mlx4/srq.c
rename to drivers/net/ethernet/mellanox/mlx4/srq.c
-- 
1.7.5.4

