From: Joao Pinto <Joao.Pinto@synopsys.com>
Subject: [PATCH net-next] net: stmicro: dwmac4 comments enhancement
Date: Mon, 23 Jan 2017 15:56:24 +0000
Message-ID: <4b0ae13cd5076f1830bae79e1ad9bd0542d0e2bf.1485186686.git.jpinto@synopsys.com>
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, Joao Pinto <Joao.Pinto@synopsys.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from us01smtprelay-2.synopsys.com ([198.182.60.111]:35504 "EHLO
        smtprelay.synopsys.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751335AbdAWP4j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 10:56:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds clarification about the HW Controller that the dwmac4 driver
package is targeting.

Signed-off-by: Joao Pinto <jpinto@synopsys.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c  | 4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 4 ++--
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h | 2 +-
 drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c   | 4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
index 202216c..d893da9 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_core.c
@@ -1,6 +1,6 @@
 /*
- * This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
- * DWC Ether MAC version 4.00  has been used for developing this code.
+ * This is the driver for the DesignWare Ethernet QoS Controller.
+ * For historical reasons it started in 4.x version.
  *
  * This only implements the mac core functions for this chip.
  *
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
index 8816515..1f94bd6 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c
@@ -1,6 +1,6 @@
 /*
- * This contains the functions to handle the descriptors for DesignWare databook
- * 4.xx.
+ * This contains the functions to handle the descriptors for the DesignWare
+ * Ethernet QoS Controller. For historical reasons it started in 4.x version.
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
index 9736c50..cfeb08a 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.h
@@ -1,6 +1,6 @@
 /*
  * Header File to describe the DMA descriptors and related definitions specific
- * for DesignWare databook 4.xx.
+ * for the DesignWare Ethernet QoS Controller
  *
  * Copyright (C) 2015  STMicroelectronics Ltd
  *
diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
index 377d1b4..301d01f 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac4_dma.c
@@ -1,6 +1,6 @@
 /*
- * This is the driver for the GMAC on-chip Ethernet controller for ST SoCs.
- * DWC Ether MAC version 4.xx  has been used for  developing this code.
+ * This is the driver for DesignWare Ethernet QoS Controller.
+ * For historical reasons it started in 4.x version.
  *
  * This contains the functions to handle the dma.
  *
-- 
2.9.3
