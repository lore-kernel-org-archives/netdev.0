From: ggrundstrom@neteffect.com
Subject: [PATCH 13/14] nes: kernel build infrastructure
Date: Tue, 7 Aug 2007 20:23:51 -0500
Message-ID: <200708080123.l781NpKJ004903@neteffect.com>
Cc: ewg@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:52545 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S935013AbXHHBaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig kernel build file.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/Kconfig
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/Kconfig	2007-08-06 20:09:04.000000000 -0500
@@ -0,0 +1,15 @@
+config INFINIBAND_NES
+	tristate "NetEffect RNIC Driver"
+	depends on PCI && INET && INFINIBAND
+	---help---
+	  This is a low-level driver for NetEffect RDMA enabled
+	  Network Interface Cards (RNIC).
+
+config INFINIBAND_NES_DEBUG
+	bool "Verbose debugging output"
+	depends on INFINIBAND_NES
+	default n
+	---help---
+	  This option causes the NetEffect RNIC driver to produce debug
+	  messages.  Select this if you are developing the driver
+	  or trying to diagnose a problem.
