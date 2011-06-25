From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC 01/72] drivers/net/ethernet: Add ethernet dir and config option
Date: Sat, 25 Jun 2011 06:58:12 -0700
Message-ID: <1309010363-22750-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44842 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751605Ab1FYN72 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Jun 2011 09:59:28 -0400
In-Reply-To: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the initial patch to organize the drivers/net directory
structure and networking device driver config options.  This patch
does the following:
  - add drivers/net/ethernet/Kconfig
  - integrate the new files into the existing config

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/Kconfig           |    2 ++
 drivers/net/Makefile          |    2 +-
 drivers/net/ethernet/Kconfig  |   14 ++++++++++++++
 drivers/net/ethernet/Makefile |    4 ++++
 4 files changed, 21 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/Kconfig
 create mode 100644 drivers/net/ethernet/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f5919c2..32aa191 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -193,6 +193,8 @@ source "drivers/net/phy/Kconfig"
 #	Ethernet
 #
 
+source "drivers/net/ethernet/Kconfig"
+
 menuconfig NET_ETHERNET
 	bool "Ethernet (10 or 100Mbit)"
 	depends on !UML
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 86f6c8d..848f95a 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -1,5 +1,5 @@
 #
-# Makefile for the Linux network (ethercard) device drivers.
+# Makefile for the Linux network device drivers.
 #
 
 obj-$(CONFIG_MII) += mii.o
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
new file mode 100644
index 0000000..d59e4f2
--- /dev/null
+++ b/drivers/net/ethernet/Kconfig
@@ -0,0 +1,14 @@
+#
+# Ethernet LAN device configuration
+#
+
+menuconfig ETHERNET
+	bool "Ethernet driver support"
+	depends on NET
+	default y
+	---help---
+	  This section contains all the Ethernet device drivers.
+
+if ETHERNET
+
+endif # ETHERNET
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
new file mode 100644
index 0000000..d52694b
--- /dev/null
+++ b/drivers/net/ethernet/Makefile
@@ -0,0 +1,4 @@
+#
+# Makefile for the Linux network Ethernet device drivers.
+#
+
-- 
1.7.5.4

