From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/6] net: bcmgenet: add missing blank line after declaration
Date: Tue, 22 Jul 2014 10:55:14 -0700
Message-ID: <1406051718-15883-3-git-send-email-f.fainelli@gmail.com>
References: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35478 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbaGVRzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 13:55:36 -0400
Received: by mail-pa0-f50.google.com with SMTP id et14so12460620pad.37
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 10:55:35 -0700 (PDT)
In-Reply-To: <1406051718-15883-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

checkpatch flagged a bunch of problems in bcmgenet.h with: WARNING:
Missing a blank line after declarations, fix them.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 2ef8673943de..73acc7c9b6df 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -438,6 +438,7 @@ struct bcmgenet_mib_counters {
 struct enet_cb {
 	struct sk_buff      *skb;
 	void __iomem *bd_addr;
+
 	DEFINE_DMA_UNMAP_ADDR(dma_addr);
 	DEFINE_DMA_UNMAP_LEN(dma_len);
 };
@@ -503,6 +504,7 @@ struct bcmgenet_tx_ring {
 	unsigned int	prod_index;	/* Tx ring producer index SW copy */
 	unsigned int	cb_ptr;		/* Tx ring initial CB ptr */
 	unsigned int	end_ptr;	/* Tx ring end CB ptr */
+
 	void (*int_enable)(struct bcmgenet_priv *priv,
 				struct bcmgenet_tx_ring *);
 	void (*int_disable)(struct bcmgenet_priv *priv,
-- 
1.9.1
