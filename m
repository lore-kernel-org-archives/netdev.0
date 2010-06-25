From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 9/9] cxgb4vf: Stitch new T4 PCI-E SR-IOV Virtual Function driver into the build
Date: Fri, 25 Jun 2010 15:15:33 -0700
Message-ID: <201006251515.33641.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25959 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756801Ab0FYWPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:15:34 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMFZf8019458
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:15:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stitch new T4 PCI-E SR-IOV Virtual Function driver into the build.

Signed-off-by: Casey Leedom
---
 drivers/net/Kconfig  |   23 +++++++++++++++++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 71e6f8f..ec7f8b9 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2602,6 +2602,29 @@ config CHELSIO_T4
 	  To compile this driver as a module choose M here; the module
 	  will be called cxgb4.
 
+config CHELSIO_T4VF_DEPENDS
+	tristate
+	depends on PCI && INET
+	default y
+
+config CHELSIO_T4VF
+	tristate "Chelsio Communications T4 Virtual Function Ethernet support"
+	depends on CHELSIO_T4VF_DEPENDS
+	help
+	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
+	  adapters with PCI-E SR-IOV Virtual Functions.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.htm>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module choose M here; the module
+	  will be called cxgb4vf.
+
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS && INET && SPARSEMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 0a0512a..49384ca 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_CHELSIO_T4) += cxgb4/
+obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf/
 obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
