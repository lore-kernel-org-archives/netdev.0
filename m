From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 2/5] atl1: fix typo in DMA engine setup
Date: Thu, 19 Jul 2007 18:45:11 -0500
Message-ID: <11848887141896-git-send-email-jacliburn@bellsouth.net>
References: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, csnook@redhat.com,
	Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf17aec.mail.bellsouth.net ([205.152.59.65]:61175 "EHLO
	imf17aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759371AbXGSXpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2007 19:45:17 -0400
In-Reply-To: <1184888714454-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DMA engine setup contains a typo that can result in an incorrect
dmaw_block setting.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 79d60e1..3b8f633 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -908,8 +908,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* config DMA Engine */
 	value = ((((u32) hw->dmar_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
 		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) |
-		((((u32) hw->dmaw_block) & DMA_CTRL_DMAR_BURST_LEN_MASK)
-		<< DMA_CTRL_DMAR_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
+		((((u32) hw->dmaw_block) & DMA_CTRL_DMAW_BURST_LEN_MASK)
+		<< DMA_CTRL_DMAW_BURST_LEN_SHIFT) | DMA_CTRL_DMAR_EN |
 		DMA_CTRL_DMAW_EN;
 	value |= (u32) hw->dma_ord;
 	if (atl1_rcb_128 == hw->rcb_value)
-- 
1.5.2.2

