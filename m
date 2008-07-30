From: akpm@linux-foundation.org
Subject: [patch 09/11] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 12:37:42 -0700
Message-ID: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com, samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33479 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752011AbYG3TxR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:53:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/irda/act200l-sir.c    |   10 -
 drivers/net/irda/actisys-sir.c    |    2 
 drivers/net/irda/ali-ircc.c       |  246 ++++++++++++++--------------
 drivers/net/irda/donauboe.c       |   68 +++----
 drivers/net/irda/girbil-sir.c     |   12 -
 drivers/net/irda/irda-usb.c       |   92 +++++-----
 drivers/net/irda/irtty-sir.c      |   10 -
 drivers/net/irda/kingsun-sir.c    |    2 
 drivers/net/irda/litelink-sir.c   |    8 
 drivers/net/irda/ma600-sir.c      |   16 -
 drivers/net/irda/mcp2120-sir.c    |   12 -
 drivers/net/irda/nsc-ircc.c       |  112 ++++++------
 drivers/net/irda/old_belkin-sir.c |    8 
 drivers/net/irda/sir_dev.c        |   62 +++----
 drivers/net/irda/sir_dongle.c     |    2 
 drivers/net/irda/smsc-ircc2.c     |  120 ++++++-------
 drivers/net/irda/tekram-sir.c     |   10 -
 drivers/net/irda/toim3232-sir.c   |   10 -
 drivers/net/irda/via-ircc.c       |   80 ++++-----
 drivers/net/irda/vlsi_ir.c        |   92 +++++-----
 drivers/net/irda/vlsi_ir.h        |    2 
 drivers/net/irda/w83977af_ir.c    |   62 +++----
 22 files changed, 519 insertions(+), 519 deletions(-)

