From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT in lasi_82596.c
Date: Sun, 22 Feb 2004 19:35:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222183504.GA28040@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.22/drivers/net/lasi_82596.c	Sat Jan 10 16:34:11 2004
+++ edited/drivers/net/lasi_82596.c	Sun Feb 22 20:30:38 2004
@@ -1016,8 +1016,6 @@
 {
 	DEB(DEB_OPEN,printk("%s: i596_open() irq %d.\n", dev->name, dev->irq));
 
-	MOD_INC_USE_COUNT;
-
 	if (request_irq(dev->irq, &i596_interrupt, 0, "i82596", dev)) {
 		printk("%s: IRQ %d not free\n", dev->name, dev->irq);
 		goto out;
@@ -1038,8 +1036,6 @@
 	remove_rx_bufs(dev);
 	free_irq(dev->irq, dev);
 out:
-	MOD_DEC_USE_COUNT;
-
 	return -EAGAIN;
 }
 
