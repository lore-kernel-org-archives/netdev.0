From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.6.5 3/4] pcnet32 correct name display
Date: Mon, 5 Apr 2004 14:27:59 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200404052127.i35LRxW11003@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This displays the device name (eth%d) instead of the device type
when registering the interrupt handler.

--- linux-2.6.5/drivers/net/print.pcnet32.c	Mon Apr  5 11:48:47 2004
+++ linux-2.6.5/drivers/net/pcnet32.c	Mon Apr  5 11:48:56 2004
@@ -1180,7 +1180,7 @@
 
     if (dev->irq == 0 ||
 	request_irq(dev->irq, &pcnet32_interrupt,
-		    lp->shared_irq ? SA_SHIRQ : 0, lp->name, (void *)dev)) {
+		    lp->shared_irq ? SA_SHIRQ : 0, dev->name, (void *)dev)) {
 	return -EAGAIN;
     }
 

-- 
Don Fry
brazilnut@us.ibm.com
