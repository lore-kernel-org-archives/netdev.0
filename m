From: bora.sahin@ttnet.net.tr
Subject: [PATCH 7/12] smc911x: Fix a few DBG macros
Date: Wed, 13 Sep 2006 21:09:55 +0300
Message-ID: <200609132109.55467.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:56699 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751060AbWIMSfD
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:35:03 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some cosmetic around DBG macros...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -389,7 +388,7 @@
 	unsigned cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	/* Disable IRQ's */
 	SMC_SET_INT_EN(0);
@@ -408,7 +407,7 @@
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int fifo_count, timeout, reg;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", dev->name, __FUNCTION__);
 	fifo_count = SMC_GET_RX_FIFO_INF() & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
@@ -861,7 +857,7 @@
 	unsigned long flags;
 	unsigned int reg;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	reg = SMC_GET_PMT_CTRL();
