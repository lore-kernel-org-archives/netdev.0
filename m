From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT in meth
Date: Sun, 22 Feb 2004 20:01:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222190106.GC28350@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.3/drivers/net/meth.c	Sat Jan 10 16:43:38 2004
+++ edited/drivers/net/meth.c	Sun Feb 22 20:31:23 2004
@@ -356,8 +356,6 @@
 	meth_private *priv=dev->priv;
 	volatile meth_regs *regs=priv->regs;
 
-	MOD_INC_USE_COUNT;
-
 	/* Start DMA */
 	regs->dma_ctrl|=
 	        METH_DMA_TX_EN|/*METH_DMA_TX_INT_EN|*/
@@ -380,7 +378,6 @@
 		~(METH_DMA_TX_EN|METH_DMA_TX_INT_EN|
 		METH_DMA_RX_EN|METH_DMA_RX_INT_EN);
 	free_irq(dev->irq, dev);
-    MOD_DEC_USE_COUNT;
     return 0;
 }
 
