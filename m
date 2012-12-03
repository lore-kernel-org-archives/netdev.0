From: Liming Wang <walimisdev@gmail.com>
Subject: [PATCH] stmmac: remove two repeated macros
Date: Mon,  3 Dec 2012 20:19:44 +0800
Message-ID: <1354537184-1423-1-git-send-email-walimisdev@gmail.com>
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38301 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751091Ab2LCMUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 07:20:08 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so1005987bkw.19
        for <netdev@vger.kernel.org>; Mon, 03 Dec 2012 04:20:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two macros have been defined twice, remove them.

Signed-off-by: Liming Wang <walimisdev@gmail.com>
---
 drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
index e49c9a0..d064d92 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac_dma.h
@@ -77,8 +77,6 @@
 #define DMA_STATUS_GPI		0x10000000	/* PMT interrupt */
 #define DMA_STATUS_GMI		0x08000000	/* MMC interrupt */
 #define DMA_STATUS_GLI		0x04000000	/* GMAC Line interface int */
-#define DMA_STATUS_GMI		0x08000000
-#define DMA_STATUS_GLI		0x04000000
 #define DMA_STATUS_EB_MASK	0x00380000	/* Error Bits Mask */
 #define DMA_STATUS_EB_TX_ABORT	0x00080000	/* Error Bits - TX Abort */
 #define DMA_STATUS_EB_RX_ABORT	0x00100000	/* Error Bits - RX Abort */
-- 
1.7.9.5
