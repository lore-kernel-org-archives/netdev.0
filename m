From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH TRIVIAL] net: amd8111e: Spelling s/recive/receive/
Date: Sun, 12 Jan 2014 14:02:52 +0100
Message-ID: <1389531772-6154-1-git-send-email-geert@linux-m68k.org>
Cc: Geert Uytterhoeven <geert+renesas@linux-m68k.org>
To: Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from juliette.telenet-ops.be ([195.130.137.74]:46558 "EHLO
	juliette.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751238AbaALNCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 08:02:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert+renesas@linux-m68k.org>

Signed-off-by: Geert Uytterhoeven <geert+renesas@linux-m68k.org>
---
 drivers/net/ethernet/amd/amd8111e.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.h b/drivers/net/ethernet/amd/amd8111e.h
index 8baa3527ba74..be19c3058d69 100644
--- a/drivers/net/ethernet/amd/amd8111e.h
+++ b/drivers/net/ethernet/amd/amd8111e.h
@@ -753,7 +753,7 @@ struct amd8111e_priv{
 	const char *name;
 	struct pci_dev *pci_dev;	/* Ptr to the associated pci_dev */
 	struct net_device* amd8111e_net_dev; 	/* ptr to associated net_device */
-	/* Transmit and recive skbs */
+	/* Transmit and receive skbs */
 	struct sk_buff *tx_skbuff[NUM_TX_BUFFERS];
 	struct sk_buff *rx_skbuff[NUM_RX_BUFFERS];
 	/* Transmit and receive dma mapped addr */
-- 
1.7.9.5
