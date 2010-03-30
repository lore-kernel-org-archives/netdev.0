From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 6/6] net: Hook up cxgb4 to Kconfig and Makefile
Date: Tue, 30 Mar 2010 10:52:22 -0800
Message-ID: <1269975142-30896-7-git-send-email-dm@chelsio.com>
References: <1269975142-30896-1-git-send-email-dm@chelsio.com>
 <1269975142-30896-2-git-send-email-dm@chelsio.com>
 <1269975142-30896-3-git-send-email-dm@chelsio.com>
 <1269975142-30896-4-git-send-email-dm@chelsio.com>
 <1269975142-30896-5-git-send-email-dm@chelsio.com>
 <1269975142-30896-6-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:17499 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755506Ab0C3SwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 14:52:24 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o2UIqOMc011247
	for <netdev@vger.kernel.org>; Tue, 30 Mar 2010 11:52:24 -0700
In-Reply-To: <1269975142-30896-6-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/Kconfig  |   25 +++++++++++++++++++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4f1f974..944ffd1 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2582,6 +2582,31 @@ config CHELSIO_T3
 	  To compile this driver as a module, choose M here: the module
 	  will be called cxgb3.
 
+config CHELSIO_T4_DEPENDS
+	tristate
+	depends on PCI && INET
+	default y
+
+config CHELSIO_T4
+	tristate "Chelsio Communications T4 Ethernet support"
+	depends on CHELSIO_T4_DEPENDS
+	select FW_LOADER
+	select MDIO
+	help
+	  This driver supports Chelsio T4-based gigabit and 10Gb Ethernet
+	  adapters.
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
+	  will be called cxgb4.
+
 config EHEA
 	tristate "eHEA Ethernet support"
 	depends on IBMEBUS && INET && SPARSEMEM
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 4788862..a583b50 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_IP1000) += ipg.o
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
+obj-$(CONFIG_CHELSIO_T4) += cxgb4/
 obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
-- 
1.5.4