diff -puN drivers/net/irda/act200l-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/act200l-sir.c
--- a/drivers/net/irda/act200l-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/act200l-sir.c
@@ -107,7 +107,7 @@ static int act200l_open(struct sir_dev *
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Power on the dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -124,7 +124,7 @@ static int act200l_open(struct sir_dev *
 
 static int act200l_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Power off the dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -143,7 +143,7 @@ static int act200l_change_speed(struct s
 	u8 control[3];
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Clear DTR and set RTS to enter command mode */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
@@ -212,7 +212,7 @@ static int act200l_reset(struct sir_dev 
 	};
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -240,7 +240,7 @@ static int act200l_reset(struct sir_dev 
 		dev->speed = 9600;
 		break;
 	default:
-		IRDA_ERROR("%s(), unknown state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), unknown state %d\n", __func__, state);
 		ret = -1;
 		break;
 	}
diff -puN drivers/net/irda/actisys-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/actisys-sir.c
--- a/drivers/net/irda/actisys-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/actisys-sir.c
@@ -165,7 +165,7 @@ static int actisys_change_speed(struct s
 	int ret = 0;
 	int i = 0;
 
-        IRDA_DEBUG(4, "%s(), speed=%d (was %d)\n", __FUNCTION__,
+        IRDA_DEBUG(4, "%s(), speed=%d (was %d)\n", __func__,
         	speed, dev->speed);
 
 	/* dongle was already resetted from irda_request state machine,
diff -puN drivers/net/irda/ali-ircc.c~irda-replace-__function__-with-__func__ drivers/net/irda/ali-ircc.c
--- a/drivers/net/irda/ali-ircc.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/ali-ircc.c
@@ -152,7 +152,7 @@ static int __init ali_ircc_init(void)
 	int reg, revision;
 	int i = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 
 	ret = platform_driver_register(&ali_ircc_driver);
         if (ret) {
@@ -166,7 +166,7 @@ static int __init ali_ircc_init(void)
 	/* Probe for all the ALi chipsets we know about */
 	for (chip= chips; chip->name; chip++, i++) 
 	{
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__, chip->name);
+		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__, chip->name);
 				
 		/* Try all config registers for this chip */
 		for (cfg=0; cfg<2; cfg++)
@@ -196,11 +196,11 @@ static int __init ali_ircc_init(void)
 				
 			if (reg == chip->cid_value)
 			{
-				IRDA_DEBUG(2, "%s(), Chip found at 0x%03x\n", __FUNCTION__, cfg_base);
+				IRDA_DEBUG(2, "%s(), Chip found at 0x%03x\n", __func__, cfg_base);
 					   
 				outb(0x1F, cfg_base);
 				revision = inb(cfg_base+1);
-				IRDA_DEBUG(2, "%s(), Found %s chip, revision=%d\n", __FUNCTION__,
+				IRDA_DEBUG(2, "%s(), Found %s chip, revision=%d\n", __func__,
 					   chip->name, revision);					
 				
 				/* 
@@ -223,14 +223,14 @@ static int __init ali_ircc_init(void)
 			}
 			else
 			{
-				IRDA_DEBUG(2, "%s(), No %s chip at 0x%03x\n", __FUNCTION__, chip->name, cfg_base);
+				IRDA_DEBUG(2, "%s(), No %s chip at 0x%03x\n", __func__, chip->name, cfg_base);
 			}
 			/* Exit configuration */
 			outb(0xbb, cfg_base);
 		}
 	}		
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);					   		
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 
 	if (ret)
 		platform_driver_unregister(&ali_ircc_driver);
@@ -248,7 +248,7 @@ static void __exit ali_ircc_cleanup(void
 {
 	int i;
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
@@ -257,7 +257,7 @@ static void __exit ali_ircc_cleanup(void
 	
 	platform_driver_unregister(&ali_ircc_driver);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 }
 
 /*
@@ -273,11 +273,11 @@ static int ali_ircc_open(int i, chipio_t
 	int dongle_id;
 	int err;
 			
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 
 	if (i >= ARRAY_SIZE(dev_self)) {
 		IRDA_ERROR("%s(), maximum number of supported chips reached!\n",
-			   __FUNCTION__);
+			   __func__);
 		return -ENOMEM;
 	}
 	
@@ -288,7 +288,7 @@ static int ali_ircc_open(int i, chipio_t
 	dev = alloc_irdadev(sizeof(*self));
 	if (dev == NULL) {
 		IRDA_ERROR("%s(), can't allocate memory for control block!\n",
-			   __FUNCTION__);
+			   __func__);
 		return -ENOMEM;
 	}
 
@@ -312,7 +312,7 @@ static int ali_ircc_open(int i, chipio_t
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext,
 			    ALI_IRCC_DRIVER_NAME)) {
-		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __FUNCTION__,
+		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __func__,
 			self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
@@ -370,19 +370,19 @@ static int ali_ircc_open(int i, chipio_t
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
 		goto err_out4;
 	}
 	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
 
 	/* Check dongle id */
 	dongle_id = ali_ircc_read_dongle_id(i, info);
-	IRDA_MESSAGE("%s(), %s, Found dongle: %s\n", __FUNCTION__,
+	IRDA_MESSAGE("%s(), %s, Found dongle: %s\n", __func__,
 		     ALI_IRCC_DRIVER_NAME, dongle_types[dongle_id]);
 		
 	self->io.dongle_id = dongle_id;
 
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;
 
@@ -411,7 +411,7 @@ static int __exit ali_ircc_close(struct 
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -421,7 +421,7 @@ static int __exit ali_ircc_close(struct 
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", __FUNCTION__, self->io.fir_base);
+	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -435,7 +435,7 @@ static int __exit ali_ircc_close(struct 
 	dev_self[self->index] = NULL;
 	free_netdev(self->netdev);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;
 }
@@ -478,7 +478,7 @@ static int ali_ircc_probe_53(ali_chip_t 
 	int cfg_base = info->cfg_base;
 	int hi, low, reg;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Enter Configuration */
 	outb(chip->entr1, cfg_base);
@@ -497,13 +497,13 @@ static int ali_ircc_probe_53(ali_chip_t 
 	
 	info->sir_base = info->fir_base;
 	
-	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __FUNCTION__, info->fir_base);
+	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __func__, info->fir_base);
 		
 	/* Read IRQ control register */
 	outb(0x70, cfg_base);
 	reg = inb(cfg_base+1);
 	info->irq = reg & 0x0f;
-	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __FUNCTION__, info->irq);
+	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __func__, info->irq);
 	
 	/* Read DMA channel */
 	outb(0x74, cfg_base);
@@ -511,26 +511,26 @@ static int ali_ircc_probe_53(ali_chip_t 
 	info->dma = reg & 0x07;
 	
 	if(info->dma == 0x04)
-		IRDA_WARNING("%s(), No DMA channel assigned !\n", __FUNCTION__);
+		IRDA_WARNING("%s(), No DMA channel assigned !\n", __func__);
 	else
-		IRDA_DEBUG(2, "%s(), probing dma=%d\n", __FUNCTION__, info->dma);
+		IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
 	
 	/* Read Enabled Status */
 	outb(0x30, cfg_base);
 	reg = inb(cfg_base+1);
 	info->enabled = (reg & 0x80) && (reg & 0x01);
-	IRDA_DEBUG(2, "%s(), probing enabled=%d\n", __FUNCTION__, info->enabled);
+	IRDA_DEBUG(2, "%s(), probing enabled=%d\n", __func__, info->enabled);
 	
 	/* Read Power Status */
 	outb(0x22, cfg_base);
 	reg = inb(cfg_base+1);
 	info->suspended = (reg & 0x20);
-	IRDA_DEBUG(2, "%s(), probing suspended=%d\n", __FUNCTION__, info->suspended);
+	IRDA_DEBUG(2, "%s(), probing suspended=%d\n", __func__, info->suspended);
 	
 	/* Exit configuration */
 	outb(0xbb, cfg_base);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;	
 }
@@ -548,7 +548,7 @@ static int ali_ircc_setup(chipio_t *info
 	int version;
 	int iobase = info->fir_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Locking comments :
 	 * Most operations here need to be protected. We are called before
@@ -609,7 +609,7 @@ static int ali_ircc_setup(chipio_t *info
 	// outb(UART_IER_RDI, iobase+UART_IER); //benjamin 2000/11/23 01:25PM
 	// Turn on the interrupts in ali_ircc_net_open
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	
 	return 0;
 }
@@ -626,7 +626,7 @@ static int ali_ircc_read_dongle_id (int 
 	int dongle_id, reg;
 	int cfg_base = info->cfg_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	/* Enter Configuration */
 	outb(chips[i].entr1, cfg_base);
@@ -640,13 +640,13 @@ static int ali_ircc_read_dongle_id (int 
 	outb(0xf0, cfg_base);
 	reg = inb(cfg_base+1);	
 	dongle_id = ((reg>>6)&0x02) | ((reg>>5)&0x01);
-	IRDA_DEBUG(2, "%s(), probing dongle_id=%d, dongle_types=%s\n", __FUNCTION__, 
+	IRDA_DEBUG(2, "%s(), probing dongle_id=%d, dongle_types=%s\n", __func__,
 		dongle_id, dongle_types[dongle_id]);
 	
 	/* Exit configuration */
 	outb(0xbb, cfg_base);
 			
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	
 	return dongle_id;
 }
@@ -663,7 +663,7 @@ static irqreturn_t ali_ircc_interrupt(in
 	struct ali_ircc_cb *self;
 	int ret;
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	self = dev->priv;
 	
@@ -677,7 +677,7 @@ static irqreturn_t ali_ircc_interrupt(in
 		
 	spin_unlock(&self->lock);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	return ret;
 }
 /*
@@ -691,7 +691,7 @@ static irqreturn_t ali_ircc_fir_interrup
 	__u8 eir, OldMessageCount;
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.fir_base;
 	
@@ -704,10 +704,10 @@ static irqreturn_t ali_ircc_fir_interrup
 	//self->ier = inb(iobase+FIR_IER); 		2000/12/1 04:32PM
 	eir = self->InterruptID & self->ier; /* Mask out the interesting ones */ 
 	
-	IRDA_DEBUG(1, "%s(), self->InterruptID = %x\n", __FUNCTION__,self->InterruptID);
-	IRDA_DEBUG(1, "%s(), self->LineStatus = %x\n", __FUNCTION__,self->LineStatus);
-	IRDA_DEBUG(1, "%s(), self->ier = %x\n", __FUNCTION__,self->ier);
-	IRDA_DEBUG(1, "%s(), eir = %x\n", __FUNCTION__,eir);
+	IRDA_DEBUG(1, "%s(), self->InterruptID = %x\n", __func__,self->InterruptID);
+	IRDA_DEBUG(1, "%s(), self->LineStatus = %x\n", __func__,self->LineStatus);
+	IRDA_DEBUG(1, "%s(), self->ier = %x\n", __func__,self->ier);
+	IRDA_DEBUG(1, "%s(), eir = %x\n", __func__,eir);
 	
 	/* Disable interrupts */
 	 SetCOMInterrupts(self, FALSE);
@@ -718,7 +718,7 @@ static irqreturn_t ali_ircc_fir_interrup
 	{		
 		if (self->io.direction == IO_XMIT) /* TX */
 		{
-			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Tx) *******\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Tx) *******\n", __func__);
 			
 			if(ali_ircc_dma_xmit_complete(self))
 			{
@@ -737,23 +737,23 @@ static irqreturn_t ali_ircc_fir_interrup
 		}	
 		else /* RX */
 		{
-			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Rx) *******\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Rx) *******\n", __func__);
 			
 			if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 			{
 				self->rcvFramesOverflow = TRUE;	
-				IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******** \n", __FUNCTION__);
+				IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******** \n", __func__);
 			}
 						
 			if (ali_ircc_dma_receive_complete(self))
 			{
-				IRDA_DEBUG(1, "%s(), ******* receive complete ******** \n", __FUNCTION__);
+				IRDA_DEBUG(1, "%s(), ******* receive complete ******** \n", __func__);
 				
 				self->ier = IER_EOM;				
 			}
 			else
 			{
-				IRDA_DEBUG(1, "%s(), ******* Not receive complete ******** \n", __FUNCTION__);
+				IRDA_DEBUG(1, "%s(), ******* Not receive complete ******** \n", __func__);
 				
 				self->ier = IER_EOM | IER_TIMER;								
 			}	
@@ -766,7 +766,7 @@ static irqreturn_t ali_ircc_fir_interrup
 		if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 		{
 			self->rcvFramesOverflow = TRUE;	
-			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******* \n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******* \n", __func__);
 		}
 		/* Disable Timer */
 		switch_bank(iobase, BANK1);
@@ -798,7 +798,7 @@ static irqreturn_t ali_ircc_fir_interrup
 	/* Restore Interrupt */	
 	SetCOMInterrupts(self, TRUE);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ---------------\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s(), ----------------- End ---------------\n", __func__);
 	return IRQ_RETVAL(eir);
 }
 
@@ -813,7 +813,7 @@ static irqreturn_t ali_ircc_sir_interrup
 	int iobase;
 	int iir, lsr;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.sir_base;
 
@@ -822,13 +822,13 @@ static irqreturn_t ali_ircc_sir_interrup
 		/* Clear interrupt */
 		lsr = inb(iobase+UART_LSR);
 
-		IRDA_DEBUG(4, "%s(), iir=%02x, lsr=%02x, iobase=%#x\n", __FUNCTION__, 
+		IRDA_DEBUG(4, "%s(), iir=%02x, lsr=%02x, iobase=%#x\n", __func__,
 			   iir, lsr, iobase);
 
 		switch (iir) 
 		{
 			case UART_IIR_RLSI:
-				IRDA_DEBUG(2, "%s(), RLSI\n", __FUNCTION__);
+				IRDA_DEBUG(2, "%s(), RLSI\n", __func__);
 				break;
 			case UART_IIR_RDI:
 				/* Receive interrupt */
@@ -842,14 +842,14 @@ static irqreturn_t ali_ircc_sir_interrup
 				}				
 				break;
 			default:
-				IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n", __FUNCTION__, iir);
+				IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n", __func__, iir);
 				break;
 		} 
 		
 	}
 	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 
 	return IRQ_RETVAL(iir);
 }
@@ -866,7 +866,7 @@ static void ali_ircc_sir_receive(struct 
 	int boguscount = 0;
 	int iobase;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	iobase = self->io.sir_base;
@@ -881,12 +881,12 @@ static void ali_ircc_sir_receive(struct 
 
 		/* Make sure we don't stay here too long */
 		if (boguscount++ > 32) {
-			IRDA_DEBUG(2,"%s(), breaking!\n", __FUNCTION__);
+			IRDA_DEBUG(2,"%s(), breaking!\n", __func__);
 			break;
 		}
 	} while (inb(iobase+UART_LSR) & UART_LSR_DR);	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -903,7 +903,7 @@ static void ali_ircc_sir_write_wakeup(st
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	iobase = self->io.sir_base;
 
@@ -922,16 +922,16 @@ static void ali_ircc_sir_write_wakeup(st
 		{
 			/* We must wait until all data are gone */
 			while(!(inb(iobase+UART_LSR) & UART_LSR_TEMT))
-				IRDA_DEBUG(1, "%s(), UART_LSR_THRE\n", __FUNCTION__ );
+				IRDA_DEBUG(1, "%s(), UART_LSR_THRE\n", __func__ );
 			
-			IRDA_DEBUG(1, "%s(), Changing speed! self->new_speed = %d\n", __FUNCTION__ , self->new_speed);
+			IRDA_DEBUG(1, "%s(), Changing speed! self->new_speed = %d\n", __func__ , self->new_speed);
 			ali_ircc_change_speed(self, self->new_speed);
 			self->new_speed = 0;			
 			
 			// benjamin 2000/11/10 06:32PM
 			if (self->io.speed > 115200)
 			{
-				IRDA_DEBUG(2, "%s(), ali_ircc_change_speed from UART_LSR_TEMT \n", __FUNCTION__ );				
+				IRDA_DEBUG(2, "%s(), ali_ircc_change_speed from UART_LSR_TEMT \n", __func__ );
 					
 				self->ier = IER_EOM;
 				// SetCOMInterrupts(self, TRUE);							
@@ -949,7 +949,7 @@ static void ali_ircc_sir_write_wakeup(st
 		outb(UART_IER_RDI, iobase+UART_IER);
 	}
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
@@ -957,9 +957,9 @@ static void ali_ircc_change_speed(struct
 	struct net_device *dev = self->netdev;
 	int iobase;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(2, "%s(), setting speed = %d \n", __FUNCTION__ , baud);
+	IRDA_DEBUG(2, "%s(), setting speed = %d \n", __func__ , baud);
 	
 	/* This function *must* be called with irq off and spin-lock.
 	 * - Jean II */
@@ -998,7 +998,7 @@ static void ali_ircc_change_speed(struct
 		
 	netif_wake_queue(self->netdev);	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
@@ -1008,14 +1008,14 @@ static void ali_ircc_fir_change_speed(st
 	struct ali_ircc_cb *self = (struct ali_ircc_cb *) priv;
 	struct net_device *dev;
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	IRDA_ASSERT(self != NULL, return;);
 
 	dev = self->netdev;
 	iobase = self->io.fir_base;
 	
-	IRDA_DEBUG(1, "%s(), self->io.speed = %d, change to speed = %d\n", __FUNCTION__ ,self->io.speed,baud);
+	IRDA_DEBUG(1, "%s(), self->io.speed = %d, change to speed = %d\n", __func__ ,self->io.speed,baud);
 	
 	/* Come from SIR speed */
 	if(self->io.speed <=115200)
@@ -1029,7 +1029,7 @@ static void ali_ircc_fir_change_speed(st
 	// Set Dongle Speed mode
 	ali_ircc_change_dongle_speed(self, baud);
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -1047,9 +1047,9 @@ static void ali_ircc_sir_change_speed(st
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(1, "%s(), Setting speed to: %d\n", __FUNCTION__ , speed);
+	IRDA_DEBUG(1, "%s(), Setting speed to: %d\n", __func__ , speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1103,7 +1103,7 @@ static void ali_ircc_sir_change_speed(st
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
@@ -1113,14 +1113,14 @@ static void ali_ircc_change_dongle_speed
 	int iobase,dongle_id;
 	int tmp = 0;
 			
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	iobase = self->io.fir_base; 	/* or iobase = self->io.sir_base; */
 	dongle_id = self->io.dongle_id;
 	
 	/* We are already locked, no need to do it again */
 		
-	IRDA_DEBUG(1, "%s(), Set Speed for %s , Speed = %d\n", __FUNCTION__ , dongle_types[dongle_id], speed);		
+	IRDA_DEBUG(1, "%s(), Set Speed for %s , Speed = %d\n", __func__ , dongle_types[dongle_id], speed);
 	
 	switch_bank(iobase, BANK2);
 	tmp = inb(iobase+FIR_IRDA_CR);
@@ -1284,7 +1284,7 @@ static void ali_ircc_change_dongle_speed
 			
 	switch_bank(iobase, BANK0);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );		
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 /*
@@ -1297,11 +1297,11 @@ static int ali_ircc_sir_write(int iobase
 {
 	int actual = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	/* Tx FIFO should be empty! */
 	if (!(inb(iobase+UART_LSR) & UART_LSR_THRE)) {
-		IRDA_DEBUG(0, "%s(), failed, fifo not empty!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), failed, fifo not empty!\n", __func__ );
 		return 0;
 	}
         
@@ -1313,7 +1313,7 @@ static int ali_ircc_sir_write(int iobase
 		actual++;
 	}
 	
-        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	return actual;
 }
 
@@ -1329,7 +1329,7 @@ static int ali_ircc_net_open(struct net_
 	int iobase;
 	char hwname[32];
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
@@ -1375,7 +1375,7 @@ static int ali_ircc_net_open(struct net_
 	 */
 	self->irlap = irlap_open(dev, &self->qos, hwname);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return 0;
 }
@@ -1392,7 +1392,7 @@ static int ali_ircc_net_close(struct net
 	struct ali_ircc_cb *self;
 	//int iobase;
 			
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -1415,7 +1415,7 @@ static int ali_ircc_net_close(struct net
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return 0;
 }
@@ -1434,7 +1434,7 @@ static int ali_ircc_fir_hard_xmit(struct
 	__u32 speed;
 	int mtt, diff;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	self = (struct ali_ircc_cb *) dev->priv;
 	iobase = self->io.fir_base;
@@ -1488,7 +1488,7 @@ static int ali_ircc_fir_hard_xmit(struct
 			diff = self->now.tv_usec - self->stamp.tv_usec;
 			/* self->stamp is set from ali_ircc_dma_receive_complete() */
 							
-			IRDA_DEBUG(1, "%s(), ******* diff = %d ******* \n", __FUNCTION__ , diff);	
+			IRDA_DEBUG(1, "%s(), ******* diff = %d ******* \n", __func__ , diff);
 			
 			if (diff < 0) 
 				diff += 1000000;
@@ -1510,7 +1510,7 @@ static int ali_ircc_fir_hard_xmit(struct
 					/* Adjust for timer resolution */
 					mtt = (mtt+250) / 500; 	/* 4 discard, 5 get advanced, Let's round off */
 					
-					IRDA_DEBUG(1, "%s(), ************** mtt = %d ***********\n", __FUNCTION__ , mtt);	
+					IRDA_DEBUG(1, "%s(), ************** mtt = %d ***********\n", __func__ , mtt);
 					
 					/* Setup timer */
 					if (mtt == 1) /* 500 us */
@@ -1567,7 +1567,7 @@ static int ali_ircc_fir_hard_xmit(struct
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return 0;	
 }
 
@@ -1578,7 +1578,7 @@ static void ali_ircc_dma_xmit(struct ali
 	unsigned char FIFO_OPTI, Hi, Lo;
 	
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1629,7 +1629,7 @@ static void ali_ircc_dma_xmit(struct ali
 	tmp = inb(iobase+FIR_LCR_B);
 	tmp &= ~0x20; // Disable SIP
 	outb(((unsigned char)(tmp & 0x3f) | LCR_B_TX_MODE) & ~LCR_B_BW, iobase+FIR_LCR_B);
-	IRDA_DEBUG(1, "%s(), ******* Change to TX mode: FIR_LCR_B = 0x%x ******* \n", __FUNCTION__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), ******* Change to TX mode: FIR_LCR_B = 0x%x ******* \n", __func__ , inb(iobase+FIR_LCR_B));
 	
 	outb(0, iobase+FIR_LSR);
 			
@@ -1639,7 +1639,7 @@ static void ali_ircc_dma_xmit(struct ali
 	
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
@@ -1647,7 +1647,7 @@ static int  ali_ircc_dma_xmit_complete(s
 	int iobase;
 	int ret = TRUE;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1660,7 +1660,7 @@ static int  ali_ircc_dma_xmit_complete(s
 	if((inb(iobase+FIR_LSR) & LSR_FRAME_ABORT) == LSR_FRAME_ABORT)
 	
 	{
-		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __FUNCTION__);	
+		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __func__);
 		self->stats.tx_errors++;
 		self->stats.tx_fifo_errors++;		
 	}
@@ -1703,7 +1703,7 @@ static int  ali_ircc_dma_xmit_complete(s
 		
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return ret;
 }
 
@@ -1718,7 +1718,7 @@ static int ali_ircc_dma_receive(struct a
 {
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	iobase = self->io.fir_base;
 	
@@ -1756,7 +1756,7 @@ static int ali_ircc_dma_receive(struct a
 	//switch_bank(iobase, BANK0);
 	tmp = inb(iobase+FIR_LCR_B);
 	outb((unsigned char)(tmp &0x3f) | LCR_B_RX_MODE | LCR_B_BW , iobase + FIR_LCR_B); // 2000/12/1 05:16PM
-	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x *** \n", __FUNCTION__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x *** \n", __func__ , inb(iobase+FIR_LCR_B));
 			
 	/* Set Rx Threshold */
 	switch_bank(iobase, BANK1);
@@ -1768,7 +1768,7 @@ static int ali_ircc_dma_receive(struct a
 	outb(CR_DMA_EN | CR_DMA_BURST, iobase+FIR_CR);
 				
 	switch_bank(iobase, BANK0); 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return 0;
 }
 
@@ -1779,7 +1779,7 @@ static int  ali_ircc_dma_receive_complet
 	__u8 status, MessageCount;
 	int len, i, iobase, val;	
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );
 
 	st_fifo = &self->st_fifo;		
 	iobase = self->io.fir_base;	
@@ -1788,7 +1788,7 @@ static int  ali_ircc_dma_receive_complet
 	MessageCount = inb(iobase+ FIR_LSR)&0x07;
 	
 	if (MessageCount > 0)	
-		IRDA_DEBUG(0, "%s(), Messsage count = %d,\n", __FUNCTION__ , MessageCount);	
+		IRDA_DEBUG(0, "%s(), Messsage count = %d,\n", __func__ , MessageCount);
 		
 	for (i=0; i<=MessageCount; i++)
 	{
@@ -1801,11 +1801,11 @@ static int  ali_ircc_dma_receive_complet
 		len = len << 8; 
 		len |= inb(iobase+FIR_RX_DSR_LO);
 		
-		IRDA_DEBUG(1, "%s(), RX Length = 0x%.2x,\n", __FUNCTION__ , len);	
-		IRDA_DEBUG(1, "%s(), RX Status = 0x%.2x,\n", __FUNCTION__ , status);
+		IRDA_DEBUG(1, "%s(), RX Length = 0x%.2x,\n", __func__ , len);
+		IRDA_DEBUG(1, "%s(), RX Status = 0x%.2x,\n", __func__ , status);
 		
 		if (st_fifo->tail >= MAX_RX_WINDOW) {
-			IRDA_DEBUG(0, "%s(), window is full!\n", __FUNCTION__ );
+			IRDA_DEBUG(0, "%s(), window is full!\n", __func__ );
 			continue;
 		}
 			
@@ -1828,7 +1828,7 @@ static int  ali_ircc_dma_receive_complet
 		/* Check for errors */
 		if ((status & 0xd8) || self->rcvFramesOverflow || (len==0)) 		
 		{
-			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __FUNCTION__ );	
+			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __func__ );
 			
 			/* Skip frame */
 			self->stats.rx_errors++;
@@ -1838,29 +1838,29 @@ static int  ali_ircc_dma_receive_complet
 			if (status & LSR_FIFO_UR) 
 			{
 				self->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************ \n", __FUNCTION__ );
+				IRDA_DEBUG(0,"%s(), ************* FIFO Errors ************ \n", __func__ );
 			}	
 			if (status & LSR_FRAME_ERROR)
 			{
 				self->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************ \n", __FUNCTION__ );
+				IRDA_DEBUG(0,"%s(), ************* FRAME Errors ************ \n", __func__ );
 			}
 							
 			if (status & LSR_CRC_ERROR) 
 			{
 				self->stats.rx_crc_errors++;
-				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************ \n", __FUNCTION__ );
+				IRDA_DEBUG(0,"%s(), ************* CRC Errors ************ \n", __func__ );
 			}
 			
 			if(self->rcvFramesOverflow)
 			{
 				self->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************ \n", __FUNCTION__ );								
+				IRDA_DEBUG(0,"%s(), ************* Overran DMA buffer ************ \n", __func__ );
 			}
 			if(len == 0)
 			{
 				self->stats.rx_frame_errors++;
-				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 ********* \n", __FUNCTION__ );
+				IRDA_DEBUG(0,"%s(), ********** Receive Frame Size = 0 ********* \n", __func__ );
 			}
 		}	 
 		else 
@@ -1872,7 +1872,7 @@ static int  ali_ircc_dma_receive_complet
 				val = inb(iobase+FIR_BSR);	
 				if ((val& BSR_FIFO_NOT_EMPTY)== 0x80) 
 				{
-					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************ \n", __FUNCTION__ );
+					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************ \n", __func__ );
 					
 					/* Put this entry back in fifo */
 					st_fifo->head--;
@@ -1909,7 +1909,7 @@ static int  ali_ircc_dma_receive_complet
 			{
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
-					     __FUNCTION__);
+					     __func__);
 				self->stats.rx_dropped++;
 
 				return FALSE;
@@ -1937,7 +1937,7 @@ static int  ali_ircc_dma_receive_complet
 	
 	switch_bank(iobase, BANK0);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 	return TRUE;
 }
 
@@ -1956,7 +1956,7 @@ static int ali_ircc_sir_hard_xmit(struct
 	int iobase;
 	__u32 speed;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return 0;);
 	
@@ -2005,7 +2005,7 @@ static int ali_ircc_sir_hard_xmit(struct
 
 	dev_kfree_skb(skb);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return 0;	
 }
@@ -2024,7 +2024,7 @@ static int ali_ircc_net_ioctl(struct net
 	unsigned long flags;
 	int ret = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2032,11 +2032,11 @@ static int ali_ircc_net_ioctl(struct net
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__ , dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
-		IRDA_DEBUG(1, "%s(), SIOCSBANDWIDTH\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), SIOCSBANDWIDTH\n", __func__ );
 		/*
 		 * This function will also be used by IrLAP to change the
 		 * speed, so we still must allow for speed change within
@@ -2050,13 +2050,13 @@ static int ali_ircc_net_ioctl(struct net
 		spin_unlock_irqrestore(&self->lock, flags);
 		break;
 	case SIOCSMEDIABUSY: /* Set media busy */
-		IRDA_DEBUG(1, "%s(), SIOCSMEDIABUSY\n", __FUNCTION__ );
+		IRDA_DEBUG(1, "%s(), SIOCSMEDIABUSY\n", __func__ );
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 		irda_device_set_media_busy(self->netdev, TRUE);
 		break;
 	case SIOCGRECEIVING: /* Check if we are receiving right now */
-		IRDA_DEBUG(2, "%s(), SIOCGRECEIVING\n", __FUNCTION__ );
+		IRDA_DEBUG(2, "%s(), SIOCGRECEIVING\n", __func__ );
 		/* This is protected */
 		irq->ifr_receiving = ali_ircc_is_receiving(self);
 		break;
@@ -2064,7 +2064,7 @@ static int ali_ircc_net_ioctl(struct net
 		ret = -EOPNOTSUPP;
 	}
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return ret;
 }
@@ -2081,7 +2081,7 @@ static int ali_ircc_is_receiving(struct 
 	int status = FALSE;
 	int iobase;		
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
@@ -2095,7 +2095,7 @@ static int ali_ircc_is_receiving(struct 
 		if((inb(iobase+FIR_FIFO_FR) & 0x3f) != 0) 		
 		{
 			/* We are receiving something */
-			IRDA_DEBUG(1, "%s(), We are receiving something\n", __FUNCTION__ );
+			IRDA_DEBUG(1, "%s(), We are receiving something\n", __func__ );
 			status = TRUE;
 		}
 		switch_bank(iobase, BANK0);		
@@ -2107,7 +2107,7 @@ static int ali_ircc_is_receiving(struct 
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return status;
 }
@@ -2116,9 +2116,9 @@ static struct net_device_stats *ali_ircc
 {
 	struct ali_ircc_cb *self = (struct ali_ircc_cb *) dev->priv;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return &self->stats;
 }
@@ -2164,7 +2164,7 @@ static void SetCOMInterrupts(struct ali_
 	
 	int iobase = self->io.fir_base; /* or sir_base */
 
-	IRDA_DEBUG(2, "%s(), -------- Start -------- ( Enable = %d )\n", __FUNCTION__ , enable);	
+	IRDA_DEBUG(2, "%s(), -------- Start -------- ( Enable = %d )\n", __func__ , enable);
 	
 	/* Enable the interrupt which we wish to */
 	if (enable){
@@ -2205,14 +2205,14 @@ static void SetCOMInterrupts(struct ali_
 	else
 		outb(newMask, iobase+UART_IER);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void SIR2FIR(int iobase)
 {
 	//unsigned char tmp;
 		
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	/* Already protected (change_speed() or setup()), no need to lock.
 	 * Jean II */
@@ -2228,14 +2228,14 @@ static void SIR2FIR(int iobase)
 	//tmp |= 0x20;
 	//outb(tmp, iobase+FIR_LCR_B);	
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static void FIR2SIR(int iobase)
 {
 	unsigned char val;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	/* Already protected (change_speed() or setup()), no need to lock.
 	 * Jean II */
@@ -2251,7 +2251,7 @@ static void FIR2SIR(int iobase)
 	val = inb(iobase+UART_LSR);
 	val = inb(iobase+UART_MSR);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 MODULE_AUTHOR("Benjamin Kong <benjamin_kong@ali.com.tw>");
diff -puN drivers/net/irda/donauboe.c~irda-replace-__function__-with-__func__ drivers/net/irda/donauboe.c
--- a/drivers/net/irda/donauboe.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/donauboe.c
@@ -245,7 +245,7 @@ toshoboe_dumpregs (struct toshoboe_cb *s
 {
   __u32 ringbase;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   ringbase = INB (OBOE_RING_BASE0) << 10;
   ringbase |= INB (OBOE_RING_BASE1) << 18;
@@ -293,7 +293,7 @@ static void
 toshoboe_disablebm (struct toshoboe_cb *self)
 {
   __u8 command;
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   pci_read_config_byte (self->pdev, PCI_COMMAND, &command);
   command &= ~PCI_COMMAND_MASTER;
@@ -305,7 +305,7 @@ toshoboe_disablebm (struct toshoboe_cb *
 static void
 toshoboe_stopchip (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   /*Disable interrupts */
   OUTB (0x0, OBOE_IER);
@@ -350,7 +350,7 @@ toshoboe_setbaud (struct toshoboe_cb *se
   __u16 pconfig = 0;
   __u8 config0l = 0;
 
-  IRDA_DEBUG (2, "%s(%d/%d)\n", __FUNCTION__, self->speed, self->io.speed);
+  IRDA_DEBUG (2, "%s(%d/%d)\n", __func__, self->speed, self->io.speed);
 
   switch (self->speed)
     {
@@ -482,7 +482,7 @@ toshoboe_setbaud (struct toshoboe_cb *se
 static void
 toshoboe_enablebm (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
   pci_set_master (self->pdev);
 }
 
@@ -492,7 +492,7 @@ toshoboe_initring (struct toshoboe_cb *s
 {
   int i;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   for (i = 0; i < TX_SLOTS; ++i)
     {
@@ -550,7 +550,7 @@ toshoboe_startchip (struct toshoboe_cb *
 {
   __u32 physaddr;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   toshoboe_initring (self);
   toshoboe_enablebm (self);
@@ -824,7 +824,7 @@ toshoboe_probe (struct toshoboe_cb *self
 #endif
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (request_irq (self->io.irq, toshoboe_probeinterrupt,
                    self->io.irqflags, "toshoboe", (void *) self))
@@ -983,10 +983,10 @@ toshoboe_hard_xmit (struct sk_buff *skb,
 
   IRDA_ASSERT (self != NULL, return 0; );
 
-  IRDA_DEBUG (1, "%s.tx:%x(%x)%x\n", __FUNCTION__
+  IRDA_DEBUG (1, "%s.tx:%x(%x)%x\n", __func__
       ,skb->len,self->txpending,INB (OBOE_ENABLEH));
   if (!cb->magic) {
-      IRDA_DEBUG (2, "%s.Not IrLAP:%x\n", __FUNCTION__, cb->magic);
+      IRDA_DEBUG (2, "%s.Not IrLAP:%x\n", __func__, cb->magic);
 #ifdef DUMP_PACKETS
       _dumpbufs(skb->data,skb->len,'>');
 #endif
@@ -1015,7 +1015,7 @@ toshoboe_hard_xmit (struct sk_buff *skb,
         {
           self->new_speed = speed;
           IRDA_DEBUG (1, "%s: Queued TxDone scheduled speed change %d\n" ,
-		      __FUNCTION__, speed);
+		      __func__, speed);
           /* if no data, that's all! */
           if (!skb->len)
             {
@@ -1057,7 +1057,7 @@ toshoboe_hard_xmit (struct sk_buff *skb,
       /* which we will add a wrong checksum to */
 
       mtt = toshoboe_makemttpacket (self, self->tx_bufs[self->txs], mtt);
-      IRDA_DEBUG (1, "%s.mtt:%x(%x)%d\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.mtt:%x(%x)%d\n", __func__
           ,skb->len,mtt,self->txpending);
       if (mtt)
         {
@@ -1101,7 +1101,7 @@ dumpbufs(skb->data,skb->len,'>');
 
   if (self->ring->tx[self->txs].control & OBOE_CTL_TX_HW_OWNS)
     {
-      IRDA_DEBUG (0, "%s.ful:%x(%x)%x\n", __FUNCTION__
+      IRDA_DEBUG (0, "%s.ful:%x(%x)%x\n", __func__
           ,skb->len, self->ring->tx[self->txs].control, self->txpending);
       toshoboe_start_DMA(self, OBOE_CONFIG0H_ENTX);
       spin_unlock_irqrestore(&self->spinlock, flags);
@@ -1179,7 +1179,7 @@ toshoboe_interrupt (int irq, void *dev_i
           if (self->ring->tx[i].control & OBOE_CTL_TX_HW_OWNS)
               self->txpending++;
         }
-      IRDA_DEBUG (1, "%s.txd(%x)%x/%x\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.txd(%x)%x/%x\n", __func__
           ,irqstat,txp,self->txpending);
 
       txp = INB (OBOE_TXSLOT) & OBOE_SLOT_MASK;
@@ -1209,7 +1209,7 @@ toshoboe_interrupt (int irq, void *dev_i
         {
           self->speed = self->new_speed;
           IRDA_DEBUG (1, "%s: Executed TxDone scheduled speed change %d\n",
-		      __FUNCTION__, self->speed);
+		      __func__, self->speed);
           toshoboe_setbaud (self);
         }
 
@@ -1224,7 +1224,7 @@ toshoboe_interrupt (int irq, void *dev_i
         {
           int len = self->ring->rx[self->rxs].len;
           skb = NULL;
-          IRDA_DEBUG (3, "%s.rcv:%x(%x)\n", __FUNCTION__
+          IRDA_DEBUG (3, "%s.rcv:%x(%x)\n", __func__
 		      ,len,self->ring->rx[self->rxs].control);
 
 #ifdef DUMP_PACKETS
@@ -1246,7 +1246,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (1, "%s.SIR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (1, "%s.SIR:%x(%x)\n", __func__, len,enable);
                 }
 
 #ifdef USE_MIR
@@ -1256,7 +1256,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (2, "%s.MIR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (2, "%s.MIR:%x(%x)\n", __func__, len,enable);
                 }
 #endif
               else if (enable & OBOE_ENABLEH_FIRON)
@@ -1265,10 +1265,10 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
                       len -= 4;   /*FIXME: check this */
                   else
                       len = 0;
-                  IRDA_DEBUG (1, "%s.FIR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (1, "%s.FIR:%x(%x)\n", __func__, len,enable);
                 }
               else
-                  IRDA_DEBUG (0, "%s.?IR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (0, "%s.?IR:%x(%x)\n", __func__, len,enable);
 
               if (len)
                 {
@@ -1289,7 +1289,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
                     {
                       printk (KERN_INFO
                               "%s(), memory squeeze, dropping frame.\n",
-			      __FUNCTION__);
+			      __func__);
                     }
                 }
             }
@@ -1301,7 +1301,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
             /* (SIR) data is splitted in several slots. */
             /* we have to join all the received buffers received */
             /*in a large buffer before checking CRC. */
-            IRDA_DEBUG (0, "%s.err:%x(%x)\n", __FUNCTION__
+            IRDA_DEBUG (0, "%s.err:%x(%x)\n", __func__
                 ,len,self->ring->rx[self->rxs].control);
             }
 
@@ -1329,7 +1329,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<
   if (irqstat & OBOE_INT_SIP)
     {
       self->int_sip++;
-      IRDA_DEBUG (1, "%s.sip:%x(%x)%x\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.sip:%x(%x)%x\n", __func__
 	      ,self->int_sip,irqstat,self->txpending);
     }
   return IRQ_HANDLED;
@@ -1343,7 +1343,7 @@ toshoboe_net_open (struct net_device *de
   unsigned long flags;
   int rc;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   self = netdev_priv(dev);
 
@@ -1381,7 +1381,7 @@ toshoboe_net_close (struct net_device *d
 {
   struct toshoboe_cb *self;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (dev != NULL, return -1; );
   self = (struct toshoboe_cb *) dev->priv;
@@ -1426,7 +1426,7 @@ toshoboe_net_ioctl (struct net_device *d
 
   IRDA_ASSERT (self != NULL, return -1; );
 
-  IRDA_DEBUG (5, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+  IRDA_DEBUG (5, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
   /* Disable interrupts & save flags */
   spin_lock_irqsave(&self->spinlock, flags);
@@ -1438,7 +1438,7 @@ toshoboe_net_ioctl (struct net_device *d
        * speed, so we still must allow for speed change within
        * interrupt context.
        */
-      IRDA_DEBUG (1, "%s(BANDWIDTH), %s, (%X/%ld\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s(BANDWIDTH), %s, (%X/%ld\n", __func__
           ,dev->name, INB (OBOE_STATUS), irq->ifr_baudrate );
       if (!in_interrupt () && !capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
@@ -1451,7 +1451,7 @@ toshoboe_net_ioctl (struct net_device *d
       self->new_speed = irq->ifr_baudrate;
       break;
     case SIOCSMEDIABUSY:       /* Set media busy */
-      IRDA_DEBUG (1, "%s(MEDIABUSY), %s, (%X/%x)\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s(MEDIABUSY), %s, (%X/%x)\n", __func__
           ,dev->name, INB (OBOE_STATUS), capable (CAP_NET_ADMIN) );
       if (!capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
@@ -1461,11 +1461,11 @@ toshoboe_net_ioctl (struct net_device *d
       break;
     case SIOCGRECEIVING:       /* Check if we are receiving right now */
       irq->ifr_receiving = (INB (OBOE_STATUS) & OBOE_STATUS_RXBUSY) ? 1 : 0;
-      IRDA_DEBUG (3, "%s(RECEIVING), %s, (%X/%x)\n", __FUNCTION__
+      IRDA_DEBUG (3, "%s(RECEIVING), %s, (%X/%x)\n", __func__
           ,dev->name, INB (OBOE_STATUS), irq->ifr_receiving );
       break;
     default:
-      IRDA_DEBUG (1, "%s(?), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+      IRDA_DEBUG (1, "%s(?), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
       ret = -EOPNOTSUPP;
     }
 out:
@@ -1492,7 +1492,7 @@ toshoboe_close (struct pci_dev *pci_dev)
   int i;
   struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (self != NULL, return; );
 
@@ -1533,7 +1533,7 @@ toshoboe_open (struct pci_dev *pci_dev, 
   int ok = 0;
   int err;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if ((err=pci_enable_device(pci_dev)))
     return err;
@@ -1700,7 +1700,7 @@ toshoboe_gotosleep (struct pci_dev *pci_
   unsigned long flags;
   int i = 10;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (!self || self->stopped)
     return 0;
@@ -1728,7 +1728,7 @@ toshoboe_wakeup (struct pci_dev *pci_dev
   struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (!self || !self->stopped)
     return 0;
diff -puN drivers/net/irda/girbil-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/girbil-sir.c
--- a/drivers/net/irda/girbil-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/girbil-sir.c
@@ -86,7 +86,7 @@ static int girbil_open(struct sir_dev *d
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -102,7 +102,7 @@ static int girbil_open(struct sir_dev *d
 
 static int girbil_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -126,7 +126,7 @@ static int girbil_change_speed(struct si
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* dongle alread reset - port and dongle at default speed */
 
@@ -179,7 +179,7 @@ static int girbil_change_speed(struct si
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -209,7 +209,7 @@ static int girbil_reset(struct sir_dev *
 	u8 control = GIRBIL_TXEN | GIRBIL_RXEN;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -241,7 +241,7 @@ static int girbil_reset(struct sir_dev *
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
 		ret = -1;
 		break;
 	}
diff -puN drivers/net/irda/irda-usb.c~irda-replace-__function__-with-__func__ drivers/net/irda/irda-usb.c
--- a/drivers/net/irda/irda-usb.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/irda-usb.c
@@ -177,12 +177,12 @@ static void irda_usb_build_header(struct
 		    (!force) && (self->speed != -1)) {
 			/* No speed and xbofs change here
 			 * (we'll do it later in the write callback) */
-			IRDA_DEBUG(2, "%s(), not changing speed yet\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), not changing speed yet\n", __func__);
 			*header = 0;
 			return;
 		}
 
-		IRDA_DEBUG(2, "%s(), changing speed to %d\n", __FUNCTION__, self->new_speed);
+		IRDA_DEBUG(2, "%s(), changing speed to %d\n", __func__, self->new_speed);
 		self->speed = self->new_speed;
 		/* We will do ` self->new_speed = -1; ' in the completion
 		 * handler just in case the current URB fail - Jean II */
@@ -228,7 +228,7 @@ static void irda_usb_build_header(struct
 	
 	/* Set the negotiated additional XBOFS */
 	if (self->new_xbofs != -1) {
-		IRDA_DEBUG(2, "%s(), changing xbofs to %d\n", __FUNCTION__, self->new_xbofs);
+		IRDA_DEBUG(2, "%s(), changing xbofs to %d\n", __func__, self->new_xbofs);
 		self->xbofs = self->new_xbofs;
 		/* We will do ` self->new_xbofs = -1; ' in the completion
 		 * handler just in case the current URB fail - Jean II */
@@ -302,13 +302,13 @@ static void irda_usb_change_speed_xbofs(
 	struct urb *urb;
 	int ret;
 
-	IRDA_DEBUG(2, "%s(), speed=%d, xbofs=%d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), speed=%d, xbofs=%d\n", __func__,
 		   self->new_speed, self->new_xbofs);
 
 	/* Grab the speed URB */
 	urb = self->speed_urb;
 	if (urb->status != 0) {
-		IRDA_WARNING("%s(), URB still in use!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), URB still in use!\n", __func__);
 		return;
 	}
 
@@ -334,7 +334,7 @@ static void irda_usb_change_speed_xbofs(
 
 	/* Irq disabled -> GFP_ATOMIC */
 	if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Speed URB\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed Speed URB\n", __func__);
 	}
 }
 
@@ -347,7 +347,7 @@ static void speed_bulk_callback(struct u
 {
 	struct irda_usb_cb *self = urb->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
@@ -357,7 +357,7 @@ static void speed_bulk_callback(struct u
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __FUNCTION__, urb->status, urb->transfer_flags);
+		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer.
 		 * Instead, we will wait for irda_usb_net_timeout(), the
@@ -392,7 +392,7 @@ static int irda_usb_hard_xmit(struct sk_
 	int res, mtt;
 	int	err = 1;	/* Failed */
 
-	IRDA_DEBUG(4, "%s() on %s\n", __FUNCTION__, netdev->name);
+	IRDA_DEBUG(4, "%s() on %s\n", __func__, netdev->name);
 
 	netif_stop_queue(netdev);
 
@@ -403,7 +403,7 @@ static int irda_usb_hard_xmit(struct sk_
 	 * We need to check self->present under the spinlock because
 	 * of irda_usb_disconnect() is synchronous - Jean II */
 	if (!self->present) {
-		IRDA_DEBUG(0, "%s(), Device is gone...\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Device is gone...\n", __func__);
 		goto drop;
 	}
 
@@ -437,7 +437,7 @@ static int irda_usb_hard_xmit(struct sk_
 	}
 
 	if (urb->status != 0) {
-		IRDA_WARNING("%s(), URB still in use!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), URB still in use!\n", __func__);
 		goto drop;
 	}
 
@@ -524,7 +524,7 @@ static int irda_usb_hard_xmit(struct sk_
 	
 	/* Ask USB to send the packet - Irq disabled -> GFP_ATOMIC */
 	if ((res = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Tx URB\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed Tx URB\n", __func__);
 		self->stats.tx_errors++;
 		/* Let USB recover : We will catch that in the watchdog */
 		/*netif_start_queue(netdev);*/
@@ -556,7 +556,7 @@ static void write_bulk_callback(struct u
 	struct sk_buff *skb = urb->context;
 	struct irda_usb_cb *self = ((struct irda_skb_cb *) skb->cb)->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
@@ -570,7 +570,7 @@ static void write_bulk_callback(struct u
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __FUNCTION__, urb->status, urb->transfer_flags);
+		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer,
 		 * and we could go in recursion and blow the kernel stack...
@@ -589,7 +589,7 @@ static void write_bulk_callback(struct u
 
 	/* If the network is closed, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone...\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Network is gone...\n", __func__);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
 	}
@@ -600,7 +600,7 @@ static void write_bulk_callback(struct u
 		    (self->new_xbofs != self->xbofs)) {
 			/* We haven't changed speed yet (because of
 			 * IUC_SPEED_BUG), so do it now - Jean II */
-			IRDA_DEBUG(1, "%s(), Changing speed now...\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), Changing speed now...\n", __func__);
 			irda_usb_change_speed_xbofs(self);
 		} else {
 			/* New speed and xbof is now commited in hardware */
@@ -632,7 +632,7 @@ static void irda_usb_net_timeout(struct 
 	struct urb *urb;
 	int	done = 0;	/* If we have made any progress */
 
-	IRDA_DEBUG(0, "%s(), Network layer thinks we timed out!\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Network layer thinks we timed out!\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	/* Protect us from USB callbacks, net Tx and else. */
@@ -640,7 +640,7 @@ static void irda_usb_net_timeout(struct 
 
 	/* self->present *MUST* be read under spinlock */
 	if (!self->present) {
-		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), device not present!\n", __func__);
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
@@ -763,7 +763,7 @@ static void irda_usb_submit(struct irda_
 	struct irda_skb_cb *cb;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* This should never happen */
 	IRDA_ASSERT(skb != NULL, return;);
@@ -786,7 +786,7 @@ static void irda_usb_submit(struct irda_
 		/* If this ever happen, we are in deep s***.
 		 * Basically, the Rx path will stop... */
 		IRDA_WARNING("%s(), Failed to submit Rx URB %d\n",
-			     __FUNCTION__, ret);
+			     __func__, ret);
 	}
 }
 
@@ -807,7 +807,7 @@ static void irda_usb_receive(struct urb 
 	struct urb *next_urb;
 	unsigned int len, docopy;
 
-	IRDA_DEBUG(2, "%s(), len=%d\n", __FUNCTION__, urb->actual_length);
+	IRDA_DEBUG(2, "%s(), len=%d\n", __func__, urb->actual_length);
 	
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
@@ -817,7 +817,7 @@ static void irda_usb_receive(struct urb 
 
 	/* If the network is closed or the device gone, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Network is gone!\n", __func__);
 		/* Don't re-submit the URB : will stall the Rx path */
 		return;
 	}
@@ -840,7 +840,7 @@ static void irda_usb_receive(struct urb 
 			/* Usually precursor to a hot-unplug on OHCI. */
 		default:
 			self->stats.rx_errors++;
-			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X \n", __FUNCTION__, urb->status, urb->transfer_flags);
+			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X \n", __func__, urb->status, urb->transfer_flags);
 			break;
 		}
 		/* If we received an error, we don't want to resubmit the
@@ -861,7 +861,7 @@ static void irda_usb_receive(struct urb 
 	
 	/* Check for empty frames */
 	if (urb->actual_length <= self->header_length) {
-		IRDA_WARNING("%s(), empty frame!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), empty frame!\n", __func__);
 		goto done;
 	}
 
@@ -967,7 +967,7 @@ static void irda_usb_rx_defer_expired(un
 	struct irda_skb_cb *cb;
 	struct urb *next_urb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
@@ -1053,7 +1053,7 @@ static int stir421x_fw_upload(struct ird
 				   patch_block, block_size,
 				   &actual_len, msecs_to_jiffies(500));
 		IRDA_DEBUG(3,"%s(): Bulk send %u bytes, ret=%d\n",
-			   __FUNCTION__, actual_len, ret);
+			   __func__, actual_len, ret);
 
 		if (ret < 0)
 			break;
@@ -1092,7 +1092,7 @@ static int stir421x_patch_device(struct 
 
         /* We get a patch from userspace */
         IRDA_MESSAGE("%s(): Received firmware %s (%zu bytes)\n",
-                     __FUNCTION__, stir421x_fw_name, fw->size);
+                     __func__, stir421x_fw_name, fw->size);
 
         ret = -EINVAL;
 
@@ -1116,7 +1116,7 @@ static int stir421x_patch_device(struct 
 				+ (build % 10);
 
 			IRDA_DEBUG(3, "%s(): Firmware Product version %ld\n",
-                                   __FUNCTION__, fw_version);
+                                   __func__, fw_version);
                 }
         }
 
@@ -1172,7 +1172,7 @@ static int irda_usb_net_open(struct net_
 	char	hwname[16];
 	int i;
 	
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = (struct irda_usb_cb *) netdev->priv;
@@ -1182,13 +1182,13 @@ static int irda_usb_net_open(struct net_
 	/* Can only open the device if it's there */
 	if(!self->present) {
 		spin_unlock_irqrestore(&self->lock, flags);
-		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), device not present!\n", __func__);
 		return -1;
 	}
 
 	if(self->needspatch) {
 		spin_unlock_irqrestore(&self->lock, flags);
-		IRDA_WARNING("%s(), device needs patch\n", __FUNCTION__) ;
+		IRDA_WARNING("%s(), device needs patch\n", __func__) ;
 		return -EIO ;
 	}
 
@@ -1231,7 +1231,7 @@ static int irda_usb_net_open(struct net_
 			/* If this ever happen, we are in deep s***.
 			 * Basically, we can't start the Rx path... */
 			IRDA_WARNING("%s(), Failed to allocate Rx skb\n",
-				     __FUNCTION__);
+				     __func__);
 			return -1;
 		}
 		//skb_reserve(newskb, USB_IRDA_HEADER - 1);
@@ -1254,7 +1254,7 @@ static int irda_usb_net_close(struct net
 	struct irda_usb_cb *self;
 	int	i;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = (struct irda_usb_cb *) netdev->priv;
@@ -1309,7 +1309,7 @@ static int irda_usb_net_ioctl(struct net
 	self = dev->priv;
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -1367,7 +1367,7 @@ static inline void irda_usb_init_qos(str
 {
 	struct irda_class_desc *desc;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 	
 	desc = self->irda_desc;
 	
@@ -1384,7 +1384,7 @@ static inline void irda_usb_init_qos(str
 	self->qos.data_size.bits       = desc->bmDataSize;
 
 	IRDA_DEBUG(0, "%s(), dongle says speed=0x%X, size=0x%X, window=0x%X, bofs=0x%X, turn=0x%X\n", 
-		__FUNCTION__, self->qos.baud_rate.bits, self->qos.data_size.bits, self->qos.window_size.bits, self->qos.additional_bofs.bits, self->qos.min_turn_time.bits);
+		__func__, self->qos.baud_rate.bits, self->qos.data_size.bits, self->qos.window_size.bits, self->qos.additional_bofs.bits, self->qos.min_turn_time.bits);
 
 	/* Don't always trust what the dongle tell us */
 	if(self->capability & IUC_SIR_ONLY)
@@ -1419,7 +1419,7 @@ static inline int irda_usb_open(struct i
 {
 	struct net_device *netdev = self->netdev;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	irda_usb_init_qos(self);
 
@@ -1442,7 +1442,7 @@ static inline int irda_usb_open(struct i
  */
 static inline void irda_usb_close(struct irda_usb_cb *self)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	/* Remove netdevice */
 	unregister_netdev(self->netdev);
@@ -1515,13 +1515,13 @@ static inline int irda_usb_parse_endpoin
 				/* This is our interrupt endpoint */
 				self->bulk_int_ep = ep;
 			} else {
-				IRDA_ERROR("%s(), Unrecognised endpoint %02X.\n", __FUNCTION__, ep);
+				IRDA_ERROR("%s(), Unrecognised endpoint %02X.\n", __func__, ep);
 			}
 		}
 	}
 
 	IRDA_DEBUG(0, "%s(), And our endpoints are : in=%02X, out=%02X (%d), int=%02X\n",
-		__FUNCTION__, self->bulk_in_ep, self->bulk_out_ep, self->bulk_out_mtu, self->bulk_int_ep);
+		__func__, self->bulk_in_ep, self->bulk_out_ep, self->bulk_out_mtu, self->bulk_int_ep);
 
 	return((self->bulk_in_ep != 0) && (self->bulk_out_ep != 0));
 }
@@ -1583,7 +1583,7 @@ static inline struct irda_class_desc *ir
 		0, intf->altsetting->desc.bInterfaceNumber, desc,
 		sizeof(*desc), 500);
 	
-	IRDA_DEBUG(1, "%s(), ret=%d\n", __FUNCTION__, ret);
+	IRDA_DEBUG(1, "%s(), ret=%d\n", __func__, ret);
 	if (ret < sizeof(*desc)) {
 		IRDA_WARNING("usb-irda: class_descriptor read %s (%d)\n",
 			     (ret<0) ? "failed" : "too short", ret);
@@ -1696,10 +1696,10 @@ static int irda_usb_probe(struct usb_int
 			/* Martin Diehl says if we get a -EPIPE we should
 			 * be fine and we don't need to do a usb_clear_halt().
 			 * - Jean II */
-			IRDA_DEBUG(0, "%s(), Received -EPIPE, ignoring...\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), Received -EPIPE, ignoring...\n", __func__);
 			break;
 		default:
-			IRDA_DEBUG(0, "%s(), Unknown error %d\n", __FUNCTION__, ret);
+			IRDA_DEBUG(0, "%s(), Unknown error %d\n", __func__, ret);
 			ret = -EIO;
 			goto err_out_3;
 	}
@@ -1708,7 +1708,7 @@ static int irda_usb_probe(struct usb_int
 	interface = intf->cur_altsetting;
 	if(!irda_usb_parse_endpoints(self, interface->endpoint,
 				     interface->desc.bNumEndpoints)) {
-		IRDA_ERROR("%s(), Bogus endpoints...\n", __FUNCTION__);
+		IRDA_ERROR("%s(), Bogus endpoints...\n", __func__);
 		ret = -EIO;
 		goto err_out_3;
 	}
@@ -1815,7 +1815,7 @@ static void irda_usb_disconnect(struct u
 	struct irda_usb_cb *self = usb_get_intfdata(intf);
 	int i;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	usb_set_intfdata(intf, NULL);
 	if (!self)
@@ -1865,7 +1865,7 @@ static void irda_usb_disconnect(struct u
 
 	/* Free self and network device */
 	free_netdev(self->netdev);
-	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __func__);
 }
 
 /*------------------------------------------------------------------*/
diff -puN drivers/net/irda/irtty-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/irtty-sir.c
--- a/drivers/net/irda/irtty-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/irtty-sir.c
@@ -231,7 +231,7 @@ static void irtty_receive_buf(struct tty
 
 	dev = priv->dev;
 	if (!dev) {
-		IRDA_WARNING("%s(), not ready yet!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), not ready yet!\n", __func__);
 		return;
 	}
 
@@ -388,7 +388,7 @@ static int irtty_ioctl(struct tty_struct
 	IRDA_ASSERT(priv != NULL, return -ENODEV;);
 	IRDA_ASSERT(priv->magic == IRTTY_MAGIC, return -EBADR;);
 
-	IRDA_DEBUG(3, "%s(cmd=0x%X)\n", __FUNCTION__, cmd);
+	IRDA_DEBUG(3, "%s(cmd=0x%X)\n", __func__, cmd);
 
 	dev = priv->dev;
 	IRDA_ASSERT(dev != NULL, return -1;);
@@ -476,7 +476,7 @@ static int irtty_open(struct tty_struct 
 
 	mutex_unlock(&irtty_mutex);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline opened\n", __FUNCTION__, tty->name);
+	IRDA_DEBUG(0, "%s - %s: irda line discipline opened\n", __func__, tty->name);
 
 	return 0;
 
@@ -528,7 +528,7 @@ static void irtty_close(struct tty_struc
 
 	kfree(priv);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline closed\n", __FUNCTION__, tty->name);
+	IRDA_DEBUG(0, "%s - %s: irda line discipline closed\n", __func__, tty->name);
 }
 
 /* ------------------------------------------------------- */
@@ -566,7 +566,7 @@ static void __exit irtty_sir_cleanup(voi
 
 	if ((err = tty_unregister_ldisc(N_IRDA))) {
 		IRDA_ERROR("%s(), can't unregister line discipline (err = %d)\n",
-			   __FUNCTION__, err);
+			   __func__, err);
 	}
 }
 
diff -puN drivers/net/irda/kingsun-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/kingsun-sir.c
--- a/drivers/net/irda/kingsun-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/kingsun-sir.c
@@ -243,7 +243,7 @@ static void kingsun_rcv_irq(struct urb *
 		}
 	} else if (urb->actual_length > 0) {
 		err("%s(): Unexpected response length, expected %d got %d",
-		    __FUNCTION__, kingsun->max_rx, urb->actual_length);
+		    __func__, kingsun->max_rx, urb->actual_length);
 	}
 	/* This urb has already been filled in kingsun_net_open */
 	ret = usb_submit_urb(urb, GFP_ATOMIC);
diff -puN drivers/net/irda/litelink-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/litelink-sir.c
--- a/drivers/net/irda/litelink-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/litelink-sir.c
@@ -78,7 +78,7 @@ static int litelink_open(struct sir_dev 
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power up dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -95,7 +95,7 @@ static int litelink_open(struct sir_dev 
 
 static int litelink_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -113,7 +113,7 @@ static int litelink_change_speed(struct 
 {
         int i;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* dongle already reset by irda-thread - current speed (dongle and
 	 * port) is the default speed (115200 for litelink!)
@@ -156,7 +156,7 @@ static int litelink_change_speed(struct 
  */
 static int litelink_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* probably the power-up can be dropped here, but with only
 	 * 15 usec delay it's not worth the risk unless somebody with
diff -puN drivers/net/irda/ma600-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/ma600-sir.c
--- a/drivers/net/irda/ma600-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/ma600-sir.c
@@ -67,13 +67,13 @@ static struct dongle_driver ma600 = {
 
 static int __init ma600_sir_init(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 	return irda_register_dongle(&ma600);
 }
 
 static void __exit ma600_sir_cleanup(void)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 	irda_unregister_dongle(&ma600);
 }
 
@@ -88,7 +88,7 @@ static int ma600_open(struct sir_dev *de
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -106,7 +106,7 @@ static int ma600_open(struct sir_dev *de
 
 static int ma600_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -176,7 +176,7 @@ static int ma600_change_speed(struct sir
 {
 	u8	byte;
 	
-	IRDA_DEBUG(2, "%s(), speed=%d (was %d)\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), speed=%d (was %d)\n", __func__,
 		speed, dev->speed);
 
 	/* dongle already reset, dongle and port at default speed (9600) */
@@ -201,12 +201,12 @@ static int ma600_change_speed(struct sir
 	sirdev_raw_read(dev, &byte, sizeof(byte));
 	if (byte != get_control_byte(speed))  {
 		IRDA_WARNING("%s(): bad control byte read-back %02x != %02x\n",
-			     __FUNCTION__, (unsigned) byte,
+			     __func__, (unsigned) byte,
 			     (unsigned) get_control_byte(speed));
 		return -1;
 	}
 	else
-		IRDA_DEBUG(2, "%s() control byte write read OK\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s() control byte write read OK\n", __func__);
 #endif
 
 	/* Set DTR, Set RTS */
@@ -238,7 +238,7 @@ static int ma600_change_speed(struct sir
 
 int ma600_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Reset the dongle : set DTR low for 10 ms */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
diff -puN drivers/net/irda/mcp2120-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/mcp2120-sir.c
--- a/drivers/net/irda/mcp2120-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/mcp2120-sir.c
@@ -63,7 +63,7 @@ static int mcp2120_open(struct sir_dev *
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* seems no explicit power-on required here and reset switching it on anyway */
 
@@ -76,7 +76,7 @@ static int mcp2120_open(struct sir_dev *
 
 static int mcp2120_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
         /* reset and inhibit mcp2120 */
@@ -102,7 +102,7 @@ static int mcp2120_change_speed(struct s
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -155,7 +155,7 @@ static int mcp2120_change_speed(struct s
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefine state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefine state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -187,7 +187,7 @@ static int mcp2120_reset(struct sir_dev 
 	unsigned delay = 0;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -213,7 +213,7 @@ static int mcp2120_reset(struct sir_dev 
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
diff -puN drivers/net/irda/nsc-ircc.c~irda-replace-__function__-with-__func__ drivers/net/irda/nsc-ircc.c
--- a/drivers/net/irda/nsc-ircc.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/nsc-ircc.c
@@ -223,7 +223,7 @@ static int __init nsc_ircc_init(void)
 
 	/* Probe for all the NSC chipsets we know about */
 	for (chip = chips; chip->name ; chip++) {
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__,
 			   chip->name);
 		
 		/* Try all config registers for this chip */
@@ -235,7 +235,7 @@ static int __init nsc_ircc_init(void)
 			/* Read index register */
 			reg = inb(cfg_base);
 			if (reg == 0xff) {
-				IRDA_DEBUG(2, "%s() no chip at 0x%03x\n", __FUNCTION__, cfg_base);
+				IRDA_DEBUG(2, "%s() no chip at 0x%03x\n", __func__, cfg_base);
 				continue;
 			}
 			
@@ -244,7 +244,7 @@ static int __init nsc_ircc_init(void)
 			id = inb(cfg_base+1);
 			if ((id & chip->cid_mask) == chip->cid_value) {
 				IRDA_DEBUG(2, "%s() Found %s chip, revision=%d\n",
-					   __FUNCTION__, chip->name, id & ~chip->cid_mask);
+					   __func__, chip->name, id & ~chip->cid_mask);
 
 				/*
 				 * If we found a correct PnP setting,
@@ -295,7 +295,7 @@ static int __init nsc_ircc_init(void)
 				}
 				i++;
 			} else {
-				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __FUNCTION__, id);
+				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __func__, id);
 			}
 		} 
 	}
@@ -345,7 +345,7 @@ static int __init nsc_ircc_open(chipio_t
 	void *ret;
 	int err, chip_index;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 
  	for (chip_index = 0; chip_index < ARRAY_SIZE(dev_self); chip_index++) {
@@ -354,7 +354,7 @@ static int __init nsc_ircc_open(chipio_t
 	}
 
 	if (chip_index == ARRAY_SIZE(dev_self)) {
-		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -369,7 +369,7 @@ static int __init nsc_ircc_open(chipio_t
 	dev = alloc_irdadev(sizeof(struct nsc_ircc_cb));
 	if (dev == NULL) {
 		IRDA_ERROR("%s(), can't allocate memory for "
-			   "control block!\n", __FUNCTION__);
+			   "control block!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -393,7 +393,7 @@ static int __init nsc_ircc_open(chipio_t
 	ret = request_region(self->io.fir_base, self->io.fir_ext, driver_name);
 	if (!ret) {
 		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n",
-			     __FUNCTION__, self->io.fir_base);
+			     __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto out1;
 	}
@@ -450,7 +450,7 @@ static int __init nsc_ircc_open(chipio_t
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
 		goto out4;
 	}
 	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
@@ -506,7 +506,7 @@ static int __exit nsc_ircc_close(struct 
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -519,7 +519,7 @@ static int __exit nsc_ircc_close(struct 
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", 
-		   __FUNCTION__, self->io.fir_base);
+		   __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -557,7 +557,7 @@ static int nsc_ircc_init_108(nsc_chip_t 
 	case 0x2e8: outb(0x15, cfg_base+1); break;
 	case 0x3f8: outb(0x16, cfg_base+1); break;
 	case 0x2f8: outb(0x17, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid base_address", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid base_address", __func__);
 	}
 	
 	/* Control Signal Routing Register (CSRT) */
@@ -569,7 +569,7 @@ static int nsc_ircc_init_108(nsc_chip_t 
 	case 9:  temp = 0x05; break;
 	case 11: temp = 0x06; break;
 	case 15: temp = 0x07; break;
-	default: IRDA_ERROR("%s(), invalid irq", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid irq", __func__);
 	}
 	outb(CFG_108_CSRT, cfg_base);
 	
@@ -577,7 +577,7 @@ static int nsc_ircc_init_108(nsc_chip_t 
 	case 0: outb(0x08+temp, cfg_base+1); break;
 	case 1: outb(0x10+temp, cfg_base+1); break;
 	case 3: outb(0x18+temp, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid dma", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid dma", __func__);
 	}
 	
 	outb(CFG_108_MCTL, cfg_base);      /* Mode Control Register (MCTL) */
@@ -616,7 +616,7 @@ static int nsc_ircc_probe_108(nsc_chip_t
 		break;
 	}
 	info->sir_base = info->fir_base;
-	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __func__,
 		   info->fir_base);
 
 	/* Read control signals routing register (CSRT) */
@@ -649,7 +649,7 @@ static int nsc_ircc_probe_108(nsc_chip_t
 		info->irq = 15;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __FUNCTION__, info->irq);
+	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __func__, info->irq);
 
 	/* Currently we only read Rx DMA but it will also be used for Tx */
 	switch ((reg >> 3) & 0x03) {
@@ -666,7 +666,7 @@ static int nsc_ircc_probe_108(nsc_chip_t
 		info->dma = 3;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing dma=%d\n", __FUNCTION__, info->dma);
+	IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
 
 	/* Read mode control register (MCTL) */
 	outb(CFG_108_MCTL, cfg_base);
@@ -823,7 +823,7 @@ static int nsc_ircc_init_39x(nsc_chip_t 
 	/* User is sure about his config... accept it. */
 	IRDA_DEBUG(2, "%s(): nsc_ircc_init_39x (user settings): "
 		   "io=0x%04x, irq=%d, dma=%d\n", 
-		   __FUNCTION__, info->fir_base, info->irq, info->dma);
+		   __func__, info->fir_base, info->irq, info->dma);
 
 	/* Access bank for SP2 */
 	outb(CFG_39X_LDN, cfg_base);
@@ -864,7 +864,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 	int enabled, susp;
 
 	IRDA_DEBUG(2, "%s(), nsc_ircc_probe_39x, base=%d\n",
-		   __FUNCTION__, cfg_base);
+		   __func__, cfg_base);
 
 	/* This function should be executed with irq off to avoid
 	 * another driver messing with the Super I/O bank - Jean II */
@@ -898,7 +898,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t
 	outb(CFG_39X_SPC, cfg_base);
 	susp = 1 - ((inb(cfg_base+1) & 0x02) >> 1);
 
-	IRDA_DEBUG(2, "%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n", __FUNCTION__, reg1,reg2,irq,irqt,dma1,dma2,enabled,susp);
+	IRDA_DEBUG(2, "%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n", __func__, reg1,reg2,irq,irqt,dma1,dma2,enabled,susp);
 
 	/* Configure SP2 */
 
@@ -950,7 +950,7 @@ static int nsc_ircc_pnp_probe(struct pnp
 		pnp_info.dma = pnp_dma(dev, 0);
 
 	IRDA_DEBUG(0, "%s() : From PnP, found firbase 0x%03X ; irq %d ; dma %d.\n",
-		   __FUNCTION__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
+		   __func__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
 
 	if((pnp_info.fir_base == 0) ||
 	   (pnp_info.irq == -1) || (pnp_info.dma == -1)) {
@@ -979,7 +979,7 @@ static int nsc_ircc_setup(chipio_t *info
 	version = inb(iobase+MID);
 
 	IRDA_DEBUG(2, "%s() Driver %s Found chip version %02x\n",
-		   __FUNCTION__, driver_name, version);
+		   __func__, driver_name, version);
 
 	/* Should be 0x2? */
 	if (0x20 != (version & 0xf0)) {
@@ -1083,30 +1083,30 @@ static void nsc_ircc_init_dongle_interfa
 	case 0x00: /* same as */
 	case 0x01: /* Differential serial interface */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x02: /* same as */
 	case 0x03: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x04: /* Sharp RY5HD01 */
 		break;
 	case 0x05: /* Reserved, but this is what the Thinkpad reports */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x06: /* Single-ended serial interface */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x07: /* Consumer-IR only */
 		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x08: /* HP HSDL-2300, HP HSDL-3600/HSDL-3610 */
 		IRDA_DEBUG(0, "%s(), %s\n",
-			   __FUNCTION__, dongle_types[dongle_id]);
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x09: /* IBM31T1100 or Temic TFDS6000/TFDS6500 */
 		outb(0x28, iobase+7); /* Set irsl[0-2] as output */
@@ -1114,7 +1114,7 @@ static void nsc_ircc_init_dongle_interfa
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1129,14 +1129,14 @@ static void nsc_ircc_init_dongle_interfa
 		break;
 	case 0x0F: /* No dongle connected */
 		IRDA_DEBUG(0, "%s(), %s\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 
 		switch_bank(iobase, BANK0);
 		outb(0x62, iobase+MCR);
 		break;
 	default: 
 		IRDA_DEBUG(0, "%s(), invalid dongle_id %#x", 
-			   __FUNCTION__, dongle_id);
+			   __func__, dongle_id);
 	}
 	
 	/* IRCFG1: IRSL1 and 2 are set to IrDA mode */
@@ -1168,30 +1168,30 @@ static void nsc_ircc_change_dongle_speed
 	case 0x00: /* same as */
 	case 0x01: /* Differential serial interface */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x02: /* same as */
 	case 0x03: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x04: /* Sharp RY5HD01 */
 		break;
 	case 0x05: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x06: /* Single-ended serial interface */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x07: /* Consumer-IR only */
 		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x08: /* HP HSDL-2300, HP HSDL-3600/HSDL-3610 */
 		IRDA_DEBUG(0, "%s(), %s\n", 
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		outb(0x00, iobase+4);
 		if (speed > 115200)
 			outb(0x01, iobase+4);
@@ -1210,7 +1210,7 @@ static void nsc_ircc_change_dongle_speed
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]);
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1219,13 +1219,13 @@ static void nsc_ircc_change_dongle_speed
 		break;
 	case 0x0F: /* No dongle connected */
 		IRDA_DEBUG(0, "%s(), %s is not for IrDA mode\n",
-			   __FUNCTION__, dongle_types[dongle_id]);
+			   __func__, dongle_types[dongle_id]);
 
 		switch_bank(iobase, BANK0); 
 		outb(0x62, iobase+MCR);
 		break;
 	default: 
-		IRDA_DEBUG(0, "%s(), invalid data_rate\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), invalid data_rate\n", __func__);
 	}
 	/* Restore bank register */
 	outb(bank, iobase+BSR);
@@ -1246,7 +1246,7 @@ static __u8 nsc_ircc_change_speed(struct
 	__u8 bank;
 	__u8 ier;                  /* Interrupt enable register */
 
-	IRDA_DEBUG(2, "%s(), speed=%d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(2, "%s(), speed=%d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
@@ -1279,20 +1279,20 @@ static __u8 nsc_ircc_change_speed(struct
 		outb(inb(iobase+4) | 0x04, iobase+4);
 	       
 		mcr = MCR_MIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		mcr = MCR_MIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __func__);
 		break;
 	case 4000000:
 		mcr = MCR_FIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __func__);
 		break;
 	default:
 		mcr = MCR_FIR;
 		IRDA_DEBUG(0, "%s(), unknown baud rate of %d\n", 
-			   __FUNCTION__, speed);
+			   __func__, speed);
 		break;
 	}
 
@@ -1597,7 +1597,7 @@ static int nsc_ircc_pio_write(int iobase
 	int actual = 0;
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* Save current bank */
 	bank = inb(iobase+BSR);
@@ -1605,7 +1605,7 @@ static int nsc_ircc_pio_write(int iobase
 	switch_bank(iobase, BANK0);
 	if (!(inb_p(iobase+LSR) & LSR_TXEMP)) {
 		IRDA_DEBUG(4, "%s(), warning, FIFO not empty yet!\n",
-			   __FUNCTION__);
+			   __func__);
 
 		/* FIFO may still be filled to the Tx interrupt threshold */
 		fifo_size -= 17;
@@ -1618,7 +1618,7 @@ static int nsc_ircc_pio_write(int iobase
 	}
         
 	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __FUNCTION__, fifo_size, actual, len);
+		   __func__, fifo_size, actual, len);
 	
 	/* Restore bank */
 	outb(bank, iobase+BSR);
@@ -1639,7 +1639,7 @@ static int nsc_ircc_dma_xmit_complete(st
 	__u8 bank;
 	int ret = TRUE;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	iobase = self->io.fir_base;
 
@@ -1770,7 +1770,7 @@ static int nsc_ircc_dma_receive_complete
 		len = inb(iobase+RFLFL) | ((inb(iobase+RFLFH) & 0x1f) << 8);
 
 		if (st_fifo->tail >= MAX_RX_WINDOW) {
-			IRDA_DEBUG(0, "%s(), window is full!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), window is full!\n", __func__);
 			continue;
 		}
 			
@@ -1862,7 +1862,7 @@ static int nsc_ircc_dma_receive_complete
 			if (skb == NULL)  {
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
-					     __FUNCTION__);
+					     __func__);
 				self->stats.rx_dropped++;
 
 				/* Restore bank register */
@@ -1968,7 +1968,7 @@ static void nsc_ircc_sir_interrupt(struc
 		 * Need to be after self->io.direction to avoid race with
 		 * nsc_ircc_hard_xmit_sir() - Jean II */
 		if (self->new_speed) {
-			IRDA_DEBUG(2, "%s(), Changing speed!\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), Changing speed!\n", __func__);
 			self->ier = nsc_ircc_change_speed(self,
 							  self->new_speed);
 			self->new_speed = 0;
@@ -2054,7 +2054,7 @@ static void nsc_ircc_fir_interrupt(struc
 				} else
 					IRDA_WARNING("%s(), potential "
 						     "Tx queue lockup !\n",
-						     __FUNCTION__);
+						     __func__);
 			}
 		} else {
 			/*  Not finished yet, so interrupt on DMA again */
@@ -2163,7 +2163,7 @@ static int nsc_ircc_net_open(struct net_
 	char hwname[32];
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct nsc_ircc_cb *) dev->priv;
@@ -2225,7 +2225,7 @@ static int nsc_ircc_net_close(struct net
 	int iobase;
 	__u8 bank;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2279,7 +2279,7 @@ static int nsc_ircc_net_ioctl(struct net
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
diff -puN drivers/net/irda/old_belkin-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/old_belkin-sir.c
--- a/drivers/net/irda/old_belkin-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/old_belkin-sir.c
@@ -92,7 +92,7 @@ static int old_belkin_open(struct sir_de
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -110,7 +110,7 @@ static int old_belkin_open(struct sir_de
 
 static int old_belkin_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -125,7 +125,7 @@ static int old_belkin_close(struct sir_d
  */
 static int old_belkin_change_speed(struct sir_dev *dev, unsigned speed)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	dev->speed = 9600;
 	return (speed==dev->speed) ? 0 : -EINVAL;
@@ -139,7 +139,7 @@ static int old_belkin_change_speed(struc
  */
 static int old_belkin_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* This dongles speed "defaults" to 9600 bps ;-) */
 	dev->speed = 9600;
diff -puN drivers/net/irda/sir_dev.c~irda-replace-__function__-with-__func__ drivers/net/irda/sir_dev.c
--- a/drivers/net/irda/sir_dev.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/sir_dev.c
@@ -80,7 +80,7 @@ static int sirdev_tx_complete_fsm(struct
 			return 0;
 
 		default:
-			IRDA_ERROR("%s - undefined state\n", __FUNCTION__);
+			IRDA_ERROR("%s - undefined state\n", __func__);
 			return -EINVAL;
 		}
 		fsm->substate = next_state;
@@ -107,11 +107,11 @@ static void sirdev_config_fsm(struct wor
 	int ret = -1;
 	unsigned delay;
 
-	IRDA_DEBUG(2, "%s(), <%ld>\n", __FUNCTION__, jiffies);
+	IRDA_DEBUG(2, "%s(), <%ld>\n", __func__, jiffies);
 
 	do {
 		IRDA_DEBUG(3, "%s - state=0x%04x / substate=0x%04x\n",
-			__FUNCTION__, fsm->state, fsm->substate);
+			__func__, fsm->state, fsm->substate);
 
 		next_state = fsm->state;
 		delay = 0;
@@ -249,12 +249,12 @@ static void sirdev_config_fsm(struct wor
 			break;
 
 		default:
-			IRDA_ERROR("%s - undefined state\n", __FUNCTION__);
+			IRDA_ERROR("%s - undefined state\n", __func__);
 			fsm->result = -EINVAL;
 			/* fall thru */
 
 		case SIRDEV_STATE_ERROR:
-			IRDA_ERROR("%s - error: %d\n", __FUNCTION__, fsm->result);
+			IRDA_ERROR("%s - error: %d\n", __func__, fsm->result);
 
 #if 0	/* don't enable this before we have netdev->tx_timeout to recover */
 			netif_stop_queue(dev->netdev);
@@ -284,11 +284,11 @@ int sirdev_schedule_request(struct sir_d
 {
 	struct sir_fsm *fsm = &dev->fsm;
 
-	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __FUNCTION__, initial_state, param);
+	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __func__, initial_state, param);
 
 	if (!down_try(&fsm->sem)) {
 		if (in_interrupt()  ||  in_atomic()  ||  irqs_disabled()) {
-			IRDA_DEBUG(1, "%s(), state machine busy!\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), state machine busy!\n", __func__);
 			return -EWOULDBLOCK;
 		} else
 			down(&fsm->sem);
@@ -296,7 +296,7 @@ int sirdev_schedule_request(struct sir_d
 
 	if (fsm->state == SIRDEV_STATE_DEAD) {
 		/* race with sirdev_close should never happen */
-		IRDA_ERROR("%s(), instance staled!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), instance staled!\n", __func__);
 		up(&fsm->sem);
 		return -ESTALE;		/* or better EPIPE? */
 	}
@@ -341,7 +341,7 @@ int sirdev_set_dongle(struct sir_dev *de
 {
 	int err;
 
-	IRDA_DEBUG(3, "%s : requesting dongle %d.\n", __FUNCTION__, type);
+	IRDA_DEBUG(3, "%s : requesting dongle %d.\n", __func__, type);
 
 	err = sirdev_schedule_dongle_open(dev, type);
 	if (unlikely(err))
@@ -376,7 +376,7 @@ int sirdev_raw_write(struct sir_dev *dev
 
 	ret = dev->drv->do_write(dev, dev->tx_buff.data, dev->tx_buff.len);
 	if (ret > 0) {
-		IRDA_DEBUG(3, "%s(), raw-tx started\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), raw-tx started\n", __func__);
 
 		dev->tx_buff.data += ret;
 		dev->tx_buff.len -= ret;
@@ -437,7 +437,7 @@ void sirdev_write_complete(struct sir_de
 	spin_lock_irqsave(&dev->tx_lock, flags);
 
 	IRDA_DEBUG(3, "%s() - dev->tx_buff.len = %d\n",
-		   __FUNCTION__, dev->tx_buff.len);
+		   __func__, dev->tx_buff.len);
 
 	if (likely(dev->tx_buff.len > 0))  {
 		/* Write data left in transmit buffer */
@@ -450,7 +450,7 @@ void sirdev_write_complete(struct sir_de
 		else if (unlikely(actual<0)) {
 			/* could be dropped later when we have tx_timeout to recover */
 			IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-				   __FUNCTION__, actual);
+				   __func__, actual);
 			if ((skb=dev->tx_skb) != NULL) {
 				dev->tx_skb = NULL;
 				dev_kfree_skb_any(skb);
@@ -471,7 +471,7 @@ void sirdev_write_complete(struct sir_de
 		 * restarted when the irda-thread has completed the request.
 		 */
 
-		IRDA_DEBUG(3, "%s(), raw-tx done\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), raw-tx done\n", __func__);
 		dev->raw_tx = 0;
 		goto done;	/* no post-frame handling in raw mode */
 	}
@@ -488,7 +488,7 @@ void sirdev_write_complete(struct sir_de
 	 * re-activated.
 	 */
 
-	IRDA_DEBUG(5, "%s(), finished with frame!\n", __FUNCTION__);
+	IRDA_DEBUG(5, "%s(), finished with frame!\n", __func__);
 		
 	if ((skb=dev->tx_skb) != NULL) {
 		dev->tx_skb = NULL;
@@ -498,14 +498,14 @@ void sirdev_write_complete(struct sir_de
 	}
 
 	if (unlikely(dev->new_speed > 0)) {
-		IRDA_DEBUG(5, "%s(), Changing speed!\n", __FUNCTION__);
+		IRDA_DEBUG(5, "%s(), Changing speed!\n", __func__);
 		err = sirdev_schedule_speed(dev, dev->new_speed);
 		if (unlikely(err)) {
 			/* should never happen
 			 * forget the speed change and hope the stack recovers
 			 */
 			IRDA_ERROR("%s - schedule speed change failed: %d\n",
-				   __FUNCTION__, err);
+				   __func__, err);
 			netif_wake_queue(dev->netdev);
 		}
 		/* else: success
@@ -532,13 +532,13 @@ EXPORT_SYMBOL(sirdev_write_complete);
 int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count) 
 {
 	if (!dev || !dev->netdev) {
-		IRDA_WARNING("%s(), not ready yet!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), not ready yet!\n", __func__);
 		return -1;
 	}
 
 	if (!dev->irlap) {
 		IRDA_WARNING("%s - too early: %p / %zd!\n",
-			     __FUNCTION__, cp, count);
+			     __func__, cp, count);
 		return -1;
 	}
 
@@ -548,7 +548,7 @@ int sirdev_receive(struct sir_dev *dev, 
 		 */
 		irda_device_set_media_busy(dev->netdev, TRUE);
 		dev->stats.rx_dropped++;
-		IRDA_DEBUG(0, "%s; rx-drop: %zd\n", __FUNCTION__, count);
+		IRDA_DEBUG(0, "%s; rx-drop: %zd\n", __func__, count);
 		return 0;
 	}
 
@@ -600,7 +600,7 @@ static int sirdev_hard_xmit(struct sk_bu
 
 	netif_stop_queue(ndev);
 
-	IRDA_DEBUG(3, "%s(), skb->len = %d\n", __FUNCTION__, skb->len);
+	IRDA_DEBUG(3, "%s(), skb->len = %d\n", __func__, skb->len);
 
 	speed = irda_get_next_speed(skb);
 	if ((speed != dev->speed) && (speed != -1)) {
@@ -637,7 +637,7 @@ static int sirdev_hard_xmit(struct sk_bu
 
 	/* Check problems */
 	if(spin_is_locked(&dev->tx_lock)) {
-		IRDA_DEBUG(3, "%s(), write not completed\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), write not completed\n", __func__);
 	}
 
 	/* serialize with write completion */
@@ -666,7 +666,7 @@ static int sirdev_hard_xmit(struct sk_bu
 	else if (unlikely(actual < 0)) {
 		/* could be dropped later when we have tx_timeout to recover */
 		IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-			   __FUNCTION__, actual);
+			   __func__, actual);
 		dev_kfree_skb_any(skb);
 		dev->stats.tx_errors++;		      
 		dev->stats.tx_dropped++;		      
@@ -687,7 +687,7 @@ static int sirdev_ioctl(struct net_devic
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	IRDA_DEBUG(3, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, ndev->name, cmd);
+	IRDA_DEBUG(3, "%s(), %s, (cmd=0x%X)\n", __func__, ndev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -804,7 +804,7 @@ static int sirdev_open(struct net_device
 	if (!try_module_get(drv->owner))
 		return -ESTALE;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (sirdev_alloc_buffers(dev))
 		goto errout_dec;
@@ -822,7 +822,7 @@ static int sirdev_open(struct net_device
 
 	netif_wake_queue(ndev);
 
-	IRDA_DEBUG(2, "%s - done, speed = %d\n", __FUNCTION__, dev->speed);
+	IRDA_DEBUG(2, "%s - done, speed = %d\n", __func__, dev->speed);
 
 	return 0;
 
@@ -842,7 +842,7 @@ static int sirdev_close(struct net_devic
 	struct sir_dev *dev = ndev->priv;
 	const struct sir_driver *drv;
 
-//	IRDA_DEBUG(0, "%s\n", __FUNCTION__);
+//	IRDA_DEBUG(0, "%s\n", __func__);
 
 	netif_stop_queue(ndev);
 
@@ -878,7 +878,7 @@ struct sir_dev * sirdev_get_instance(con
 	struct net_device *ndev;
 	struct sir_dev *dev;
 
-	IRDA_DEBUG(0, "%s - %s\n", __FUNCTION__, name);
+	IRDA_DEBUG(0, "%s - %s\n", __func__, name);
 
 	/* instead of adding tests to protect against drv->do_write==NULL
 	 * at several places we refuse to create a sir_dev instance for
@@ -892,7 +892,7 @@ struct sir_dev * sirdev_get_instance(con
 	 */
 	ndev = alloc_irdadev(sizeof(*dev));
 	if (ndev == NULL) {
-		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __FUNCTION__);
+		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __func__);
 		goto out;
 	}
 	dev = ndev->priv;
@@ -921,7 +921,7 @@ struct sir_dev * sirdev_get_instance(con
 	ndev->do_ioctl = sirdev_ioctl;
 
 	if (register_netdev(ndev)) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
 		goto out_freenetdev;
 	}
 
@@ -938,7 +938,7 @@ int sirdev_put_instance(struct sir_dev *
 {
 	int err = 0;
 
-	IRDA_DEBUG(0, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s\n", __func__);
 
 	atomic_set(&dev->enable_rx, 0);
 
@@ -948,7 +948,7 @@ int sirdev_put_instance(struct sir_dev *
 	if (dev->dongle_drv)
 		err = sirdev_schedule_dongle_close(dev);
 	if (err)
-		IRDA_ERROR("%s - error %d\n", __FUNCTION__, err);
+		IRDA_ERROR("%s - error %d\n", __func__, err);
 
 	sirdev_close(dev->netdev);
 
diff -puN drivers/net/irda/sir_dongle.c~irda-replace-__function__-with-__func__ drivers/net/irda/sir_dongle.c
--- a/drivers/net/irda/sir_dongle.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/sir_dongle.c
@@ -36,7 +36,7 @@ int irda_register_dongle(struct dongle_d
 	struct dongle_driver *drv;
 
 	IRDA_DEBUG(0, "%s : registering dongle \"%s\" (%d).\n",
-		   __FUNCTION__, new->driver_name, new->type);
+		   __func__, new->driver_name, new->type);
 
 	mutex_lock(&dongle_list_lock);
 	list_for_each(entry, &dongle_list) {
diff -puN drivers/net/irda/smsc-ircc2.c~irda-replace-__function__-with-__func__ drivers/net/irda/smsc-ircc2.c
--- a/drivers/net/irda/smsc-ircc2.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/smsc-ircc2.c
@@ -460,7 +460,7 @@ static int __init smsc_ircc_init(void)
 {
 	int ret;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	ret = platform_driver_register(&smsc_ircc_driver);
 	if (ret) {
@@ -500,7 +500,7 @@ static int __init smsc_ircc_open(unsigne
 	struct net_device *dev;
 	int err;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	err = smsc_ircc_present(fir_base, sir_base);
 	if (err)
@@ -508,7 +508,7 @@ static int __init smsc_ircc_open(unsigne
 
 	err = -ENOMEM;
 	if (dev_count >= ARRAY_SIZE(dev_self)) {
-	        IRDA_WARNING("%s(), too many devices!\n", __FUNCTION__);
+	        IRDA_WARNING("%s(), too many devices!\n", __func__);
 		goto err_out1;
 	}
 
@@ -517,7 +517,7 @@ static int __init smsc_ircc_open(unsigne
 	 */
 	dev = alloc_irdadev(sizeof(struct smsc_ircc_cb));
 	if (!dev) {
-		IRDA_WARNING("%s() can't allocate net device\n", __FUNCTION__);
+		IRDA_WARNING("%s() can't allocate net device\n", __func__);
 		goto err_out1;
 	}
 
@@ -633,14 +633,14 @@ static int smsc_ircc_present(unsigned in
 	if (!request_region(fir_base, SMSC_IRCC2_FIR_CHIP_IO_EXTENT,
 			    driver_name)) {
 		IRDA_WARNING("%s: can't get fir_base of 0x%03x\n",
-			     __FUNCTION__, fir_base);
+			     __func__, fir_base);
 		goto out1;
 	}
 
 	if (!request_region(sir_base, SMSC_IRCC2_SIR_CHIP_IO_EXTENT,
 			    driver_name)) {
 		IRDA_WARNING("%s: can't get sir_base of 0x%03x\n",
-			     __FUNCTION__, sir_base);
+			     __func__, sir_base);
 		goto out2;
 	}
 
@@ -656,7 +656,7 @@ static int smsc_ircc_present(unsigned in
 
 	if (high != 0x10 || low != 0xb8 || (chip != 0xf1 && chip != 0xf2)) {
 		IRDA_WARNING("%s(), addr 0x%04x - no device found!\n",
-			     __FUNCTION__, fir_base);
+			     __func__, fir_base);
 		goto out3;
 	}
 	IRDA_MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
@@ -793,7 +793,7 @@ static int smsc_ircc_net_ioctl(struct ne
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -878,7 +878,7 @@ int smsc_ircc_hard_xmit_sir(struct sk_bu
 	unsigned long flags;
 	s32 speed;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return 0;);
 
@@ -953,21 +953,21 @@ static void smsc_ircc_set_fir_speed(stru
 		ir_mode = IRCC_CFGA_IRDA_HDLC;
 		ctrl = IRCC_CRC;
 		fast = 0;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__);
 		break;
 	case 1152000:
 		ir_mode = IRCC_CFGA_IRDA_HDLC;
 		ctrl = IRCC_1152 | IRCC_CRC;
 		fast = IRCC_LCR_A_FAST | IRCC_LCR_A_GP_DATA;
 		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n",
-			   __FUNCTION__);
+			   __func__);
 		break;
 	case 4000000:
 		ir_mode = IRCC_CFGA_IRDA_4PPM;
 		ctrl = IRCC_CRC;
 		fast = IRCC_LCR_A_FAST;
 		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n",
-			   __FUNCTION__);
+			   __func__);
 		break;
 	}
 	#if 0
@@ -995,7 +995,7 @@ static void smsc_ircc_fir_start(struct s
 	struct net_device *dev;
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1043,7 +1043,7 @@ static void smsc_ircc_fir_stop(struct sm
 {
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1067,7 +1067,7 @@ static void smsc_ircc_change_speed(struc
 	struct net_device *dev;
 	int last_speed_was_sir;
 
-	IRDA_DEBUG(0, "%s() changing speed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(0, "%s() changing speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1135,7 +1135,7 @@ void smsc_ircc_set_sir_speed(struct smsc
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(0, "%s(), Setting speed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(0, "%s(), Setting speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	iobase = self->io.sir_base;
@@ -1170,7 +1170,7 @@ void smsc_ircc_set_sir_speed(struct smsc
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI | UART_IER_THRI, iobase + UART_IER);
 
-	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __func__, speed);
 }
 
 
@@ -1253,7 +1253,7 @@ static void smsc_ircc_dma_xmit(struct sm
 	int iobase = self->io.fir_base;
 	u8 ctrl;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 1
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1307,7 +1307,7 @@ static void smsc_ircc_dma_xmit_complete(
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 0
 	/* Disable Tx */
 	register_bank(iobase, 0);
@@ -1411,7 +1411,7 @@ static void smsc_ircc_dma_receive_comple
 
 	register_bank(iobase, 0);
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 0
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1422,7 +1422,7 @@ static void smsc_ircc_dma_receive_comple
 	lsr= inb(iobase + IRCC_LSR);
 	msgcnt = inb(iobase + IRCC_LCR_B) & 0x08;
 
-	IRDA_DEBUG(2, "%s: dma count = %d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s: dma count = %d\n", __func__,
 		   get_dma_residue(self->io.dma));
 
 	len = self->rx_buff.truesize - get_dma_residue(self->io.dma);
@@ -1445,15 +1445,15 @@ static void smsc_ircc_dma_receive_comple
 	len -= self->io.speed < 4000000 ? 2 : 4;
 
 	if (len < 2 || len > 2050) {
-		IRDA_WARNING("%s(), bogus len=%d\n", __FUNCTION__, len);
+		IRDA_WARNING("%s(), bogus len=%d\n", __func__, len);
 		return;
 	}
-	IRDA_DEBUG(2, "%s: msgcnt = %d, len=%d\n", __FUNCTION__, msgcnt, len);
+	IRDA_DEBUG(2, "%s: msgcnt = %d, len=%d\n", __func__, msgcnt, len);
 
 	skb = dev_alloc_skb(len + 1);
 	if (!skb) {
 		IRDA_WARNING("%s(), memory squeeze, dropping frame.\n",
-			     __FUNCTION__);
+			     __func__);
 		return;
 	}
 	/* Make sure IP header gets aligned */
@@ -1494,7 +1494,7 @@ static void smsc_ircc_sir_receive(struct
 
 		/* Make sure we don't stay here to long */
 		if (boguscount++ > 32) {
-			IRDA_DEBUG(2, "%s(), breaking!\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), breaking!\n", __func__);
 			break;
 		}
 	} while (inb(iobase + UART_LSR) & UART_LSR_DR);
@@ -1536,7 +1536,7 @@ static irqreturn_t smsc_ircc_interrupt(i
 	lcra = inb(iobase + IRCC_LCR_A);
 	lsr = inb(iobase + IRCC_LSR);
 
-	IRDA_DEBUG(2, "%s(), iir = 0x%02x\n", __FUNCTION__, iir);
+	IRDA_DEBUG(2, "%s(), iir = 0x%02x\n", __func__, iir);
 
 	if (iir & IRCC_IIR_EOM) {
 		if (self->io.direction == IO_RECV)
@@ -1548,7 +1548,7 @@ static irqreturn_t smsc_ircc_interrupt(i
 	}
 
 	if (iir & IRCC_IIR_ACTIVE_FRAME) {
-		/*printk(KERN_WARNING "%s(): Active Frame\n", __FUNCTION__);*/
+		/*printk(KERN_WARNING "%s(): Active Frame\n", __func__);*/
 	}
 
 	/* Enable interrupts again */
@@ -1587,11 +1587,11 @@ static irqreturn_t smsc_ircc_interrupt_s
 		lsr = inb(iobase + UART_LSR);
 
 		IRDA_DEBUG(4, "%s(), iir=%02x, lsr=%02x, iobase=%#x\n",
-			    __FUNCTION__, iir, lsr, iobase);
+			    __func__, iir, lsr, iobase);
 
 		switch (iir) {
 		case UART_IIR_RLSI:
-			IRDA_DEBUG(2, "%s(), RLSI\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), RLSI\n", __func__);
 			break;
 		case UART_IIR_RDI:
 			/* Receive interrupt */
@@ -1604,7 +1604,7 @@ static irqreturn_t smsc_ircc_interrupt_s
 			break;
 		default:
 			IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n",
-				   __FUNCTION__, iir);
+				   __func__, iir);
 			break;
 		}
 
@@ -1631,11 +1631,11 @@ static int ircc_is_receiving(struct smsc
 	int status = FALSE;
 	/* int iobase; */
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
-	IRDA_DEBUG(0, "%s: dma count = %d\n", __FUNCTION__,
+	IRDA_DEBUG(0, "%s: dma count = %d\n", __func__,
 		   get_dma_residue(self->io.dma));
 
 	status = (self->rx_buff.state != OUTSIDE_FRAME);
@@ -1652,7 +1652,7 @@ static int smsc_ircc_request_irq(struct 
 			    self->netdev->name, self->netdev);
 	if (error)
 		IRDA_DEBUG(0, "%s(), unable to allocate irq=%d, err=%d\n",
-			   __FUNCTION__, self->io.irq, error);
+			   __func__, self->io.irq, error);
 
 	return error;
 }
@@ -1696,21 +1696,21 @@ static int smsc_ircc_net_open(struct net
 	struct smsc_ircc_cb *self;
 	char hwname[16];
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 	IRDA_ASSERT(self != NULL, return 0;);
 
 	if (self->io.suspended) {
-		IRDA_DEBUG(0, "%s(), device is suspended\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), device is suspended\n", __func__);
 		return -EAGAIN;
 	}
 
 	if (request_irq(self->io.irq, smsc_ircc_interrupt, 0, dev->name,
 			(void *) dev)) {
 		IRDA_DEBUG(0, "%s(), unable to allocate irq=%d\n",
-			   __FUNCTION__, self->io.irq);
+			   __func__, self->io.irq);
 		return -EAGAIN;
 	}
 
@@ -1734,7 +1734,7 @@ static int smsc_ircc_net_open(struct net
 		smsc_ircc_net_close(dev);
 
 		IRDA_WARNING("%s(), unable to allocate DMA=%d\n",
-			     __FUNCTION__, self->io.dma);
+			     __func__, self->io.dma);
 		return -EAGAIN;
 	}
 
@@ -1753,7 +1753,7 @@ static int smsc_ircc_net_close(struct ne
 {
 	struct smsc_ircc_cb *self;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
@@ -1836,7 +1836,7 @@ static int smsc_ircc_resume(struct platf
  */
 static int __exit smsc_ircc_close(struct smsc_ircc_cb *self)
 {
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -1848,12 +1848,12 @@ static int __exit smsc_ircc_close(struct
 	smsc_ircc_stop_interrupts(self);
 
 	/* Release the PORTS that this driver is using */
-	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n",  __FUNCTION__,
+	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n",  __func__,
 		   self->io.fir_base);
 
 	release_region(self->io.fir_base, self->io.fir_ext);
 
-	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n", __FUNCTION__,
+	IRDA_DEBUG(0, "%s(), releasing 0x%03x\n", __func__,
 		   self->io.sir_base);
 
 	release_region(self->io.sir_base, self->io.sir_ext);
@@ -1875,7 +1875,7 @@ static void __exit smsc_ircc_cleanup(voi
 {
 	int i;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	for (i = 0; i < 2; i++) {
 		if (dev_self[i])
@@ -1899,7 +1899,7 @@ void smsc_ircc_sir_start(struct smsc_irc
 	struct net_device *dev;
 	int fir_base, sir_base;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1926,7 +1926,7 @@ void smsc_ircc_sir_start(struct smsc_irc
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI |UART_IER_THRI, sir_base + UART_IER);
 
-	IRDA_DEBUG(3, "%s() - exit\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s() - exit\n", __func__);
 
 	outb(0x00, fir_base + IRCC_MASTER);
 }
@@ -1936,7 +1936,7 @@ void smsc_ircc_sir_stop(struct smsc_ircc
 {
 	int iobase;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 	iobase = self->io.sir_base;
 
 	/* Reset UART */
@@ -1962,7 +1962,7 @@ static void smsc_ircc_sir_write_wakeup(s
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s\n", __func__);
 
 	iobase = self->io.sir_base;
 
@@ -1984,7 +1984,7 @@ static void smsc_ircc_sir_write_wakeup(s
 		 */
 		if (self->new_speed) {
 			IRDA_DEBUG(5, "%s(), Changing speed to %d.\n",
-				   __FUNCTION__, self->new_speed);
+				   __func__, self->new_speed);
 			smsc_ircc_sir_wait_hw_transmitter_finish(self);
 			smsc_ircc_change_speed(self, self->new_speed);
 			self->new_speed = 0;
@@ -2023,7 +2023,7 @@ static int smsc_ircc_sir_write(int iobas
 
 	/* Tx FIFO should be empty! */
 	if (!(inb(iobase + UART_LSR) & UART_LSR_THRE)) {
-		IRDA_WARNING("%s(), failed, fifo not empty!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed, fifo not empty!\n", __func__);
 		return 0;
 	}
 
@@ -2123,7 +2123,7 @@ static void smsc_ircc_sir_wait_hw_transm
 		udelay(1);
 
 	if (count == 0)
-		IRDA_DEBUG(0, "%s(): stuck transmitter\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(): stuck transmitter\n", __func__);
 }
 
 
@@ -2145,7 +2145,7 @@ static int __init smsc_ircc_look_for_chi
 	while (address->cfg_base) {
 		cfg_base = address->cfg_base;
 
-		/*printk(KERN_WARNING "%s(): probing: 0x%02x for: 0x%02x\n", __FUNCTION__, cfg_base, address->type);*/
+		/*printk(KERN_WARNING "%s(): probing: 0x%02x for: 0x%02x\n", __func__, cfg_base, address->type);*/
 
 		if (address->type & SMSCSIO_TYPE_FDC) {
 			type = "FDC";
@@ -2184,7 +2184,7 @@ static int __init smsc_superio_flat(cons
 	u8 mode, dma, irq;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	if (smsc_ircc_probe(cfgbase, SMSCSIOFLAT_DEVICEID_REG, chips, type) == NULL)
 		return ret;
@@ -2192,10 +2192,10 @@ static int __init smsc_superio_flat(cons
 	outb(SMSCSIOFLAT_UARTMODE0C_REG, cfgbase);
 	mode = inb(cfgbase + 1);
 
-	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __FUNCTION__, mode);*/
+	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __func__, mode);*/
 
 	if (!(mode & SMSCSIOFLAT_UART2MODE_VAL_IRDA))
-		IRDA_WARNING("%s(): IrDA not enabled\n", __FUNCTION__);
+		IRDA_WARNING("%s(): IrDA not enabled\n", __func__);
 
 	outb(SMSCSIOFLAT_UART2BASEADDR_REG, cfgbase);
 	sirbase = inb(cfgbase + 1) << 2;
@@ -2212,7 +2212,7 @@ static int __init smsc_superio_flat(cons
 	outb(SMSCSIOFLAT_UARTIRQSELECT_REG, cfgbase);
 	irq = inb(cfgbase + 1) & SMSCSIOFLAT_UART2IRQSELECT_MASK;
 
-	IRDA_MESSAGE("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n", __FUNCTION__, firbase, sirbase, dma, irq, mode);
+	IRDA_MESSAGE("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n", __func__, firbase, sirbase, dma, irq, mode);
 
 	if (firbase && smsc_ircc_open(firbase, sirbase, dma, irq) == 0)
 		ret = 0;
@@ -2234,7 +2234,7 @@ static int __init smsc_superio_paged(con
 	unsigned short fir_io, sir_io;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	if (smsc_ircc_probe(cfg_base, 0x20, chips, type) == NULL)
 		return ret;
@@ -2268,7 +2268,7 @@ static int __init smsc_superio_paged(con
 
 static int __init smsc_access(unsigned short cfg_base, unsigned char reg)
 {
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	outb(reg, cfg_base);
 	return inb(cfg_base) != reg ? -1 : 0;
@@ -2278,7 +2278,7 @@ static const struct smsc_chip * __init s
 {
 	u8 devid, xdevid, rev;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	/* Leave configuration */
 
@@ -2353,7 +2353,7 @@ static int __init smsc_superio_fdc(unsig
 
 	if (!request_region(cfg_base, 2, driver_name)) {
 		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __FUNCTION__, cfg_base);
+			     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(fdc_chips_flat, cfg_base, "FDC") ||
 		    !smsc_superio_paged(fdc_chips_paged, cfg_base, "FDC"))
@@ -2371,7 +2371,7 @@ static int __init smsc_superio_lpc(unsig
 
 	if (!request_region(cfg_base, 2, driver_name)) {
 		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __FUNCTION__, cfg_base);
+			     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(lpc_chips_flat, cfg_base, "LPC") ||
 		    !smsc_superio_paged(lpc_chips_paged, cfg_base, "LPC"))
@@ -2932,7 +2932,7 @@ static void smsc_ircc_set_transceiver_sm
 		/* empty */;
 
 	if (val)
-		IRDA_WARNING("%s(): ATC: 0x%02x\n", __FUNCTION__,
+		IRDA_WARNING("%s(): ATC: 0x%02x\n", __func__,
 			     inb(fir_base + IRCC_ATC));
 }
 
diff -puN drivers/net/irda/tekram-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/tekram-sir.c
--- a/drivers/net/irda/tekram-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/tekram-sir.c
@@ -77,7 +77,7 @@ static int tekram_open(struct sir_dev *d
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -92,7 +92,7 @@ static int tekram_open(struct sir_dev *d
 
 static int tekram_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -130,7 +130,7 @@ static int tekram_change_speed(struct si
 	u8 byte;
 	static int ret = 0;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -179,7 +179,7 @@ static int tekram_change_speed(struct si
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -204,7 +204,7 @@ static int tekram_change_speed(struct si
 
 static int tekram_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Clear DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
diff -puN drivers/net/irda/toim3232-sir.c~irda-replace-__function__-with-__func__ drivers/net/irda/toim3232-sir.c
--- a/drivers/net/irda/toim3232-sir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/toim3232-sir.c
@@ -181,7 +181,7 @@ static int toim3232_open(struct sir_dev 
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Pull the lines high to start with.
 	 *
@@ -209,7 +209,7 @@ static int toim3232_open(struct sir_dev 
 
 static int toim3232_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -241,7 +241,7 @@ static int toim3232_change_speed(struct 
 	u8 byte;
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -299,7 +299,7 @@ static int toim3232_change_speed(struct 
 		break;
 
 	default:
-		printk(KERN_ERR "%s - undefined state %d\n", __FUNCTION__, state);
+		printk(KERN_ERR "%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -344,7 +344,7 @@ static int toim3232_change_speed(struct 
 
 static int toim3232_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Switch off both DTR and RTS to switch off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
diff -puN drivers/net/irda/via-ircc.c~irda-replace-__function__-with-__func__ drivers/net/irda/via-ircc.c
--- a/drivers/net/irda/via-ircc.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/via-ircc.c
@@ -152,12 +152,12 @@ static int __init via_ircc_init(void)
 {
 	int rc;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	rc = pci_register_driver(&via_driver);
 	if (rc < 0) {
 		IRDA_DEBUG(0, "%s(): error rc = %d, returning  -ENODEV...\n",
-			   __FUNCTION__, rc);
+			   __func__, rc);
 		return -ENODEV;
 	}
 	return 0;
@@ -170,11 +170,11 @@ static int __devinit via_init_one (struc
 	u16 Chipset,FirDRQ1,FirDRQ0,FirIRQ,FirIOBase;
 	chipio_t info;
 
-	IRDA_DEBUG(2, "%s(): Device ID=(0X%X)\n", __FUNCTION__, id->device);
+	IRDA_DEBUG(2, "%s(): Device ID=(0X%X)\n", __func__, id->device);
 
 	rc = pci_enable_device (pcidev);
 	if (rc) {
-		IRDA_DEBUG(0, "%s(): error rc = %d\n", __FUNCTION__, rc);
+		IRDA_DEBUG(0, "%s(): error rc = %d\n", __func__, rc);
 		return -ENODEV;
 	}
 
@@ -185,7 +185,7 @@ static int __devinit via_init_one (struc
 		Chipset=0x3076;
 
 	if (Chipset==0x3076) {
-		IRDA_DEBUG(2, "%s(): Chipset = 3076\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(): Chipset = 3076\n", __func__);
 
 		WriteLPCReg(7,0x0c );
 		temp=ReadLPCReg(0x30);//check if BIOS Enable Fir
@@ -222,7 +222,7 @@ static int __devinit via_init_one (struc
 		} else
 			rc = -ENODEV; //IR not turn on	 
 	} else { //Not VT1211
-		IRDA_DEBUG(2, "%s(): Chipset = 3096\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(): Chipset = 3096\n", __func__);
 
 		pci_read_config_byte(pcidev,0x67,&bTmp);//check if BIOS Enable Fir
 		if((bTmp&0x01)==1) {  // BIOS enable FIR
@@ -262,7 +262,7 @@ static int __devinit via_init_one (struc
 			rc = -ENODEV; //IR not turn on !!!!!
 	}//Not VT1211
 
-	IRDA_DEBUG(2, "%s(): End - rc = %d\n", __FUNCTION__, rc);
+	IRDA_DEBUG(2, "%s(): End - rc = %d\n", __func__, rc);
 	return rc;
 }
 
@@ -276,7 +276,7 @@ static void via_ircc_clean(void)
 {
 	int i;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
@@ -286,7 +286,7 @@ static void via_ircc_clean(void)
 
 static void __devexit via_remove_one (struct pci_dev *pdev)
 {
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	/* FIXME : This is ugly. We should use pci_get_drvdata(pdev);
 	 * to get our driver instance and call directly via_ircc_close().
@@ -301,7 +301,7 @@ static void __devexit via_remove_one (st
 
 static void __exit via_ircc_cleanup(void)
 {
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	/* FIXME : This should be redundant, as pci_unregister_driver()
 	 * should call via_remove_one() on each device.
@@ -324,7 +324,7 @@ static __devinit int via_ircc_open(int i
 	struct via_ircc_cb *self;
 	int err;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	if (i >= ARRAY_SIZE(dev_self))
 		return -ENOMEM;
@@ -360,7 +360,7 @@ static __devinit int via_ircc_open(int i
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext, driver_name)) {
 		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
-			   __FUNCTION__, self->io.fir_base);
+			   __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
 	}
@@ -471,7 +471,7 @@ static int via_ircc_close(struct via_irc
 {
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -483,7 +483,7 @@ static int via_ircc_close(struct via_irc
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(2, "%s(), Releasing Region %03x\n",
-		   __FUNCTION__, self->io.fir_base);
+		   __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 	if (self->tx_buff.head)
 		dma_free_coherent(NULL, self->tx_buff.truesize,
@@ -509,7 +509,7 @@ static void via_hw_init(struct via_ircc_
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	SetMaxRxPacketSize(iobase, 0x0fff);	//set to max:4095
 	// FIFO Init
@@ -582,7 +582,7 @@ static void via_ircc_change_dongle_speed
 	speed = speed;
 
 	IRDA_DEBUG(1, "%s(): change_dongle_speed to %d for 0x%x, %d\n",
-		   __FUNCTION__, speed, iobase, dongle_id);
+		   __func__, speed, iobase, dongle_id);
 
 	switch (dongle_id) {
 
@@ -671,7 +671,7 @@ static void via_ircc_change_dongle_speed
 
 	case 0x11:		/* Temic TFDS4500 */
 
-		IRDA_DEBUG(2, "%s: Temic TFDS4500: One RX pin, TX normal, RX inverted.\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s: Temic TFDS4500: One RX pin, TX normal, RX inverted.\n", __func__);
 
 		UseOneRX(iobase, ON);	//use ONE RX....RX1
 		InvertTX(iobase, OFF);
@@ -689,7 +689,7 @@ static void via_ircc_change_dongle_speed
 			SlowIRRXLowActive(iobase, OFF);
 
 		} else{
-			IRDA_DEBUG(0, "%s: Warning: TFDS4500 not running in SIR mode !\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s: Warning: TFDS4500 not running in SIR mode !\n", __func__);
 		}
 		break;
 
@@ -707,7 +707,7 @@ static void via_ircc_change_dongle_speed
 
 	default:
 		IRDA_ERROR("%s: Error: dongle_id %d unsupported !\n",
-			   __FUNCTION__, dongle_id);
+			   __func__, dongle_id);
 	}
 }
 
@@ -726,7 +726,7 @@ static void via_ircc_change_speed(struct
 	iobase = self->io.fir_base;
 	/* Update accounting for new speed */
 	self->io.speed = speed;
-	IRDA_DEBUG(1, "%s: change_speed to %d bps.\n", __FUNCTION__, speed);
+	IRDA_DEBUG(1, "%s: change_speed to %d bps.\n", __func__, speed);
 
 	WriteReg(iobase, I_ST_CT_0, 0x0);
 
@@ -957,7 +957,7 @@ static int via_ircc_dma_xmit(struct via_
 			self->tx_buff.head) + self->tx_buff_dma,
 		       self->tx_fifo.queue[self->tx_fifo.ptr].len, DMA_TX_MODE);
 	IRDA_DEBUG(1, "%s: tx_fifo.ptr=%x,len=%x,tx_fifo.len=%x..\n",
-		   __FUNCTION__, self->tx_fifo.ptr,
+		   __func__, self->tx_fifo.ptr,
 		   self->tx_fifo.queue[self->tx_fifo.ptr].len,
 		   self->tx_fifo.len);
 
@@ -981,7 +981,7 @@ static int via_ircc_dma_xmit_complete(st
 	int ret = TRUE;
 	u8 Tx_status;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	iobase = self->io.fir_base;
 	/* Disable DMA */
@@ -1014,7 +1014,7 @@ static int via_ircc_dma_xmit_complete(st
 	}
 	IRDA_DEBUG(1,
 		   "%s: tx_fifo.len=%x ,tx_fifo.ptr=%x,tx_fifo.free=%x...\n",
-		   __FUNCTION__,
+		   __func__,
 		   self->tx_fifo.len, self->tx_fifo.ptr, self->tx_fifo.free);
 /* F01_S
 	// Any frames to be sent back-to-back? 
@@ -1050,7 +1050,7 @@ static int via_ircc_dma_receive(struct v
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	self->tx_fifo.len = self->tx_fifo.ptr = self->tx_fifo.free = 0;
 	self->tx_fifo.tail = self->tx_buff.head;
@@ -1134,13 +1134,13 @@ static int via_ircc_dma_receive_complete
 			return TRUE;	//interrupt only, data maybe move by RxT  
 		if (((len - 4) < 2) || ((len - 4) > 2048)) {
 			IRDA_DEBUG(1, "%s(): Trouble:len=%x,CurCount=%x,LastCount=%x..\n",
-				   __FUNCTION__, len, RxCurCount(iobase, self),
+				   __func__, len, RxCurCount(iobase, self),
 				   self->RxLastCount);
 			hwreset(self);
 			return FALSE;
 		}
 		IRDA_DEBUG(2, "%s(): fifo.len=%x,len=%x,CurCount=%x..\n",
-			   __FUNCTION__,
+			   __func__,
 			   st_fifo->len, len - 4, RxCurCount(iobase, self));
 
 		st_fifo->entries[st_fifo->tail].status = status;
@@ -1187,7 +1187,7 @@ F01_E */
 		skb_put(skb, len - 4);
 
 		skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
-		IRDA_DEBUG(2, "%s(): len=%x.rx_buff=%p\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(): len=%x.rx_buff=%p\n", __func__,
 			   len - 4, self->rx_buff.data);
 
 		// Move to next frame 
@@ -1217,7 +1217,7 @@ static int upload_rxdata(struct via_ircc
 
 	len = GetRecvByte(iobase, self);
 
-	IRDA_DEBUG(2, "%s(): len=%x\n", __FUNCTION__, len);
+	IRDA_DEBUG(2, "%s(): len=%x\n", __func__, len);
 
 	if ((len - 4) < 2) {
 		self->stats.rx_dropped++;
@@ -1302,7 +1302,7 @@ static int RxTimerHandler(struct via_irc
 			skb_put(skb, len - 4);
 			skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
 
-			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __FUNCTION__,
+			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __func__,
 				   len - 4, st_fifo->head);
 
 			// Move to next frame 
@@ -1318,7 +1318,7 @@ static int RxTimerHandler(struct via_irc
 
 		IRDA_DEBUG(2,
 			   "%s(): End of upload HostStatus=%x,RxStatus=%x\n",
-			   __FUNCTION__,
+			   __func__,
 			   GetHostStatus(iobase), GetRXStatus(iobase));
 
 		/*
@@ -1358,7 +1358,7 @@ static irqreturn_t via_ircc_interrupt(in
 	iHostIntType = GetHostStatus(iobase);
 
 	IRDA_DEBUG(4, "%s(): iHostIntType %02x:  %s %s %s  %02x\n",
-		   __FUNCTION__, iHostIntType,
+		   __func__, iHostIntType,
 		   (iHostIntType & 0x40) ? "Timer" : "",
 		   (iHostIntType & 0x20) ? "Tx" : "",
 		   (iHostIntType & 0x10) ? "Rx" : "",
@@ -1388,7 +1388,7 @@ static irqreturn_t via_ircc_interrupt(in
 		iTxIntType = GetTXStatus(iobase);
 
 		IRDA_DEBUG(4, "%s(): iTxIntType %02x:  %s %s %s %s\n",
-			   __FUNCTION__, iTxIntType,
+			   __func__, iTxIntType,
 			   (iTxIntType & 0x08) ? "FIFO underr." : "",
 			   (iTxIntType & 0x04) ? "EOM" : "",
 			   (iTxIntType & 0x02) ? "FIFO ready" : "",
@@ -1412,7 +1412,7 @@ static irqreturn_t via_ircc_interrupt(in
 		iRxIntType = GetRXStatus(iobase);
 
 		IRDA_DEBUG(4, "%s(): iRxIntType %02x:  %s %s %s %s %s %s %s\n",
-			   __FUNCTION__, iRxIntType,
+			   __func__, iRxIntType,
 			   (iRxIntType & 0x80) ? "PHY err."	: "",
 			   (iRxIntType & 0x40) ? "CRC err"	: "",
 			   (iRxIntType & 0x20) ? "FIFO overr."	: "",
@@ -1421,7 +1421,7 @@ static irqreturn_t via_ircc_interrupt(in
 			   (iRxIntType & 0x02) ? "RxMaxLen"	: "",
 			   (iRxIntType & 0x01) ? "SIR bad"	: "");
 		if (!iRxIntType)
-			IRDA_DEBUG(3, "%s(): RxIRQ =0\n", __FUNCTION__);
+			IRDA_DEBUG(3, "%s(): RxIRQ =0\n", __func__);
 
 		if (iRxIntType & 0x10) {
 			if (via_ircc_dma_receive_complete(self, iobase)) {
@@ -1431,7 +1431,7 @@ static irqreturn_t via_ircc_interrupt(in
 		}		// No ERR     
 		else {		//ERR
 			IRDA_DEBUG(4, "%s(): RxIRQ ERR:iRxIntType=%x,HostIntType=%x,CurCount=%x,RxLastCount=%x_____\n",
-				   __FUNCTION__, iRxIntType, iHostIntType,
+				   __func__, iRxIntType, iHostIntType,
 				   RxCurCount(iobase, self),
 				   self->RxLastCount);
 
@@ -1456,7 +1456,7 @@ static void hwreset(struct via_ircc_cb *
 	int iobase;
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	ResetChip(iobase, 5);
 	EnableDMA(iobase, OFF);
@@ -1501,7 +1501,7 @@ static int via_ircc_is_receiving(struct 
 	if (CkRxRecv(iobase, self))
 		status = TRUE;
 
-	IRDA_DEBUG(2, "%s(): status=%x....\n", __FUNCTION__, status);
+	IRDA_DEBUG(2, "%s(): status=%x....\n", __func__, status);
 
 	return status;
 }
@@ -1519,7 +1519,7 @@ static int via_ircc_net_open(struct net_
 	int iobase;
 	char hwname[32];
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct via_ircc_cb *) dev->priv;
@@ -1586,7 +1586,7 @@ static int via_ircc_net_close(struct net
 	struct via_ircc_cb *self;
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct via_ircc_cb *) dev->priv;
@@ -1630,7 +1630,7 @@ static int via_ircc_net_ioctl(struct net
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = dev->priv;
 	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name,
+	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
 		   cmd);
 	/* Disable interrupts & save flags */
 	spin_lock_irqsave(&self->lock, flags);
diff -puN drivers/net/irda/vlsi_ir.c~irda-replace-__function__-with-__func__ drivers/net/irda/vlsi_ir.c
--- a/drivers/net/irda/vlsi_ir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/vlsi_ir.c
@@ -140,15 +140,15 @@ static void vlsi_ring_debug(struct vlsi_
 	unsigned i;
 
 	printk(KERN_DEBUG "%s - ring %p / size %u / mask 0x%04x / len %u / dir %d / hw %p\n",
-		__FUNCTION__, r, r->size, r->mask, r->len, r->dir, r->rd[0].hw);
-	printk(KERN_DEBUG "%s - head = %d / tail = %d\n", __FUNCTION__,
+		__func__, r, r->size, r->mask, r->len, r->dir, r->rd[0].hw);
+	printk(KERN_DEBUG "%s - head = %d / tail = %d\n", __func__,
 		atomic_read(&r->head) & r->mask, atomic_read(&r->tail) & r->mask);
 	for (i = 0; i < r->size; i++) {
 		rd = &r->rd[i];
-		printk(KERN_DEBUG "%s - ring descr %u: ", __FUNCTION__, i);
+		printk(KERN_DEBUG "%s - ring descr %u: ", __func__, i);
 		printk("skb=%p data=%p hw=%p\n", rd->skb, rd->buf, rd->hw);
 		printk(KERN_DEBUG "%s - hw: status=%02x count=%u addr=0x%08x\n",
-			__FUNCTION__, (unsigned) rd_get_status(rd),
+			__func__, (unsigned) rd_get_status(rd),
 			(unsigned) rd_get_count(rd), (unsigned) rd_get_addr(rd));
 	}
 }
@@ -435,7 +435,7 @@ static struct vlsi_ring *vlsi_alloc_ring
 		    ||  !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
 			if (rd->buf) {
 				IRDA_ERROR("%s: failed to create PCI-MAP for %p",
-					   __FUNCTION__, rd->buf);
+					   __func__, rd->buf);
 				kfree(rd->buf);
 				rd->buf = NULL;
 			}
@@ -489,7 +489,7 @@ static int vlsi_create_hwif(vlsi_irda_de
 	ringarea = pci_alloc_consistent(idev->pdev, HW_RING_AREA_SIZE, &idev->busaddr);
 	if (!ringarea) {
 		IRDA_ERROR("%s: insufficient memory for descriptor rings\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out;
 	}
 	memset(ringarea, 0, HW_RING_AREA_SIZE);
@@ -564,7 +564,7 @@ static int vlsi_process_rx(struct vlsi_r
 	crclen = (idev->mode==IFF_FIR) ? sizeof(u32) : sizeof(u16);
 	len -= crclen;		/* remove trailing CRC */
 	if (len <= 0) {
-		IRDA_DEBUG(0, "%s: strange frame (len=%d)\n", __FUNCTION__, len);
+		IRDA_DEBUG(0, "%s: strange frame (len=%d)\n", __func__, len);
 		ret |= VLSI_RX_DROP;
 		goto done;
 	}
@@ -579,14 +579,14 @@ static int vlsi_process_rx(struct vlsi_r
 		 */
 		le16_to_cpus(rd->buf+len);
 		if (irda_calc_crc16(INIT_FCS,rd->buf,len+crclen) != GOOD_FCS) {
-			IRDA_DEBUG(0, "%s: crc error\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s: crc error\n", __func__);
 			ret |= VLSI_RX_CRC;
 			goto done;
 		}
 	}
 
 	if (!rd->skb) {
-		IRDA_WARNING("%s: rx packet lost\n", __FUNCTION__);
+		IRDA_WARNING("%s: rx packet lost\n", __func__);
 		ret |= VLSI_RX_DROP;
 		goto done;
 	}
@@ -617,7 +617,7 @@ static void vlsi_fill_rx(struct vlsi_rin
 	for (rd = ring_last(r); rd != NULL; rd = ring_put(r)) {
 		if (rd_is_active(rd)) {
 			IRDA_WARNING("%s: driver bug: rx descr race with hw\n",
-				     __FUNCTION__);
+				     __func__);
 			vlsi_ring_debug(r);
 			break;
 		}
@@ -676,7 +676,7 @@ static void vlsi_rx_interrupt(struct net
 
 	if (ring_first(r) == NULL) {
 		/* we are in big trouble, if this should ever happen */
-		IRDA_ERROR("%s: rx ring exhausted!\n", __FUNCTION__);
+		IRDA_ERROR("%s: rx ring exhausted!\n", __func__);
 		vlsi_ring_debug(r);
 	}
 	else
@@ -697,7 +697,7 @@ static void vlsi_unarm_rx(vlsi_irda_dev_
 		if (rd_is_active(rd)) {
 			rd_set_status(rd, 0);
 			if (rd_get_count(rd)) {
-				IRDA_DEBUG(0, "%s - dropping rx packet\n", __FUNCTION__);
+				IRDA_DEBUG(0, "%s - dropping rx packet\n", __func__);
 				ret = -VLSI_RX_DROP;
 			}
 			rd_set_count(rd, 0);
@@ -772,7 +772,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 	int	fifocnt;
 
 	baudrate = idev->new_baud;
-	IRDA_DEBUG(2, "%s: %d -> %d\n", __FUNCTION__, idev->baud, idev->new_baud);
+	IRDA_DEBUG(2, "%s: %d -> %d\n", __func__, idev->baud, idev->new_baud);
 	if (baudrate == 4000000) {
 		mode = IFF_FIR;
 		config = IRCFG_FIR;
@@ -789,7 +789,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 		switch(baudrate) {
 			default:
 				IRDA_WARNING("%s: undefined baudrate %d - fallback to 9600!\n",
-					     __FUNCTION__, baudrate);
+					     __func__, baudrate);
 				baudrate = 9600;
 				/* fallthru */
 			case 2400:
@@ -806,7 +806,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 
 	fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 	if (fifocnt != 0) {
-		IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __FUNCTION__, fifocnt);
+		IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
 	}
 
 	outw(0, iobase+VLSI_PIO_IRENABLE);
@@ -830,14 +830,14 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 		config ^= IRENABLE_SIR_ON;
 
 	if (config != (IRENABLE_PHYANDCLOCK|IRENABLE_ENRXST)) {
-		IRDA_WARNING("%s: failed to set %s mode!\n", __FUNCTION__,
+		IRDA_WARNING("%s: failed to set %s mode!\n", __func__,
 			(mode==IFF_SIR)?"SIR":((mode==IFF_MIR)?"MIR":"FIR"));
 		ret = -1;
 	}
 	else {
 		if (inw(iobase+VLSI_PIO_PHYCTL) != nphyctl) {
 			IRDA_WARNING("%s: failed to apply baudrate %d\n",
-				     __FUNCTION__, baudrate);
+				     __func__, baudrate);
 			ret = -1;
 		}
 		else {
@@ -849,7 +849,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t
 	}
 
 	if (ret)
-		vlsi_reg_debug(iobase,__FUNCTION__);
+		vlsi_reg_debug(iobase,__func__);
 
 	return ret;
 }
@@ -982,7 +982,7 @@ static int vlsi_hard_start_xmit(struct s
 
 		if (len >= r->len-5)
 			 IRDA_WARNING("%s: possible buffer overflow with SIR wrapping!\n",
-				      __FUNCTION__);
+				      __func__);
 	}
 	else {
 		/* hw deals with MIR/FIR mode wrapping */
@@ -1027,7 +1027,7 @@ static int vlsi_hard_start_xmit(struct s
 
 		fifocnt = inw(ndev->base_addr+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
-			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __FUNCTION__, fifocnt);
+			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
 		}
 
 		config = inw(iobase+VLSI_PIO_IRCFG);
@@ -1040,7 +1040,7 @@ static int vlsi_hard_start_xmit(struct s
 
 	if (ring_put(r) == NULL) {
 		netif_stop_queue(ndev);
-		IRDA_DEBUG(3, "%s: tx ring full - queue stopped\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s: tx ring full - queue stopped\n", __func__);
 	}
 	spin_unlock_irqrestore(&idev->lock, flags);
 
@@ -1049,7 +1049,7 @@ static int vlsi_hard_start_xmit(struct s
 drop_unlock:
 	spin_unlock_irqrestore(&idev->lock, flags);
 drop:
-	IRDA_WARNING("%s: dropping packet - %s\n", __FUNCTION__, msg);
+	IRDA_WARNING("%s: dropping packet - %s\n", __func__, msg);
 	dev_kfree_skb_any(skb);
 	idev->stats.tx_errors++;
 	idev->stats.tx_dropped++;
@@ -1106,7 +1106,7 @@ static void vlsi_tx_interrupt(struct net
 		fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
 			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n",
-				__FUNCTION__, fifocnt);
+				__func__, fifocnt);
 		}
 		outw(config | IRCFG_ENTX, iobase+VLSI_PIO_IRCFG);
 	}
@@ -1115,7 +1115,7 @@ static void vlsi_tx_interrupt(struct net
 
 	if (netif_queue_stopped(ndev)  &&  !idev->new_baud) {
 		netif_wake_queue(ndev);
-		IRDA_DEBUG(3, "%s: queue awoken\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s: queue awoken\n", __func__);
 	}
 }
 
@@ -1138,7 +1138,7 @@ static void vlsi_unarm_tx(vlsi_irda_dev_
 				dev_kfree_skb_any(rd->skb);
 				rd->skb = NULL;
 			}
-			IRDA_DEBUG(0, "%s - dropping tx packet\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s - dropping tx packet\n", __func__);
 			ret = -VLSI_TX_DROP;
 		}
 		else
@@ -1188,7 +1188,7 @@ static int vlsi_start_clock(struct pci_d
 		if (count < 3) {
 			if (clksrc == 1) { /* explicitly asked for PLL hence bail out */
 				IRDA_ERROR("%s: no PLL or failed to lock!\n",
-					   __FUNCTION__);
+					   __func__);
 				clkctl = CLKCTL_CLKSTP;
 				pci_write_config_byte(pdev, VLSI_PCI_CLKCTL, clkctl);
 				return -1;
@@ -1197,7 +1197,7 @@ static int vlsi_start_clock(struct pci_d
 				clksrc = 3;	/* fallback to 40MHz XCLK (OB800) */
 
 			IRDA_DEBUG(0, "%s: PLL not locked, fallback to clksrc=%d\n",
-				__FUNCTION__, clksrc);
+				__func__, clksrc);
 		}
 		else
 			clksrc = 1;	/* got successful PLL lock */
@@ -1269,7 +1269,7 @@ static int vlsi_init_chip(struct pci_dev
 	/* start the clock and clean the registers */
 
 	if (vlsi_start_clock(pdev)) {
-		IRDA_ERROR("%s: no valid clock source\n", __FUNCTION__);
+		IRDA_ERROR("%s: no valid clock source\n", __func__);
 		return -1;
 	}
 	iobase = ndev->base_addr;
@@ -1386,7 +1386,7 @@ static void vlsi_tx_timeout(struct net_d
 	vlsi_irda_dev_t *idev = ndev->priv;
 
 
-	vlsi_reg_debug(ndev->base_addr, __FUNCTION__);
+	vlsi_reg_debug(ndev->base_addr, __func__);
 	vlsi_ring_debug(idev->tx_ring);
 
 	if (netif_running(ndev))
@@ -1401,7 +1401,7 @@ static void vlsi_tx_timeout(struct net_d
 
 	if (vlsi_start_hw(idev))
 		IRDA_ERROR("%s: failed to restart hw - %s(%s) unusable!\n",
-			   __FUNCTION__, pci_name(idev->pdev), ndev->name);
+			   __func__, pci_name(idev->pdev), ndev->name);
 	else
 		netif_start_queue(ndev);
 }
@@ -1446,7 +1446,7 @@ static int vlsi_ioctl(struct net_device 
 			break;
 		default:
 			IRDA_WARNING("%s: notsupp - cmd=%04x\n",
-				     __FUNCTION__, cmd);
+				     __func__, cmd);
 			ret = -EOPNOTSUPP;
 	}	
 	
@@ -1491,7 +1491,7 @@ static irqreturn_t vlsi_interrupt(int ir
 
 	if (boguscount <= 0)
 		IRDA_MESSAGE("%s: too much work in interrupt!\n",
-			     __FUNCTION__);
+			     __func__);
 	return IRQ_RETVAL(handled);
 }
 
@@ -1504,7 +1504,7 @@ static int vlsi_open(struct net_device *
 	char	hwname[32];
 
 	if (pci_request_regions(idev->pdev, drivername)) {
-		IRDA_WARNING("%s: io resource busy\n", __FUNCTION__);
+		IRDA_WARNING("%s: io resource busy\n", __func__);
 		goto errout;
 	}
 	ndev->base_addr = pci_resource_start(idev->pdev,0);
@@ -1519,7 +1519,7 @@ static int vlsi_open(struct net_device *
 	if (request_irq(ndev->irq, vlsi_interrupt, IRQF_SHARED,
 			drivername, ndev)) {
 		IRDA_WARNING("%s: couldn't get IRQ: %d\n",
-			     __FUNCTION__, ndev->irq);
+			     __func__, ndev->irq);
 		goto errout_io;
 	}
 
@@ -1540,7 +1540,7 @@ static int vlsi_open(struct net_device *
 
 	netif_start_queue(ndev);
 
-	IRDA_MESSAGE("%s: device %s operational\n", __FUNCTION__, ndev->name);
+	IRDA_MESSAGE("%s: device %s operational\n", __func__, ndev->name);
 
 	return 0;
 
@@ -1574,7 +1574,7 @@ static int vlsi_close(struct net_device 
 
 	pci_release_regions(idev->pdev);
 
-	IRDA_MESSAGE("%s: device %s stopped\n", __FUNCTION__, ndev->name);
+	IRDA_MESSAGE("%s: device %s stopped\n", __func__, ndev->name);
 
 	return 0;
 }
@@ -1593,7 +1593,7 @@ static int vlsi_irda_init(struct net_dev
 
 	if (pci_set_dma_mask(pdev,DMA_MASK_USED_BY_HW)
 	    || pci_set_dma_mask(pdev,DMA_MASK_MSTRPAGE)) {
-		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __FUNCTION__);
+		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __func__);
 		return -1;
 	}
 
@@ -1645,14 +1645,14 @@ vlsi_irda_probe(struct pci_dev *pdev, co
 
 	if ( !pci_resource_start(pdev,0)
 	     || !(pci_resource_flags(pdev,0) & IORESOURCE_IO) ) {
-		IRDA_ERROR("%s: bar 0 invalid", __FUNCTION__);
+		IRDA_ERROR("%s: bar 0 invalid", __func__);
 		goto out_disable;
 	}
 
 	ndev = alloc_irdadev(sizeof(*idev));
 	if (ndev==NULL) {
 		IRDA_ERROR("%s: Unable to allocate device memory.\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out_disable;
 	}
 
@@ -1667,7 +1667,7 @@ vlsi_irda_probe(struct pci_dev *pdev, co
 		goto out_freedev;
 
 	if (register_netdev(ndev) < 0) {
-		IRDA_ERROR("%s: register_netdev failed\n", __FUNCTION__);
+		IRDA_ERROR("%s: register_netdev failed\n", __func__);
 		goto out_freedev;
 	}
 
@@ -1678,7 +1678,7 @@ vlsi_irda_probe(struct pci_dev *pdev, co
 				       vlsi_proc_root, VLSI_PROC_FOPS, ndev);
 		if (!ent) {
 			IRDA_WARNING("%s: failed to create proc entry\n",
-				     __FUNCTION__);
+				     __func__);
 		} else {
 			ent->size = 0;
 		}
@@ -1745,7 +1745,7 @@ static int vlsi_irda_suspend(struct pci_
 
 	if (!ndev) {
 		IRDA_ERROR("%s - %s: no netdevice \n",
-			   __FUNCTION__, pci_name(pdev));
+			   __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = ndev->priv;	
@@ -1756,7 +1756,7 @@ static int vlsi_irda_suspend(struct pci_
 			pdev->current_state = state.event;
 		}
 		else
-			IRDA_ERROR("%s - %s: invalid suspend request %u -> %u\n", __FUNCTION__, pci_name(pdev), pdev->current_state, state.event);
+			IRDA_ERROR("%s - %s: invalid suspend request %u -> %u\n", __func__, pci_name(pdev), pdev->current_state, state.event);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
@@ -1784,7 +1784,7 @@ static int vlsi_irda_resume(struct pci_d
 
 	if (!ndev) {
 		IRDA_ERROR("%s - %s: no netdevice \n",
-			   __FUNCTION__, pci_name(pdev));
+			   __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = ndev->priv;	
@@ -1792,7 +1792,7 @@ static int vlsi_irda_resume(struct pci_d
 	if (pdev->current_state == 0) {
 		mutex_unlock(&idev->mtx);
 		IRDA_WARNING("%s - %s: already resumed\n",
-			     __FUNCTION__, pci_name(pdev));
+			     __func__, pci_name(pdev));
 		return 0;
 	}
 	
@@ -1811,7 +1811,7 @@ static int vlsi_irda_resume(struct pci_d
 		 * now we explicitly set pdev->current_state = 0 after enabling the
 		 * device and independently resume_ok should catch any garbage config.
 		 */
-		IRDA_WARNING("%s - hm, nothing to resume?\n", __FUNCTION__);
+		IRDA_WARNING("%s - hm, nothing to resume?\n", __func__);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
diff -puN drivers/net/irda/vlsi_ir.h~irda-replace-__function__-with-__func__ drivers/net/irda/vlsi_ir.h
--- a/drivers/net/irda/vlsi_ir.h~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/vlsi_ir.h
@@ -617,7 +617,7 @@ static inline void rd_set_addr_status(st
 	 */
 
 	if ((a & ~DMA_MASK_MSTRPAGE)>>24 != MSTRPAGE_VALUE) {
-		IRDA_ERROR("%s: pci busaddr inconsistency!\n", __FUNCTION__);
+		IRDA_ERROR("%s: pci busaddr inconsistency!\n", __func__);
 		dump_stack();
 		return;
 	}
diff -puN drivers/net/irda/w83977af_ir.c~irda-replace-__function__-with-__func__ drivers/net/irda/w83977af_ir.c
--- a/drivers/net/irda/w83977af_ir.c~irda-replace-__function__-with-__func__
+++ a/drivers/net/irda/w83977af_ir.c
@@ -114,7 +114,7 @@ static int __init w83977af_init(void)
 {
         int i;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	for (i=0; (io[i] < 2000) && (i < ARRAY_SIZE(dev_self)); i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
@@ -133,7 +133,7 @@ static void __exit w83977af_cleanup(void
 {
 	int i;
 
-        IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+        IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
@@ -154,12 +154,12 @@ int w83977af_open(int i, unsigned int io
         struct w83977af_ir *self;
 	int err;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	/* Lock the port that we need */
 	if (!request_region(iobase, CHIP_IO_EXTENT, driver_name)) {
 		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
-		      __FUNCTION__ , iobase);
+		      __func__ , iobase);
 		return -ENODEV;
 	}
 
@@ -241,7 +241,7 @@ int w83977af_open(int i, unsigned int io
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdevice() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdevice() failed!\n", __func__);
 		goto err_out3;
 	}
 	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
@@ -273,7 +273,7 @@ static int w83977af_close(struct w83977a
 {
 	int iobase;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
         iobase = self->io.fir_base;
 
@@ -294,7 +294,7 @@ static int w83977af_close(struct w83977a
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(0 , "%s(), Releasing Region %03x\n", 
-	      __FUNCTION__ , self->io.fir_base);
+	      __func__ , self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -316,7 +316,7 @@ int w83977af_probe( int iobase, int irq,
 	int i;
   	
  	for (i=0; i < 2; i++) {
- 		IRDA_DEBUG( 0, "%s()\n", __FUNCTION__ );
+ 		IRDA_DEBUG( 0, "%s()\n", __func__ );
 #ifdef CONFIG_USE_W977_PNP
  		/* Enter PnP configuration mode */
 		w977_efm_enter(efbase[i]);
@@ -403,7 +403,7 @@ int w83977af_probe( int iobase, int irq,
 			return 0;
 		} else {
 			/* Try next extented function register address */
-			IRDA_DEBUG( 0, "%s(), Wrong chip version", __FUNCTION__ );
+			IRDA_DEBUG( 0, "%s(), Wrong chip version", __func__ );
 		}
   	}   	
 	return -1;
@@ -439,19 +439,19 @@ void w83977af_change_speed(struct w83977
 	case 115200: outb(0x01, iobase+ABLL); break;
 	case 576000:
 		ir_mode = HCR_MIR_576;
-		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), handling baud of 576000\n", __func__ );
 		break;
 	case 1152000:
 		ir_mode = HCR_MIR_1152;
-		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), handling baud of 1152000\n", __func__ );
 		break;
 	case 4000000:
 		ir_mode = HCR_FIR;
-		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), handling baud of 4000000\n", __func__ );
 		break;
 	default:
 		ir_mode = HCR_FIR;
-		IRDA_DEBUG(0, "%s(), unknown baud rate of %d\n", __FUNCTION__ , speed);
+		IRDA_DEBUG(0, "%s(), unknown baud rate of %d\n", __func__ , speed);
 		break;
 	}
 
@@ -501,7 +501,7 @@ int w83977af_hard_xmit(struct sk_buff *s
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(4, "%s(%ld), skb->len=%d\n", __FUNCTION__ , jiffies, 
+	IRDA_DEBUG(4, "%s(%ld), skb->len=%d\n", __func__ , jiffies,
 		   (int) skb->len);
 	
 	/* Lock transmit buffer */
@@ -549,7 +549,7 @@ int w83977af_hard_xmit(struct sk_buff *s
 			outb(ICR_ETMRI, iobase+ICR);
 		} else {
 #endif
-			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __FUNCTION__ , jiffies, mtt);
+			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
 			if (mtt)
 				udelay(mtt);
 
@@ -591,7 +591,7 @@ static void w83977af_dma_write(struct w8
 	unsigned long flags;
 	__u8 hcr;
 #endif
-        IRDA_DEBUG(4, "%s(), len=%d\n", __FUNCTION__ , self->tx_buff.len);
+        IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
 
 	/* Save current set */
 	set = inb(iobase+SSR);
@@ -643,7 +643,7 @@ static int w83977af_pio_write(int iobase
 	int actual = 0;
 	__u8 set;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* Save current bank */
 	set = inb(iobase+SSR);
@@ -651,11 +651,11 @@ static int w83977af_pio_write(int iobase
 	switch_bank(iobase, SET0);
 	if (!(inb_p(iobase+USR) & USR_TSRE)) {
 		IRDA_DEBUG(4,
-			   "%s(), warning, FIFO not empty yet!\n", __FUNCTION__  );
+			   "%s(), warning, FIFO not empty yet!\n", __func__  );
 
 		fifo_size -= 17;
 		IRDA_DEBUG(4, "%s(), %d bytes left in tx fifo\n", 
-			   __FUNCTION__ , fifo_size);
+			   __func__ , fifo_size);
 	}
 
 	/* Fill FIFO with current frame */
@@ -665,7 +665,7 @@ static int w83977af_pio_write(int iobase
 	}
         
 	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __FUNCTION__ , fifo_size, actual, len);
+		   __func__ , fifo_size, actual, len);
 
 	/* Restore bank */
 	outb(set, iobase+SSR);
@@ -685,7 +685,7 @@ static void w83977af_dma_xmit_complete(s
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(4, "%s(%ld)\n", __FUNCTION__ , jiffies);
+	IRDA_DEBUG(4, "%s(%ld)\n", __func__ , jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -700,7 +700,7 @@ static void w83977af_dma_xmit_complete(s
 	
 	/* Check for underrrun! */
 	if (inb(iobase+AUDR) & AUDR_UNDR) {
-		IRDA_DEBUG(0, "%s(), Transmit underrun!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), Transmit underrun!\n", __func__ );
 		
 		self->stats.tx_errors++;
 		self->stats.tx_fifo_errors++;
@@ -741,7 +741,7 @@ int w83977af_dma_receive(struct w83977af
 #endif
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s\n", __func__ );
 
 	iobase= self->io.fir_base;
 
@@ -812,7 +812,7 @@ int w83977af_dma_receive_complete(struct
 	__u8 set;
 	__u8 status;
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s\n", __func__ );
 
 	st_fifo = &self->st_fifo;
 
@@ -892,7 +892,7 @@ int w83977af_dma_receive_complete(struct
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
 				printk(KERN_INFO
-				       "%s(), memory squeeze, dropping frame.\n", __FUNCTION__);
+				       "%s(), memory squeeze, dropping frame.\n", __func__);
 				/* Restore set register */
 				outb(set, iobase+SSR);
 
@@ -943,7 +943,7 @@ static void w83977af_pio_receive(struct 
 	__u8 byte = 0x00;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	
@@ -970,7 +970,7 @@ static __u8 w83977af_sir_interrupt(struc
 	__u8 set;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), isr=%#x\n", __FUNCTION__ , isr);
+	IRDA_DEBUG(4, "%s(), isr=%#x\n", __func__ , isr);
 	
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
@@ -1007,7 +1007,7 @@ static __u8 w83977af_sir_interrupt(struc
 		/* Check if we need to change the speed? */
 		if (self->new_speed) {
 			IRDA_DEBUG(2,
-				   "%s(), Changing speed!\n", __FUNCTION__ );
+				   "%s(), Changing speed!\n", __func__ );
 			w83977af_change_speed(self, self->new_speed);
 			self->new_speed = 0;
 		}
@@ -1189,7 +1189,7 @@ static int w83977af_net_open(struct net_
 	char hwname[32];
 	__u8 set;
 	
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct w83977af_ir *) dev->priv;
@@ -1252,7 +1252,7 @@ static int w83977af_net_close(struct net
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
@@ -1307,7 +1307,7 @@ static int w83977af_net_ioctl(struct net
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__ , dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
 	
 	spin_lock_irqsave(&self->lock, flags);
 
_
