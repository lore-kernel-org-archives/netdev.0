From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 01/71] drivers/net/ethernet: Add ethernet dir and config option
Date: Sat, 30 Jul 2011 20:26:20 -0700
Message-ID: <1312082850-24914-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:27579 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752686Ab1GaD1g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 Jul 2011 23:27:36 -0400
In-Reply-To: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/Makefile |    3 +++
 4 files changed, 20 insertions(+), 1 deletions(-)
 create mode 100644 drivers/net/ethernet/Kconfig
 create mode 100644 drivers/net/ethernet/Makefile

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 8d0314d..5b95796 100644
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
index e1eca2a..670b514 100644
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
index 0000000..0d21dda
--- /dev/null
+++ b/drivers/net/ethernet/Makefile
@@ -0,0 +1,3 @@
+#
+# Makefile for the Linux network Ethernet device drivers.
+#
-- 
1.7.6

