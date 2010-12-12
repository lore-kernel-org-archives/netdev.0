From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 1/6] drivers/net: Add directory ethernet
Date: Sun, 12 Dec 2010 04:03:22 -0800
Message-ID: <ca0d9a13864803217f53ca4798efe026d420a75e.1292154142.git.joe@perches.com>
References: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2507 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738Ab0LLMDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:34 -0500
In-Reply-To: <cover.1292154142.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add empty Kconfig files for various speeds and a no effect Makefile.
Modify drivers/net Kconfig and Makefile to include these new files.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/Kconfig                 |    6 ++++++
 drivers/net/Makefile                |    2 ++
 drivers/net/ethernet/Kconfig.10-100 |    3 +++
 drivers/net/ethernet/Kconfig.1000   |    3 +++
 drivers/net/ethernet/Kconfig.10000  |    3 +++
 drivers/net/ethernet/Makefile       |    9 +++++++++
 6 files changed, 26 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/ethernet/Kconfig.10-100
 create mode 100644 drivers/net/ethernet/Kconfig.1000
 create mode 100644 drivers/net/ethernet/Kconfig.10000
 create mode 100644 drivers/net/ethernet/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a20693f..c1d1be8 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -222,6 +222,8 @@ menuconfig NET_ETHERNET
 
 if NET_ETHERNET
 
+source "drivers/net/ethernet/Kconfig.10-100"
+
 config MACB
 	tristate "Atmel MACB support"
 	depends on HAVE_NET_MACB
@@ -2041,6 +2043,8 @@ menuconfig NETDEV_1000
 
 if NETDEV_1000
 
+source "drivers/net/ethernet/Kconfig.1000"
+
 config ACENIC
 	tristate "Alteon AceNIC/3Com 3C985/NetGear GA620 Gigabit support"
 	depends on PCI
@@ -2569,6 +2573,8 @@ menuconfig NETDEV_10000
 
 if NETDEV_10000
 
+source "drivers/net/ethernet/Kconfig.10000"
+
 config MDIO
 	tristate
 
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 652fc6b..bfb5ade 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -2,6 +2,8 @@
 # Makefile for the Linux network (ethercard) device drivers.
 #
 
+obj-y += ethernet/
+
 obj-$(CONFIG_MII) += mii.o
 obj-$(CONFIG_MDIO) += mdio.o
 obj-$(CONFIG_PHYLIB) += phy/
diff --git a/drivers/net/ethernet/Kconfig.10-100 b/drivers/net/ethernet/Kconfig.10-100
new file mode 100644
index 0000000..8b1ee80
--- /dev/null
+++ b/drivers/net/ethernet/Kconfig.10-100
@@ -0,0 +1,3 @@
+#
+# 10 Mb and 100Mb ethernet device configuration
+#
diff --git a/drivers/net/ethernet/Kconfig.1000 b/drivers/net/ethernet/Kconfig.1000
new file mode 100644
index 0000000..f51b97c
--- /dev/null
+++ b/drivers/net/ethernet/Kconfig.1000
@@ -0,0 +1,3 @@
+#
+# 1 Gb ethernet device configuration
+#
diff --git a/drivers/net/ethernet/Kconfig.10000 b/drivers/net/ethernet/Kconfig.10000
new file mode 100644
index 0000000..a8e28fe
--- /dev/null
+++ b/drivers/net/ethernet/Kconfig.10000
@@ -0,0 +1,3 @@
+#
+# 10 Gb ethernet device configuration
+#
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
new file mode 100644
index 0000000..f2aebec
--- /dev/null
+++ b/drivers/net/ethernet/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for ethernet device drivers
+#
+
+# Dummy object just to avoid breaking build
+# These comments and the line below will be deleted on the
+# first addition to this file
+
+obj-$(CONFIG_ETHERNET_DUMMY_DRIVER) += /dev/null/dummy.o
-- 
1.7.3.3.398.g0b0cd.dirty

