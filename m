From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH 3/3] cxgb4: update Kconfig and Makefile for FCoE support
Date: Tue, 24 Mar 2015 19:14:47 +0530
Message-ID: <937d9cc4ca4fa6a2da26442e2c5162ee16cec67e.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, leedom@chelsio.com,
	anish@chelsio.com, hariprasad@chelsio.com, praveenm@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:3664 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752160AbbCXNqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:46:12 -0400
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
In-Reply-To: <cover.1427199268.git.varun@chelsio.com>
References: <cover.1427199268.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig        |   11 +++++++++++
 drivers/net/ethernet/chelsio/cxgb4/Makefile |    1 +
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index ac6473f..7daa088 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -97,6 +97,17 @@ config CHELSIO_T4_DCB
 
 	  If unsure, say N.
 
+config CHELSIO_T4_FCOE
+	bool "Fibre Channel over Ethernet (FCoE) Support for Chelsio T5 cards"
+	default n
+	depends on CHELSIO_T4 && CHELSIO_T4_DCB && FCOE
+	---help---
+	  Enable FCoE offload features.
+	  Say Y here if you want to enable Fibre Channel over Ethernet (FCoE) support
+	  in the driver.
+
+	  If unsure, say N.
+
 config CHELSIO_T4VF
 	tristate "Chelsio Communications T4/T5 Virtual Function Ethernet support"
 	depends on PCI
diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index ae50cd7..07d9b68 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -6,4 +6,5 @@ obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
 cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
+cxgb4-$(CONFIG_CHELSIO_T4_FCOE) +=  cxgb4_fcoe.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
-- 
1.7.1
