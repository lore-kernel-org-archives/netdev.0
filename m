From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 1/4] stmmac: fix the EEE LPI Macro definitions.
Date: Thu, 28 Aug 2014 08:11:41 +0200
Message-ID: <1409206304-23239-2-git-send-email-peppe.cavallaro@st.com>
References: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, nandini sharma <nandini.sharma@st.com>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00178001.pphosted.com ([91.207.212.93]:34988 "EHLO
	mx08-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754872AbaH1GLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 02:11:54 -0400
In-Reply-To: <1409206304-23239-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: nandini sharma <nandini.sharma@st.com>

This patch is to fix the definition of macros for EEE otherwise the LPI TX/RX
entry/exit cannot be properly managed.

Signed-off-by: Nandini Sharma <nandini.sharma@st.com>
Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
---
 drivers/net/ethernet/stmicro/stmmac/common.h |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index de507c3..a464e8c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -220,10 +220,10 @@ enum dma_irq_status {
 	handle_tx = 0x8,
 };
 
-#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 1)
-#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 2)
-#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 3)
-#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 4)
+#define	CORE_IRQ_TX_PATH_IN_LPI_MODE	(1 << 0)
+#define	CORE_IRQ_TX_PATH_EXIT_LPI_MODE	(1 << 1)
+#define	CORE_IRQ_RX_PATH_IN_LPI_MODE	(1 << 2)
+#define	CORE_IRQ_RX_PATH_EXIT_LPI_MODE	(1 << 3)
 
 #define	CORE_PCS_ANE_COMPLETE		(1 << 5)
 #define	CORE_PCS_LINK_STATUS		(1 << 6)
-- 
1.7.4.4
