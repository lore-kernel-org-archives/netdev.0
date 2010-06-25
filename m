From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH 8/9] cxgb4vf: Add new Makefile for T4 PCI-E SR-IOV Virtual Function driver cxgb4vf
Date: Fri, 25 Jun 2010 15:14:57 -0700
Message-ID: <201006251514.57894.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:6944 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563Ab0FYWO6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 18:14:58 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5PMEx0g019443
	for <netdev@vger.kernel.org>; Fri, 25 Jun 2010 15:14:59 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add new Makefile for T4 PCI-E SR-IOV Virtual Function driver "cxgb4vf".

Signed-off-by: Casey Leedom
---
 drivers/net/cxgb4vf/Makefile |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4vf/Makefile b/drivers/net/cxgb4vf/Makefile
new file mode 100644
index 0000000..d72ee26
--- /dev/null
+++ b/drivers/net/cxgb4vf/Makefile
@@ -0,0 +1,7 @@
+#
+# Chelsio T4 SR-IOV Virtual Function Driver
+#
+
+obj-$(CONFIG_CHELSIO_T4VF) += cxgb4vf.o
+
+cxgb4vf-objs := cxgb4vf_main.o t4vf_hw.o sge.o
