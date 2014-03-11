From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: [PATCH net-next v3 7/9] Altera TSE: Add Altera Ethernet Driver Makefile and Kconfig
Date: Tue, 11 Mar 2014 17:43:09 -0500
Message-ID: <1394577791-6547-8-git-send-email-vbridgers2013@gmail.com>
References: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
Cc: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	rob@landley.net, vbridgers2013@gmail.com
To: devicetree@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:62382 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056AbaCKWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 18:48:20 -0400
In-Reply-To: <1394577791-6547-1-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Altera Triple Speed Ethernet Makfile and
Kconfig file.

Signed-off-by: Vince Bridgers <vbridgers2013@gmail.com>
---
V3: - Reorder commits from V2, otherwise no changes to these files

V2: - Break up the driver files submission, no change to
      the Makefile or Kconfig file
---
 drivers/net/ethernet/altera/Kconfig  |    8 ++++++++
 drivers/net/ethernet/altera/Makefile |    7 +++++++
 2 files changed, 15 insertions(+)
 create mode 100644 drivers/net/ethernet/altera/Kconfig
 create mode 100644 drivers/net/ethernet/altera/Makefile

diff --git a/drivers/net/ethernet/altera/Kconfig b/drivers/net/ethernet/altera/Kconfig
new file mode 100644
index 0000000..80c1ab7
--- /dev/null
+++ b/drivers/net/ethernet/altera/Kconfig
@@ -0,0 +1,8 @@
+config ALTERA_TSE
+	tristate "Altera Triple-Speed Ethernet MAC support"
+	select PHYLIB
+	---help---
+	  This driver supports the Altera Triple-Speed (TSE) Ethernet MAC.
+
+	  To compile this driver as a module, choose M here. The module
+	  will be called alteratse.
diff --git a/drivers/net/ethernet/altera/Makefile b/drivers/net/ethernet/altera/Makefile
new file mode 100644
index 0000000..d4a187e
--- /dev/null
+++ b/drivers/net/ethernet/altera/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Altera device drivers.
+#
+
+obj-$(CONFIG_ALTERA_TSE) += altera_tse.o
+altera_tse-objs := altera_tse_main.o altera_tse_ethtool.o \
+altera_msgdma.o altera_sgdma.o altera_utils.o
-- 
1.7.9.5
