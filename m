From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4 : Makefile & Kconfig changes for DCBx support
Date: Thu, 19 Jun 2014 15:22:10 -0700
Message-ID: <1403216531-7874-5-git-send-email-anish@chelsio.com>
References: <1403216531-7874-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:35735
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S965467AbaFSXYg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2014 19:24:36 -0400
In-Reply-To: <1403216531-7874-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/Kconfig        | 11 +++++++++++
 drivers/net/ethernet/chelsio/cxgb4/Makefile |  1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/Kconfig b/drivers/net/ethernet/chelsio/Kconfig
index 570222c..c3ce9df 100644
--- a/drivers/net/ethernet/chelsio/Kconfig
+++ b/drivers/net/ethernet/chelsio/Kconfig
@@ -86,6 +86,17 @@ config CHELSIO_T4
 	  To compile this driver as a module choose M here; the module
 	  will be called cxgb4.
 
+config CHELSIO_T4_DCB
+	bool "Data Center Bridging (DCB) Support for Chelsio T4/T5 cards"
+	default n
+	depends on CHELSIO_T4 && DCB
+	---help---
+	  Enable DCB support through rtNetlink interface.
+	  Say Y here if you want to enable Data Center Bridging (DCB) support
+	  in the driver.
+
+	  If unsure, say N.
+
 config CHELSIO_T4VF
 	tristate "Chelsio Communications T4/T5 Virtual Function Ethernet support"
 	depends on PCI
diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index 4986674..1df65c9 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -5,3 +5,4 @@
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
 cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o
+cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
-- 
2.0.0
