From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] remove useless MOD_{INC,DEC}_USE_COUNT in sun3lance
Date: Sun, 22 Feb 2004 19:57:55 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040222185755.GA28350@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--- 1.17/drivers/net/sun3lance.c	Sat Jan 10 16:37:56 2004
+++ edited/drivers/net/sun3lance.c	Sun Feb 22 20:31:10 2004
@@ -430,7 +430,6 @@
 	netif_start_queue(dev);
 	
 	DPRINTK( 2, ( "%s: LANCE is open, csr0 %04x\n", dev->name, DREG ));
-	MOD_INC_USE_COUNT;
 
 	return( 0 );
 }
@@ -880,8 +879,6 @@
 	/* We stop the LANCE here -- it occasionally polls
 	   memory if we don't. */
 	DREG = CSR0_STOP;
-
-	MOD_DEC_USE_COUNT;
 	return 0;
 }
 
