From: ggrundstrom@neteffect.com
Subject: [PATCH 14/14] nes: kernel build infrastructure
Date: Tue, 7 Aug 2007 20:25:31 -0500
Message-ID: <200708080125.l781PVIM004915@neteffect.com>
Cc: ewg@lists.openfabrics.org, ggrundstrom@neteffect.com,
	netdev@vger.kernel.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75.neteffect.com ([204.57.75.75]:52703 "EHLO
	localhost.localdomain" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S934501AbXHHBb7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 21:31:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Makefile kernel build file.

Signed-off-by: Glenn Grundstrom <ggrundstrom@neteffect.com>
---
diff -Nurp NULL ofa_kernel-1.2/drivers/infiniband/hw/nes/Makefile
--- NULL	1969-12-31 18:00:00.000000000 -0600
+++ ofa_kernel-1.2/drivers/infiniband/hw/nes/Makefile	2007-08-06 20:09:04.000000000 -0500
@@ -0,0 +1,10 @@
+ifdef CONFIG_INFINIBAND_NES_DEBUG
+EXTRA_CFLAGS += -DNES_DEBUG
+endif
+
+EXTRA_CFLAGS += -DNES_MINICM
+
+obj-$(CONFIG_INFINIBAND_NES) += iw_nes.o
+
+iw_nes-objs := nes.o nes_hw.o nes_nic.o nes_utils.o nes_verbs.o nes_cm.o
+
