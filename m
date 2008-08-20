From: akpm@linux-foundation.org
Subject: [patch 08/12] drivers/net: replace __FUNCTION__ with __func__
Date: Wed, 20 Aug 2008 16:52:04 -0700
Message-ID: <200808202352.m7KNq5u9006053@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	harvey.harrison@gmail.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:32971 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756167AbYHTXyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 19:54:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/3c505.c               |    4 
 drivers/net/arcnet/arcnet.c       |   18 ++--
 drivers/net/arcnet/com20020.c     |   16 +--
 drivers/net/ax88796.c             |   14 +--
 drivers/net/bfin_mac.c            |    8 -
 drivers/net/bonding/bonding.h     |    2 
 drivers/net/cxgb3/cxgb3_offload.c |    8 -
 drivers/net/e100.c                |    2 
 drivers/net/enc28j60.c            |   56 ++++++-------
 drivers/net/ibm_newemac/phy.c     |    2 
 drivers/net/ixgb/ixgb.h           |    2 
 drivers/net/ixgbe/ixgbe.h         |    2 
 drivers/net/meth.c                |    2 
 drivers/net/mipsnet.c             |    2 
 drivers/net/netx-eth.c            |    2 
 drivers/net/netxen/netxen_nic.h   |    2 
 drivers/net/pci-skeleton.c        |    4 
 drivers/net/r8169.c               |    2 
 drivers/net/s2io.c                |   40 ++++-----
 drivers/net/smc911x.c             |   66 +++++++--------
 drivers/net/smc91x.c              |   40 ++++-----
 drivers/net/tehuti.h              |    8 -
 drivers/net/tsi108_eth.c          |    6 -
 drivers/net/ucc_geth.c            |  116 ++++++++++++++--------------
 drivers/net/usb/mcs7830.c         |    2 
 drivers/net/usb/pegasus.c         |   24 ++---
 drivers/net/via-velocity.h        |    2 
 drivers/net/wan/cycx_drv.c        |    6 -
 drivers/net/wan/cycx_x25.c        |   12 +-
 drivers/net/wan/dscc4.c           |    2 
 drivers/net/wan/pc300_tty.c       |    2 
 31 files changed, 237 insertions(+), 237 deletions(-)

diff -puN drivers/net/3c505.c~drivers-net-replace-__function__-with-__func__ drivers/net/3c505.c
--- a/drivers/net/3c505.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/3c505.c
@@ -130,12 +130,12 @@ static const char filename[] = __FILE__;
 
 static const char timeout_msg[] = "*** timeout at %s:%s (line %d) ***\n";
 #define TIMEOUT_MSG(lineno) \
-	printk(timeout_msg, filename,__FUNCTION__,(lineno))
+	printk(timeout_msg, filename,__func__,(lineno))
 
 static const char invalid_pcb_msg[] =
 "*** invalid pcb length %d at %s:%s (line %d) ***\n";
 #define INVALID_PCB_MSG(len) \
-	printk(invalid_pcb_msg, (len),filename,__FUNCTION__,__LINE__)
+	printk(invalid_pcb_msg, (len),filename,__func__,__LINE__)
 
 static char search_msg[] __initdata = KERN_INFO "%s: Looking for 3c505 adapter at address %#x...";
 
diff -puN drivers/net/arcnet/arcnet.c~drivers-net-replace-__function__-with-__func__ drivers/net/arcnet/arcnet.c
--- a/drivers/net/arcnet/arcnet.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/arcnet/arcnet.c
@@ -442,24 +442,24 @@ static int arcnet_open(struct net_device
 		BUGMSG(D_NORMAL, "WARNING!  Station address FF may confuse "
 		       "DOS networking programs!\n");
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	if (ASTATUS() & RESETflag) {
-	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	  	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 		ACOMMAND(CFLAGScmd | RESETclear);
 	}
 
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	/* make sure we're ready to receive IRQ's. */
 	AINTMASK(0);
 	udelay(1);		/* give it time to set the mask before
 				 * we reset it again. (may not even be
 				 * necessary)
 				 */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->intmask = NORXflag | RECONflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	netif_start_queue(dev);
 
@@ -670,14 +670,14 @@ static int arcnet_send_packet(struct sk_
 		freeskb = 0;
 	}
 
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__FUNCTION__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
 	/* make sure we didn't ignore a TX IRQ while we were in here */
 	AINTMASK(0);
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->intmask |= TXFREEflag|EXCNAKflag;
 	AINTMASK(lp->intmask);
-	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__FUNCTION__,ASTATUS());
+	BUGMSG(D_DEBUG, "%s: %d: %s, status: %x\n",__FILE__,__LINE__,__func__,ASTATUS());
 
 	spin_unlock_irqrestore(&lp->lock, flags);
 	if (freeskb) {
@@ -798,7 +798,7 @@ irqreturn_t arcnet_interrupt(int irq, vo
                 diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
-			__FILE__,__LINE__,__FUNCTION__,status);
+			__FILE__,__LINE__,__func__,status);
 		didsomething = 0;
 
 		/*
diff -puN drivers/net/arcnet/com20020.c~drivers-net-replace-__function__-with-__func__ drivers/net/arcnet/com20020.c
--- a/drivers/net/arcnet/com20020.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/arcnet/com20020.c
@@ -238,15 +238,15 @@ static int com20020_reset(struct net_dev
 	u_char inbyte;
 
 	BUGMSG(D_DEBUG, "%s: %d: %s: dev: %p, lp: %p, dev->name: %s\n",
-		__FILE__,__LINE__,__FUNCTION__,dev,lp,dev->name);
+		__FILE__,__LINE__,__func__,dev,lp,dev->name);
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n",
 	       dev->name, ASTATUS());
 
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	lp->config = TXENcfg | (lp->timeout << 3) | (lp->backplane << 2);
 	/* power-up defaults */
 	SETCONF;
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	if (really_reset) {
 		/* reset the card */
@@ -254,22 +254,22 @@ static int com20020_reset(struct net_dev
 		mdelay(RESETtime * 2);	/* COM20020 seems to be slower sometimes */
 	}
 	/* clear flags & end reset */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	ACOMMAND(CFLAGScmd | RESETclear | CONFIGclear);
 
 	/* verify that the ARCnet signature byte is present */
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	com20020_copy_from_card(dev, 0, 0, &inbyte, 1);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 	if (inbyte != TESTvalue) {
-		BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+		BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 		BUGMSG(D_NORMAL, "reset failed: TESTvalue not present.\n");
 		return 1;
 	}
 	/* enable extended (512-byte) packets */
 	ACOMMAND(CONFIGcmd | EXTconf);
-	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__FUNCTION__);
+	BUGMSG(D_DEBUG, "%s: %d: %s\n",__FILE__,__LINE__,__func__);
 
 	/* done!  return success. */
 	return 0;
diff -puN drivers/net/ax88796.c~drivers-net-replace-__function__-with-__func__ drivers/net/ax88796.c
--- a/drivers/net/ax88796.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/ax88796.c
@@ -153,7 +153,7 @@ static void ax_reset_8390(struct net_dev
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2*HZ/100) {
 			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
-			       __FUNCTION__, dev->name);
+			       __func__, dev->name);
 			break;
 		}
 	}
@@ -173,7 +173,7 @@ static void ax_get_8390_hdr(struct net_d
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -215,7 +215,7 @@ static void ax_block_input(struct net_de
 		dev_err(&ax->dev->dev,
 			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -260,7 +260,7 @@ static void ax_block_output(struct net_d
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 		       ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -396,7 +396,7 @@ ax_phy_issueaddr(struct net_device *dev,
 {
 	if (phy_debug)
 		pr_debug("%s: dev %p, %04x, %04x, %d\n",
-			__FUNCTION__, dev, phy_addr, reg, opc);
+			__func__, dev, phy_addr, reg, opc);
 
 	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
 	ax_mii_ei_outbits(dev, 1, 2);		/* frame-start */
@@ -422,7 +422,7 @@ ax_phy_read(struct net_device *dev, int 
       	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	if (phy_debug)
-		pr_debug("%s: %04x.%04x => read %04x\n", __FUNCTION__,
+		pr_debug("%s: %04x.%04x => read %04x\n", __func__,
 			 phy_addr, reg, result);
 
 	return result;
@@ -436,7 +436,7 @@ ax_phy_write(struct net_device *dev, int
 	unsigned long flags;
 
 	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
-		__FUNCTION__, dev, phy_addr, reg, value);
+		__func__, dev, phy_addr, reg, value);
 
       	spin_lock_irqsave(&ei->page_lock, flags);
 
diff -puN drivers/net/bfin_mac.c~drivers-net-replace-__function__-with-__func__ drivers/net/bfin_mac.c
--- a/drivers/net/bfin_mac.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/bfin_mac.c
@@ -811,7 +811,7 @@ static void bfin_mac_enable(void)
 {
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __FUNCTION__);
+	pr_debug("%s: %s\n", DRV_NAME, __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -847,7 +847,7 @@ static void bfin_mac_enable(void)
 /* Our watchdog timed out. Called by the networking layer */
 static void bfin_mac_timeout(struct net_device *dev)
 {
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	bfin_mac_disable();
 
@@ -949,7 +949,7 @@ static int bfin_mac_open(struct net_devi
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
 	int retval;
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -989,7 +989,7 @@ static int bfin_mac_open(struct net_devi
 static int bfin_mac_close(struct net_device *dev)
 {
 	struct bfin_mac_local *lp = netdev_priv(dev);
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
diff -puN drivers/net/bonding/bonding.h~drivers-net-replace-__function__-with-__func__ drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/bonding/bonding.h
@@ -32,7 +32,7 @@
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
-	       DRV_NAME ": %s() %d: " fmt, __FUNCTION__, __LINE__ , ## args )
+	       DRV_NAME ": %s() %d: " fmt, __func__, __LINE__ , ## args )
 #else
 #define dprintk(fmt, args...)
 #endif /* BONDING_DEBUG */
diff -puN drivers/net/cxgb3/cxgb3_offload.c~drivers-net-replace-__function__-with-__func__ drivers/net/cxgb3/cxgb3_offload.c
--- a/drivers/net/cxgb3/cxgb3_offload.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/cxgb3/cxgb3_offload.c
@@ -1018,7 +1018,7 @@ static void set_l2t_ix(struct t3cdev *td
 
 	skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_ERR "%s: cannot allocate skb!\n", __FUNCTION__);
+		printk(KERN_ERR "%s: cannot allocate skb!\n", __func__);
 		return;
 	}
 	skb->priority = CPL_PRIORITY_CONTROL;
@@ -1049,14 +1049,14 @@ void cxgb_redirect(struct dst_entry *old
 		return;
 	if (!is_offloading(newdev)) {
 		printk(KERN_WARNING "%s: Redirect to non-offload "
-		       "device ignored.\n", __FUNCTION__);
+		       "device ignored.\n", __func__);
 		return;
 	}
 	tdev = dev2t3cdev(olddev);
 	BUG_ON(!tdev);
 	if (tdev != dev2t3cdev(newdev)) {
 		printk(KERN_WARNING "%s: Redirect to different "
-		       "offload device ignored.\n", __FUNCTION__);
+		       "offload device ignored.\n", __func__);
 		return;
 	}
 
@@ -1064,7 +1064,7 @@ void cxgb_redirect(struct dst_entry *old
 	e = t3_l2t_get(tdev, new->neighbour, newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
-		       __FUNCTION__);
+		       __func__);
 		return;
 	}
 
diff -puN drivers/net/e100.c~drivers-net-replace-__function__-with-__func__ drivers/net/e100.c
--- a/drivers/net/e100.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/e100.c
@@ -195,7 +195,7 @@ MODULE_PARM_DESC(use_io, "Force use of i
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
diff -puN drivers/net/enc28j60.c~drivers-net-replace-__function__-with-__func__ drivers/net/enc28j60.c
--- a/drivers/net/enc28j60.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/enc28j60.c
@@ -110,7 +110,7 @@ spi_read_buf(struct enc28j60_net *priv, 
 	}
 	if (ret && netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 
 	return ret;
 }
@@ -131,7 +131,7 @@ static int spi_write_buf(struct enc28j60
 		ret = spi_write(priv->spi, priv->spi_transfer_buf, len + 1);
 		if (ret && netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-				__FUNCTION__, ret);
+				__func__, ret);
 	}
 	return ret;
 }
@@ -156,7 +156,7 @@ static u8 spi_read_op(struct enc28j60_ne
 	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
 	if (ret)
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 	else
 		val = rx_buf[slen - 1];
 
@@ -176,14 +176,14 @@ static int spi_write_op(struct enc28j60_
 	ret = spi_write(priv->spi, priv->spi_transfer_buf, 2);
 	if (ret && netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 	return ret;
 }
 
 static void enc28j60_soft_reset(struct enc28j60_net *priv)
 {
 	if (netif_msg_hw(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	spi_write_op(priv, ENC28J60_SOFT_RESET, 0, ENC28J60_SOFT_RESET);
 	/* Errata workaround #1, CLKRDY check is unreliable,
@@ -357,7 +357,7 @@ static void enc28j60_mem_read(struct enc
 		reg = nolock_regw_read(priv, ERDPTL);
 		if (reg != addr)
 			printk(KERN_DEBUG DRV_NAME ": %s() error writing ERDPT "
-				"(0x%04x - 0x%04x)\n", __FUNCTION__, reg, addr);
+				"(0x%04x - 0x%04x)\n", __func__, reg, addr);
 	}
 #endif
 	spi_read_buf(priv, len, data);
@@ -380,7 +380,7 @@ enc28j60_packet_write(struct enc28j60_ne
 		if (reg != TXSTART_INIT)
 			printk(KERN_DEBUG DRV_NAME
 				": %s() ERWPT:0x%04x != 0x%04x\n",
-				__FUNCTION__, reg, TXSTART_INIT);
+				__func__, reg, TXSTART_INIT);
 	}
 #endif
 	/* Set the TXND pointer to correspond to the packet size given */
@@ -390,13 +390,13 @@ enc28j60_packet_write(struct enc28j60_ne
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME
 			": %s() after control byte ERWPT:0x%04x\n",
-			__FUNCTION__, nolock_regw_read(priv, EWRPTL));
+			__func__, nolock_regw_read(priv, EWRPTL));
 	/* copy the packet into the transmit buffer */
 	spi_write_buf(priv, len, data);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME
 			 ": %s() after write packet ERWPT:0x%04x, len=%d\n",
-			 __FUNCTION__, nolock_regw_read(priv, EWRPTL), len);
+			 __func__, nolock_regw_read(priv, EWRPTL), len);
 	mutex_unlock(&priv->lock);
 }
 
@@ -495,7 +495,7 @@ static int enc28j60_set_hw_macaddr(struc
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME
 				": %s() Hardware must be disabled to set "
-				"Mac address\n", __FUNCTION__);
+				"Mac address\n", __func__);
 		ret = -EBUSY;
 	}
 	mutex_unlock(&priv->lock);
@@ -575,7 +575,7 @@ static void nolock_rxfifo_init(struct en
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) RXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set receive buffer start + end */
@@ -591,7 +591,7 @@ static void nolock_txfifo_init(struct en
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) TXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set transmit buffer start + end */
@@ -630,7 +630,7 @@ static int enc28j60_hw_init(struct enc28
 	u8 reg;
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __FUNCTION__,
+		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __func__,
 			priv->full_duplex ? "FullDuplex" : "HalfDuplex");
 
 	mutex_lock(&priv->lock);
@@ -661,7 +661,7 @@ static int enc28j60_hw_init(struct enc28
 	if (reg == 0x00 || reg == 0xff) {
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() Invalid RevId %d\n",
-				__FUNCTION__, reg);
+				__func__, reg);
 		return 0;
 	}
 
@@ -724,7 +724,7 @@ static void enc28j60_hw_enable(struct en
 	/* enable interrupts */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
-			__FUNCTION__);
+			__func__);
 
 	enc28j60_phy_write(priv, PHIE, PHIE_PGEIE | PHIE_PLNKIE);
 
@@ -888,7 +888,7 @@ static void enc28j60_hw_rx(struct net_de
 		if (netif_msg_rx_err(priv))
 			dev_err(&ndev->dev,
 				"%s() Invalid packet address!! 0x%04x\n",
-				__FUNCTION__, priv->next_pk_ptr);
+				__func__, priv->next_pk_ptr);
 		/* packet address corrupted: reset RX logic */
 		mutex_lock(&priv->lock);
 		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
@@ -917,7 +917,7 @@ static void enc28j60_hw_rx(struct net_de
 	rxstat |= rsv[4];
 
 	if (netif_msg_rx_status(priv))
-		enc28j60_dump_rsv(priv, __FUNCTION__, next_packet, len, rxstat);
+		enc28j60_dump_rsv(priv, __func__, next_packet, len, rxstat);
 
 	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
 		if (netif_msg_rx_err(priv))
@@ -941,7 +941,7 @@ static void enc28j60_hw_rx(struct net_de
 			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
 					len, skb_put(skb, len));
 			if (netif_msg_pktdata(priv))
-				dump_packet(__FUNCTION__, skb->len, skb->data);
+				dump_packet(__func__, skb->len, skb->data);
 			skb->protocol = eth_type_trans(skb, ndev);
 			/* update statistics */
 			ndev->stats.rx_packets++;
@@ -958,7 +958,7 @@ static void enc28j60_hw_rx(struct net_de
 	erxrdpt = erxrdpt_workaround(next_packet, RXSTART_INIT, RXEND_INIT);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT:0x%04x\n",
-			__FUNCTION__, erxrdpt);
+			__func__, erxrdpt);
 
 	mutex_lock(&priv->lock);
 	nolock_regw_write(priv, ERXRDPTL, erxrdpt);
@@ -968,7 +968,7 @@ static void enc28j60_hw_rx(struct net_de
 		reg = nolock_regw_read(priv, ERXRDPTL);
 		if (reg != erxrdpt)
 			printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT verify "
-				"error (0x%04x - 0x%04x)\n", __FUNCTION__,
+				"error (0x%04x - 0x%04x)\n", __func__,
 				reg, erxrdpt);
 	}
 #endif
@@ -1006,7 +1006,7 @@ static int enc28j60_get_free_rxfifo(stru
 	mutex_unlock(&priv->lock);
 	if (netif_msg_rx_status(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() free_space = %d\n",
-			__FUNCTION__, free_space);
+			__func__, free_space);
 	return free_space;
 }
 
@@ -1022,7 +1022,7 @@ static void enc28j60_check_link_status(s
 	reg = enc28j60_phy_read(priv, PHSTAT2);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() PHSTAT1: %04x, "
-			"PHSTAT2: %04x\n", __FUNCTION__,
+			"PHSTAT2: %04x\n", __func__,
 			enc28j60_phy_read(priv, PHSTAT1), reg);
 	duplex = reg & PHSTAT2_DPXSTAT;
 
@@ -1095,7 +1095,7 @@ static void enc28j60_irq_work_handler(st
 	int intflags, loop;
 
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 	/* disable further interrupts */
 	locked_reg_bfclr(priv, EIE, EIE_INTIE);
 
@@ -1198,7 +1198,7 @@ static void enc28j60_irq_work_handler(st
 	/* re-enable interrupts */
 	locked_reg_bfset(priv, EIE, EIE_INTIE);
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __func__);
 }
 
 /*
@@ -1213,7 +1213,7 @@ static void enc28j60_hw_tx(struct enc28j
 			": Tx Packet Len:%d\n", priv->tx_skb->len);
 
 	if (netif_msg_pktdata(priv))
-		dump_packet(__FUNCTION__,
+		dump_packet(__func__,
 			    priv->tx_skb->len, priv->tx_skb->data);
 	enc28j60_packet_write(priv, priv->tx_skb->len, priv->tx_skb->data);
 
@@ -1254,7 +1254,7 @@ static int enc28j60_send_packet(struct s
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_tx_queued(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	/* If some error occurs while trying to transmit this
 	 * packet, you should return '1' from this function.
@@ -1325,7 +1325,7 @@ static int enc28j60_net_open(struct net_
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		if (netif_msg_ifup(priv)) {
@@ -1363,7 +1363,7 @@ static int enc28j60_net_close(struct net
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	enc28j60_hw_disable(priv);
 	enc28j60_lowpower(priv, true);
diff -puN drivers/net/ibm_newemac/phy.c~drivers-net-replace-__function__-with-__func__ drivers/net/ibm_newemac/phy.c
--- a/drivers/net/ibm_newemac/phy.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/ibm_newemac/phy.c
@@ -321,7 +321,7 @@ static struct mii_phy_def bcm5248_phy_de
 
 static int m88e1111_init(struct mii_phy *phy)
 {
-	pr_debug("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
+	pr_debug("%s: Marvell 88E1111 Ethernet\n", __func__);
 	phy_write(phy, 0x14, 0x0ce3);
 	phy_write(phy, 0x18, 0x4101);
 	phy_write(phy, 0x09, 0x0e00);
diff -puN drivers/net/ixgb/ixgb.h~drivers-net-replace-__function__-with-__func__ drivers/net/ixgb/ixgb.h
--- a/drivers/net/ixgb/ixgb.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/ixgb/ixgb.h
@@ -85,7 +85,7 @@ struct ixgb_adapter;
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 
 /* TX/RX descriptor defines */
diff -puN drivers/net/ixgbe/ixgbe.h~drivers-net-replace-__function__-with-__func__ drivers/net/ixgbe/ixgbe.h
--- a/drivers/net/ixgbe/ixgbe.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/ixgbe/ixgbe.h
@@ -47,7 +47,7 @@
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args)))
+		__func__ , ## args)))
 
 /* TX/RX descriptor defines */
 #define IXGBE_DEFAULT_TXD		   1024
diff -puN drivers/net/meth.c~drivers-net-replace-__function__-with-__func__ drivers/net/meth.c
--- a/drivers/net/meth.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/meth.c
@@ -41,7 +41,7 @@
 #endif
 
 #if MFE_DEBUG>=1
-#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __FUNCTION__ , ## args)
+#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __func__ , ## args)
 #define MFE_RX_DEBUG 2
 #else
 #define DPRINTK(str,args...)
diff -puN drivers/net/mipsnet.c~drivers-net-replace-__function__-with-__func__ drivers/net/mipsnet.c
--- a/drivers/net/mipsnet.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/mipsnet.c
@@ -203,7 +203,7 @@ static irqreturn_t mipsnet_interrupt(int
 
 out_badirq:
 	printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
-	       dev->name, __FUNCTION__, irq);
+	       dev->name, __func__, irq);
 	return ret;
 }
 
diff -puN drivers/net/netx-eth.c~drivers-net-replace-__function__-with-__func__ drivers/net/netx-eth.c
--- a/drivers/net/netx-eth.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/netx-eth.c
@@ -189,7 +189,7 @@ netx_eth_interrupt(int irq, void *dev_id
 
 		if ((status & ISR_CON_HI) || (status & ISR_IND_HI))
 			printk("%s: unexpected status: 0x%08x\n",
-			    __FUNCTION__, status);
+			    __func__, status);
 
 		fill_level =
 		    readl(NETX_PFIFO_FILL_LEVEL(IND_FIFO_PORT_LO(priv->id)));
diff -puN drivers/net/netxen/netxen_nic.h~drivers-net-replace-__function__-with-__func__ drivers/net/netxen/netxen_nic.h
--- a/drivers/net/netxen/netxen_nic.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/netxen/netxen_nic.h
@@ -743,7 +743,7 @@ extern char netxen_nic_driver_name[];
 	} while (0)
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
+	printk(KERN_##klevel PFX "%s: %s: " fmt, __func__,\
 		(adapter != NULL && adapter->netdev != NULL) ? \
 		adapter->netdev->name : NULL, \
 		## args); } while(0)
diff -puN drivers/net/pci-skeleton.c~drivers-net-replace-__function__-with-__func__ drivers/net/pci-skeleton.c
--- a/drivers/net/pci-skeleton.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/pci-skeleton.c
@@ -119,7 +119,7 @@ KERN_INFO "  Support available from http
 
 #ifdef NETDRV_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -130,7 +130,7 @@ KERN_INFO "  Support available from http
 #  define assert(expr) \
         if(!(expr)) {					\
         printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		\
+        #expr,__FILE__,__func__,__LINE__);		\
         }
 #endif
 
diff -puN drivers/net/r8169.c~drivers-net-replace-__function__-with-__func__ drivers/net/r8169.c
--- a/drivers/net/r8169.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/r8169.c
@@ -36,7 +36,7 @@
 #define assert(expr) \
 	if (!(expr)) {					\
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-		#expr,__FILE__,__FUNCTION__,__LINE__);		\
+		#expr,__FILE__,__func__,__LINE__);		\
 	}
 #define dprintk(fmt, args...) \
 	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
diff -puN drivers/net/s2io.c~drivers-net-replace-__function__-with-__func__ drivers/net/s2io.c
--- a/drivers/net/s2io.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/s2io.c
@@ -3136,7 +3136,7 @@ static void tx_intr_handler(struct fifo_
 		if (skb == NULL) {
 			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 			DBG_PRINT(ERR_DBG, "%s: Null skb ",
-			__FUNCTION__);
+			__func__);
 			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
 			return;
 		}
@@ -3496,7 +3496,7 @@ static void s2io_reset(struct s2io_nic *
 	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
 
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
-			__FUNCTION__, sp->dev->name);
+			__func__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
@@ -3518,7 +3518,7 @@ static void s2io_reset(struct s2io_nic *
 	}
 
 	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID) {
-		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __FUNCTION__);
+		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __func__);
 	}
 
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, pci_cmd);
@@ -3768,7 +3768,7 @@ static void restore_xmsi_data(struct s2i
 		val64 = (s2BIT(7) | s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 	}
@@ -3789,7 +3789,7 @@ static void store_xmsi_data(struct s2io_
 		val64 = (s2BIT(15) | vBIT(msix_index, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, msix_index)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 		addr = readq(&bar0->xmsi_address);
@@ -3812,7 +3812,7 @@ static int s2io_enable_msi_x(struct s2io
 			       GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -3826,7 +3826,7 @@ static int s2io_enable_msi_x(struct s2io
 				   GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
@@ -6746,7 +6746,7 @@ static int s2io_change_mtu(struct net_de
 		ret = s2io_card_up(sp);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
-				  __FUNCTION__);
+				  __func__);
 			return ret;
 		}
 		s2io_wake_all_tx_queue(sp);
@@ -7530,7 +7530,7 @@ static int rx_osm_handler(struct ring_in
 					default:
 						DBG_PRINT(ERR_DBG,
 							"%s: Samadhana!!\n",
-							 __FUNCTION__);
+							 __func__);
 						BUG();
 				}
 			}
@@ -7781,7 +7781,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 		return -ENOMEM;
 	}
 	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
-		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __FUNCTION__, ret);
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __func__, ret);
 		pci_disable_device(pdev);
 		return -ENODEV;
 	}
@@ -7998,7 +7998,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_verify_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, "%s: ", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "%s: ", __func__);
 			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
 			ret = -EBADSLT;
 			goto set_swap_failed;
@@ -8299,7 +8299,7 @@ static int check_L2_lro_capable(u8 *buff
 
 	if (!(rxdp->Control_1 & RXD_FRAME_PROTO_TCP)) {
 		DBG_PRINT(INIT_DBG,"%s: Non-TCP frames not supported for LRO\n",
-			  __FUNCTION__);
+			  __func__);
 		return -1;
 	}
 
@@ -8330,7 +8330,7 @@ static int check_L2_lro_capable(u8 *buff
 static int check_for_socket_match(struct lro *lro, struct iphdr *ip,
 				  struct tcphdr *tcp)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	if ((lro->iph->saddr != ip->saddr) || (lro->iph->daddr != ip->daddr) ||
 	   (lro->tcph->source != tcp->source) || (lro->tcph->dest != tcp->dest))
 		return -1;
@@ -8345,7 +8345,7 @@ static inline int get_l4_pyld_length(str
 static void initiate_new_session(struct lro *lro, u8 *l2h,
 	struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len, u16 vlan_tag)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->l2h = l2h;
 	lro->iph = ip;
 	lro->tcph = tcp;
@@ -8375,7 +8375,7 @@ static void update_L3L4_header(struct s2
 	struct tcphdr *tcp = lro->tcph;
 	__sum16 nchk;
 	struct stat_block *statinfo = sp->mac_control.stats_info;
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	/* Update L3 header */
 	ip->tot_len = htons(lro->total_len);
@@ -8403,7 +8403,7 @@ static void update_L3L4_header(struct s2
 static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
 		struct tcphdr *tcp, u32 l4_pyld)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->total_len += l4_pyld;
 	lro->frags_len += l4_pyld;
 	lro->tcp_next_seq += l4_pyld;
@@ -8427,7 +8427,7 @@ static int verify_l3_l4_lro_capable(stru
 {
 	u8 *ptr;
 
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	if (!tcp_pyld_len) {
 		/* Runt frame or a pure ack */
@@ -8509,7 +8509,7 @@ s2io_club_tcp_session(struct ring_info *
 
 			if ((*lro)->tcp_next_seq != ntohl(tcph->seq)) {
 				DBG_PRINT(INFO_DBG, "%s:Out of order. expected "
-					  "0x%x, actual 0x%x\n", __FUNCTION__,
+					  "0x%x, actual 0x%x\n", __func__,
 					  (*lro)->tcp_next_seq,
 					  ntohl(tcph->seq));
 
@@ -8549,7 +8549,7 @@ s2io_club_tcp_session(struct ring_info *
 
 	if (ret == 0) { /* sessions exceeded */
 		DBG_PRINT(INFO_DBG,"%s:All LRO sessions already in use\n",
-			  __FUNCTION__);
+			  __func__);
 		*lro = NULL;
 		return ret;
 	}
@@ -8571,7 +8571,7 @@ s2io_club_tcp_session(struct ring_info *
 			break;
 		default:
 			DBG_PRINT(ERR_DBG,"%s:Dont know, can't say!!\n",
-				__FUNCTION__);
+				__func__);
 			break;
 	}
 
diff -puN drivers/net/smc911x.c~drivers-net-replace-__function__-with-__func__ drivers/net/smc911x.c
--- a/drivers/net/smc911x.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/smc911x.c
@@ -183,7 +183,7 @@ static void smc911x_reset(struct net_dev
 	unsigned int reg, timeout=0, resets=1;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*	 Take out of PM setting first */
 	if ((SMC_GET_PMT_CTRL(lp) & PMT_CTRL_READY_) == 0) {
@@ -272,7 +272,7 @@ static void smc911x_enable(struct net_de
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	SMC_SET_MAC_ADDR(lp, dev->dev_addr);
 
@@ -329,7 +329,7 @@ static void smc911x_shutdown(struct net_
 	unsigned cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __func__);
 
 	/* Disable IRQ's */
 	SMC_SET_INT_EN(lp, 0);
@@ -348,7 +348,7 @@ static inline void smc911x_drop_pkt(stru
 	struct smc911x_local *lp = netdev_priv(dev);
 	unsigned int fifo_count, timeout, reg;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __func__);
 	fifo_count = SMC_GET_RX_FIFO_INF(lp) & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
@@ -382,7 +382,7 @@ static inline void	 smc911x_rcv(struct n
 	unsigned char *data;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 	status = SMC_GET_RX_STS_FIFO(lp);
 	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
@@ -460,7 +460,7 @@ static void smc911x_hardware_send_pkt(st
 	unsigned char *buf;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __func__);
 	BUG_ON(lp->pending_tx_skb == NULL);
 
 	skb = lp->pending_tx_skb;
@@ -524,7 +524,7 @@ static int smc911x_hard_start_xmit(struc
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -596,7 +596,7 @@ static void smc911x_tx(struct net_device
 	unsigned int tx_status;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	/* Collect the TX status */
 	while (((SMC_GET_TX_FIFO_INF(lp) & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
@@ -647,7 +647,7 @@ static int smc911x_phy_read(struct net_d
 	SMC_GET_MII(lp, phyreg, phyaddr, phydata);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 	return phydata;
 }
 
@@ -661,7 +661,7 @@ static void smc911x_phy_write(struct net
 	struct smc911x_local *lp = netdev_priv(dev);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SET_MII(lp, phyreg, phyaddr, phydata);
 }
@@ -676,7 +676,7 @@ static void smc911x_phy_detect(struct ne
 	int phyaddr;
 	unsigned int cfg, id1, id2;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -746,7 +746,7 @@ static int smc911x_phy_fixed(struct net_
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	SMC_GET_PHY_BMCR(lp, phyaddr, bmcr);
@@ -793,7 +793,7 @@ static int smc911x_phy_reset(struct net_
 	unsigned long flags;
 	unsigned int reg;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	reg = SMC_GET_PMT_CTRL(lp);
@@ -852,7 +852,7 @@ static void smc911x_phy_check_media(stru
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
@@ -892,7 +892,7 @@ static void smc911x_phy_configure(struct
 	int status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	/*
 	 * We should not be called if phy_type is zero.
@@ -985,7 +985,7 @@ static void smc911x_phy_interrupt(struct
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1013,7 +1013,7 @@ static irqreturn_t smc911x_interrupt(int
 	unsigned int rx_overrun=0, cr, pkts;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1188,7 +1188,7 @@ smc911x_tx_dma_irq(int dma, void *data)
 	struct sk_buff *skb = lp->current_tx_skb;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: TX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
@@ -1224,7 +1224,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	unsigned long flags;
 	unsigned int pkts;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, "%s: RX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
 	SMC_DMA_ACK_IRQ(dev, dma);
@@ -1272,7 +1272,7 @@ static void smc911x_timeout(struct net_d
 	int status, mask;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	status = SMC_GET_INT(lp);
@@ -1310,7 +1310,7 @@ static void smc911x_set_multicast_list(s
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(lp, mcr);
@@ -1412,7 +1412,7 @@ smc911x_open(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1420,7 +1420,7 @@ smc911x_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1449,7 +1449,7 @@ static int smc911x_close(struct net_devi
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1483,7 +1483,7 @@ smc911x_ethtool_getsettings(struct net_d
 	int ret, status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
 
@@ -1621,7 +1621,7 @@ static int smc911x_ethtool_wait_eeprom_r
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
 			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
-				dev->name, __FUNCTION__);
+				dev->name, __func__);
 			return -EFAULT;
 		}
 		mdelay(1);
@@ -1629,7 +1629,7 @@ static int smc911x_ethtool_wait_eeprom_r
 	}
 	if (timeout == 0) {
 		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
-			dev->name, __FUNCTION__);
+			dev->name, __func__);
 		return -ETIMEDOUT;
 	}
 	return 0;
@@ -1742,7 +1742,7 @@ static int __init smc911x_findirq(struct
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 
 	cookie = probe_irq_on();
 
@@ -1808,7 +1808,7 @@ static int __init smc911x_probe(struct n
 	const char *version_string;
 	unsigned long irq_flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* First, see if the endian word is recognized */
 	val = SMC_GET_BYTE_TEST(lp);
@@ -2058,7 +2058,7 @@ static int smc911x_drv_probe(struct plat
 	unsigned int *addr;
 	int ret;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __func__);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
 		ret = -ENODEV;
@@ -2129,7 +2129,7 @@ static int smc911x_drv_remove(struct pla
 	struct smc911x_local *lp = netdev_priv(ndev);
 	struct resource *res;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
@@ -2159,7 +2159,7 @@ static int smc911x_drv_suspend(struct pl
 	struct net_device *ndev = platform_get_drvdata(dev);
 	struct smc911x_local *lp = netdev_priv(ndev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
@@ -2177,7 +2177,7 @@ static int smc911x_drv_resume(struct pla
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		struct smc911x_local *lp = netdev_priv(ndev);
 
diff -puN drivers/net/smc91x.c~drivers-net-replace-__function__-with-__func__ drivers/net/smc91x.c
--- a/drivers/net/smc91x.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/smc91x.c
@@ -270,7 +270,7 @@ static void smc_reset(struct net_device 
 	unsigned int ctl, cfg;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* Disable all interrupts, block TX tasklet */
 	spin_lock_irq(&lp->lock);
@@ -363,7 +363,7 @@ static void smc_enable(struct net_device
 	void __iomem *ioaddr = lp->base;
 	int mask;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* see the header file for options in TCR/RCR DEFAULT */
 	SMC_SELECT_BANK(lp, 0);
@@ -397,7 +397,7 @@ static void smc_shutdown(struct net_devi
 	void __iomem *ioaddr = lp->base;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* no more interrupts for me */
 	spin_lock_irq(&lp->lock);
@@ -430,7 +430,7 @@ static inline void  smc_rcv(struct net_d
 	void __iomem *ioaddr = lp->base;
 	unsigned int packet_number, status, packet_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	packet_number = SMC_GET_RXFIFO(lp);
 	if (unlikely(packet_number & RXFIFO_REMPTY)) {
@@ -577,7 +577,7 @@ static void smc_hardware_send_pkt(unsign
 	unsigned int packet_no, len;
 	unsigned char *buf;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	if (!smc_special_trylock(&lp->lock)) {
 		netif_stop_queue(dev);
@@ -662,7 +662,7 @@ static int smc_hard_start_xmit(struct sk
 	void __iomem *ioaddr = lp->base;
 	unsigned int numPages, poll_count, status;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -734,7 +734,7 @@ static void smc_tx(struct net_device *de
 	void __iomem *ioaddr = lp->base;
 	unsigned int saved_packet, packet_no, tx_status, pkt_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* If the TX FIFO is empty then nothing to do */
 	packet_no = SMC_GET_TXFIFO(lp);
@@ -856,7 +856,7 @@ static int smc_phy_read(struct net_devic
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 	return phydata;
@@ -883,7 +883,7 @@ static void smc_phy_write(struct net_dev
 	SMC_SET_MII(lp, SMC_GET_MII(lp) & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(lp, 2);
 }
@@ -896,7 +896,7 @@ static void smc_phy_detect(struct net_de
 	struct smc_local *lp = netdev_priv(dev);
 	int phyaddr;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -935,7 +935,7 @@ static int smc_phy_fixed(struct net_devi
 	int phyaddr = lp->mii.phy_id;
 	int bmcr, cfg1;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	cfg1 = smc_phy_read(dev, phyaddr, PHY_CFG1_REG);
@@ -1168,7 +1168,7 @@ static void smc_phy_interrupt(struct net
 	int phyaddr = lp->mii.phy_id;
 	int phy18;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1236,7 +1236,7 @@ static irqreturn_t smc_interrupt(int irq
 	int status, mask, timeout, card_stats;
 	int saved_pointer;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	spin_lock(&lp->lock);
 
@@ -1358,7 +1358,7 @@ static void smc_timeout(struct net_devic
 	void __iomem *ioaddr = lp->base;
 	int status, mask, eph_st, meminfo, fifo;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	spin_lock_irq(&lp->lock);
 	status = SMC_GET_INT(lp);
@@ -1402,7 +1402,7 @@ static void smc_set_multicast_list(struc
 	unsigned char multicast_table[8];
 	int update_multicast = 0;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (dev->flags & IFF_PROMISC) {
 		DBG(2, "%s: RCR_PRMS\n", dev->name);
@@ -1505,7 +1505,7 @@ smc_open(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1513,7 +1513,7 @@ smc_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1557,7 +1557,7 @@ static int smc_close(struct net_device *
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1700,7 +1700,7 @@ static int __init smc_findirq(struct smc
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	cookie = probe_irq_on();
 
@@ -1778,7 +1778,7 @@ static int __init smc_probe(struct net_d
 	const char *version_string;
 	DECLARE_MAC_BUF(mac);
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* First, see if the high byte is 0x33 */
 	val = SMC_CURRENT_BANK(lp);
diff -puN drivers/net/tehuti.h~drivers-net-replace-__function__-with-__func__ drivers/net/tehuti.h
--- a/drivers/net/tehuti.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/tehuti.h
@@ -539,22 +539,22 @@ struct txd_desc {
 
 #define ERR(fmt, args...) printk(KERN_ERR fmt, ## args)
 #define DBG2(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
 
 #define BDX_ASSERT(x) BUG_ON(x)
 
 #ifdef DEBUG
 
 #define ENTER          do { \
-	printk(KERN_ERR  "%s:%-5d: ENTER\n", __FUNCTION__, __LINE__); \
+	printk(KERN_ERR  "%s:%-5d: ENTER\n", __func__, __LINE__); \
 } while (0)
 
 #define RET(args...)   do { \
-	printk(KERN_ERR  "%s:%-5d: RETURN\n", __FUNCTION__, __LINE__); \
+	printk(KERN_ERR  "%s:%-5d: RETURN\n", __func__, __LINE__); \
 return args; } while (0)
 
 #define DBG(fmt, args...)	\
-	printk(KERN_ERR  "%s:%-5d: " fmt, __FUNCTION__, __LINE__, ## args)
+	printk(KERN_ERR  "%s:%-5d: " fmt, __func__, __LINE__, ## args)
 #else
 #define ENTER         do {  } while (0)
 #define RET(args...)   return args
diff -puN drivers/net/tsi108_eth.c~drivers-net-replace-__function__-with-__func__ drivers/net/tsi108_eth.c
--- a/drivers/net/tsi108_eth.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/tsi108_eth.c
@@ -263,7 +263,7 @@ static inline void tsi108_write_tbi(stru
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static int mii_speed(struct mii_if_info *mii)
@@ -1059,7 +1059,7 @@ static void tsi108_stop_ethernet(struct 
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static void tsi108_reset_ether(struct tsi108_prv_data * data)
@@ -1244,7 +1244,7 @@ static void tsi108_init_phy(struct net_d
 		udelay(10);
 	}
 	if (i == 0)
-		printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+		printk(KERN_ERR "%s function time out \n", __func__);
 
 	if (data->phy_type == TSI108_PHY_BCM54XX) {
 		tsi108_write_mii(data, 0x09, 0x0300);
diff -puN drivers/net/ucc_geth.c~drivers-net-replace-__function__-with-__func__ drivers/net/ucc_geth.c
--- a/drivers/net/ucc_geth.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/ucc_geth.c
@@ -400,7 +400,7 @@ static struct enet_addr_container *get_e
 	enet_addr_cont = kmalloc(sizeof(struct enet_addr_container), GFP_KERNEL);
 	if (!enet_addr_cont) {
 		ugeth_err("%s: No memory for enet_addr_container object.",
-			  __FUNCTION__);
+			  __func__);
 		return NULL;
 	}
 
@@ -427,7 +427,7 @@ static int hw_add_addr_in_paddr(struct u
 	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illegal paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illegal paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -447,7 +447,7 @@ static int hw_clear_addr_in_paddr(struct
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illagel paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illagel paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -1441,7 +1441,7 @@ static int adjust_enet_interface(struct 
 	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	ug_info = ugeth->ug_info;
 	ug_regs = ugeth->ug_regs;
@@ -1504,7 +1504,7 @@ static int adjust_enet_interface(struct 
 	if (ret_val != 0) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
-			     __FUNCTION__);
+			     __func__);
 		return ret_val;
 	}
 
@@ -1744,7 +1744,7 @@ static int ugeth_enable(struct ucc_geth_
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -1773,7 +1773,7 @@ static int ugeth_disable(struct ucc_geth
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -2062,7 +2062,7 @@ static int ugeth_82xx_filtering_add_addr
 		ugeth_warn
 		    ("%s: multicast address added to paddr will have no "
 		     "effect - is this what you wanted?",
-		     __FUNCTION__);
+		     __func__);
 
 	ugeth->indAddrRegUsed[paddr_num] = 1;	/* mark this paddr as used */
 	/* store address in our database */
@@ -2278,7 +2278,7 @@ static void ucc_geth_stop(struct ucc_get
 	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	/* Disable the controller */
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
@@ -2315,7 +2315,7 @@ static int ucc_struct_init(struct ucc_ge
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Bad memory partition value.",
-					__FUNCTION__);
+					__func__);
 		return -EINVAL;
 	}
 
@@ -2327,7 +2327,7 @@ static int ucc_struct_init(struct ucc_ge
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
-					__FUNCTION__);
+					__func__);
 			return -EINVAL;
 		}
 	}
@@ -2338,7 +2338,7 @@ static int ucc_struct_init(struct ucc_ge
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Tx BD ring length must be no smaller than 2.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2349,21 +2349,21 @@ static int ucc_struct_init(struct ucc_ge
 		if (netif_msg_probe(ugeth))
 			ugeth_err
 			    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
-			     __FUNCTION__);
+			     __func__);
 		return -EINVAL;
 	}
 
 	/* num Tx queues */
 	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of tx queues too large.", __FUNCTION__);
+			ugeth_err("%s: number of tx queues too large.", __func__);
 		return -EINVAL;
 	}
 
 	/* num Rx queues */
 	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of rx queues too large.", __FUNCTION__);
+			ugeth_err("%s: number of rx queues too large.", __func__);
 		return -EINVAL;
 	}
 
@@ -2374,7 +2374,7 @@ static int ucc_struct_init(struct ucc_ge
 				ugeth_err
 				    ("%s: VLAN priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2386,7 +2386,7 @@ static int ucc_struct_init(struct ucc_ge
 				ugeth_err
 				    ("%s: IP priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2394,7 +2394,7 @@ static int ucc_struct_init(struct ucc_ge
 	if (ug_info->cam && !ug_info->ecamptr) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2404,7 +2404,7 @@ static int ucc_struct_init(struct ucc_ge
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Number of station addresses greater than 1 "
 				  "not allowed in extended parsing mode.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2418,7 +2418,7 @@ static int ucc_struct_init(struct ucc_ge
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+			ugeth_err("%s: Failed to init uccf.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2448,7 +2448,7 @@ static int ucc_geth_startup(struct ucc_g
 	u8 __iomem *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
@@ -2474,7 +2474,7 @@ static int ucc_geth_startup(struct ucc_g
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Rx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2499,7 +2499,7 @@ static int ucc_geth_startup(struct ucc_g
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Tx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2553,7 +2553,7 @@ static int ucc_geth_startup(struct ucc_g
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: IPGIFG initialization parameter too large.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2571,7 +2571,7 @@ static int ucc_geth_startup(struct ucc_g
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Half Duplex initialization parameter too large.",
-			  __FUNCTION__);
+			  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2626,7 +2626,7 @@ static int ucc_geth_startup(struct ucc_g
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Tx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2662,7 +2662,7 @@ static int ucc_geth_startup(struct ucc_g
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Rx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2678,7 +2678,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (ugeth->tx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate tx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2710,7 +2710,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (ugeth->rx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate rx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2744,7 +2744,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2767,7 +2767,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2797,7 +2797,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2841,7 +2841,7 @@ static int ucc_geth_startup(struct ucc_g
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2892,7 +2892,7 @@ static int ucc_geth_startup(struct ucc_g
 				ugeth_err
 				    ("%s: Can not allocate DPRAM memory for"
 					" p_tx_fw_statistics_pram.",
-				       	__FUNCTION__);
+				       	__func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2932,7 +2932,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2954,7 +2954,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2978,7 +2978,7 @@ static int ucc_geth_startup(struct ucc_g
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_rx_fw_statistics_pram.", __FUNCTION__);
+					" p_rx_fw_statistics_pram.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3001,7 +3001,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for"
-				" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+				" p_rx_irq_coalescing_tbl.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3070,7 +3070,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3147,7 +3147,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (!ug_info->extendedFilteringChainPointer) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
@@ -3161,7 +3161,7 @@ static int ucc_geth_startup(struct ucc_g
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_exf_glbl_param.", __FUNCTION__);
+					" p_exf_glbl_param.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3209,7 +3209,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate memory for"
-				" p_UccInitEnetParamShadows.", __FUNCTION__);
+				" p_UccInitEnetParamShadows.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3244,7 +3244,7 @@ static int ucc_geth_startup(struct ucc_g
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Invalid largest External Lookup Key Size.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
@@ -3271,7 +3271,7 @@ static int ucc_geth_startup(struct ucc_g
 		ug_info->riscRx, 1)) != 0) {
 		if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-					__FUNCTION__);
+					__func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3287,7 +3287,7 @@ static int ucc_geth_startup(struct ucc_g
 				    ug_info->riscTx, 0)) != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3297,7 +3297,7 @@ static int ucc_geth_startup(struct ucc_g
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill Rx bds with buffers.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
@@ -3309,7 +3309,7 @@ static int ucc_geth_startup(struct ucc_g
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3360,7 +3360,7 @@ static void ucc_geth_timeout(struct net_
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev->stats.tx_errors++;
 
@@ -3386,7 +3386,7 @@ static int ucc_geth_start_xmit(struct sk
 	u32 bd_status;
 	u8 txQ = 0;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	spin_lock_irq(&ugeth->lock);
 
@@ -3459,7 +3459,7 @@ static int ucc_geth_rx(struct ucc_geth_p
 	u8 *bdBuffer;
 	struct net_device *dev;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev = ugeth->dev;
 
@@ -3481,7 +3481,7 @@ static int ucc_geth_rx(struct ucc_geth_p
 		    (bd_status & R_ERRORS_FATAL)) {
 			if (netif_msg_rx_err(ugeth))
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
-					   __FUNCTION__, __LINE__, (u32) skb);
+					   __func__, __LINE__, (u32) skb);
 			if (skb)
 				dev_kfree_skb_any(skb);
 
@@ -3507,7 +3507,7 @@ static int ucc_geth_rx(struct ucc_geth_p
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
-				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+				ugeth_warn("%s: No Rx Data Buffer", __func__);
 			dev->stats.rx_dropped++;
 			break;
 		}
@@ -3613,7 +3613,7 @@ static irqreturn_t ucc_geth_irq_handler(
 	register u32 tx_mask;
 	u8 i;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
@@ -3683,13 +3683,13 @@ static int ucc_geth_open(struct net_devi
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 	int err;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	/* Test station address */
 	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Multicast address used for station address"
-				  " - is this what you wanted?", __FUNCTION__);
+				  " - is this what you wanted?", __func__);
 		return -EINVAL;
 	}
 
@@ -3772,7 +3772,7 @@ static int ucc_geth_close(struct net_dev
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	napi_disable(&ugeth->napi);
 
@@ -3840,7 +3840,7 @@ static int ucc_geth_probe(struct of_devi
 		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
 	};
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	prop = of_get_property(np, "cell-index", NULL);
 	if (!prop) {
@@ -3857,7 +3857,7 @@ static int ucc_geth_probe(struct of_devi
 	if (ug_info == NULL) {
 		if (netif_msg_probe(&debug))
 			ugeth_err("%s: [%d] Missing additional data!",
-				       	__FUNCTION__, ucc_num);
+				       	__func__, ucc_num);
 		return -ENODEV;
 	}
 
diff -puN drivers/net/usb/mcs7830.c~drivers-net-replace-__function__-with-__func__ drivers/net/usb/mcs7830.c
--- a/drivers/net/usb/mcs7830.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/usb/mcs7830.c
@@ -114,7 +114,7 @@ static void mcs7830_async_cmd_callback(s
 
 	if (urb->status < 0)
 		printk(KERN_DEBUG "%s() failed with %d\n",
-		       __FUNCTION__, urb->status);
+		       __func__, urb->status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff -puN drivers/net/usb/pegasus.c~drivers-net-replace-__function__-with-__func__ drivers/net/usb/pegasus.c
--- a/drivers/net/usb/pegasus.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/usb/pegasus.c
@@ -119,7 +119,7 @@ static void ctrl_callback(struct urb *ur
 	default:
 		if (netif_msg_drv(pegasus))
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
-				__FUNCTION__, urb->status);
+				__func__, urb->status);
 	}
 	pegasus->flags &= ~ETH_REGS_CHANGED;
 	wake_up(&pegasus->ctrl_wait);
@@ -136,7 +136,7 @@ static int get_registers(pegasus_t * peg
 	if (!buffer) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
@@ -168,7 +168,7 @@ static int get_registers(pegasus_t * peg
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -192,7 +192,7 @@ static int set_registers(pegasus_t * peg
 	if (!buffer) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	memcpy(buffer, data, size);
@@ -224,7 +224,7 @@ static int set_registers(pegasus_t * peg
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -246,7 +246,7 @@ static int set_register(pegasus_t * pega
 	if (!tmp) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	memcpy(tmp, &data, 1);
@@ -277,7 +277,7 @@ static int set_register(pegasus_t * pega
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -310,7 +310,7 @@ static int update_eth_regs_async(pegasus
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 	}
 
 	return ret;
@@ -341,7 +341,7 @@ static int read_mii_word(pegasus_t * peg
 	}
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 
 	return ret;
 }
@@ -378,7 +378,7 @@ static int write_mii_word(pegasus_t * pe
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -415,7 +415,7 @@ static int read_eprom_word(pegasus_t * p
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -463,7 +463,7 @@ static int write_eprom_word(pegasus_t * 
 		return ret;
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 #endif				/* PEGASUS_WRITE_EEPROM */
diff -puN drivers/net/via-velocity.h~drivers-net-replace-__function__-with-__func__ drivers/net/via-velocity.h
--- a/drivers/net/via-velocity.h~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/via-velocity.h
@@ -1381,7 +1381,7 @@ enum velocity_msg_level {
 #define ASSERT(x) { \
 	if (!(x)) { \
 		printk(KERN_ERR "assertion %s failed: file %s line %d\n", #x,\
-			__FUNCTION__, __LINE__);\
+			__func__, __LINE__);\
 		BUG(); \
 	}\
 }
diff -puN drivers/net/wan/cycx_drv.c~drivers-net-replace-__function__-with-__func__ drivers/net/wan/cycx_drv.c
--- a/drivers/net/wan/cycx_drv.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/wan/cycx_drv.c
@@ -407,7 +407,7 @@ static int load_cyc2x(struct cycx_hw *hw
 	if (cfm->version != CFM_VERSION) {
 		printk(KERN_ERR "%s:%s: firmware format %u rejected! "
 				"Expecting %u.\n",
-				modname, __FUNCTION__, cfm->version, CFM_VERSION);
+				modname, __func__, cfm->version, CFM_VERSION);
 		return -EINVAL;
 	}
 
@@ -420,7 +420,7 @@ static int load_cyc2x(struct cycx_hw *hw
 */
 	if (cksum != cfm->checksum) {
 		printk(KERN_ERR "%s:%s: firmware corrupted!\n",
-				modname, __FUNCTION__);
+				modname, __func__);
 		printk(KERN_ERR " cdsize = 0x%x (expected 0x%lx)\n",
 				len - (int)sizeof(struct cycx_firmware) - 1,
 				cfm->info.codesize);
@@ -432,7 +432,7 @@ static int load_cyc2x(struct cycx_hw *hw
 	/* If everything is ok, set reset, data and code pointers */
 	img_hdr = (struct cycx_fw_header *)&cfm->image;
 #ifdef FIRMWARE_DEBUG
-	printk(KERN_INFO "%s:%s: image sizes\n", __FUNCTION__, modname);
+	printk(KERN_INFO "%s:%s: image sizes\n", __func__, modname);
 	printk(KERN_INFO " reset=%lu\n", img_hdr->reset_size);
 	printk(KERN_INFO "  data=%lu\n", img_hdr->data_size);
 	printk(KERN_INFO "  code=%lu\n", img_hdr->code_size);
diff -puN drivers/net/wan/cycx_x25.c~drivers-net-replace-__function__-with-__func__ drivers/net/wan/cycx_x25.c
--- a/drivers/net/wan/cycx_x25.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/wan/cycx_x25.c
@@ -874,7 +874,7 @@ static void cycx_x25_irq_connect(struct 
 		nibble_to_byte(d + (sizeloc >> 1), rem, sizerem, sizeloc & 1);
 
 	dprintk(1, KERN_INFO "%s:lcn=%d, local=%s, remote=%s\n",
-			  __FUNCTION__, lcn, loc, rem);
+			  __func__, lcn, loc, rem);
 
 	dev = cycx_x25_get_dev_by_dte_addr(wandev, rem);
 	if (!dev) {
@@ -902,7 +902,7 @@ static void cycx_x25_irq_connect_confirm
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	cycx_peek(&card->hw, cmd->buf + 1, &key, sizeof(key));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d, key=%d\n",
-			  card->devname, __FUNCTION__, lcn, key);
+			  card->devname, __func__, lcn, key);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, -key);
 	if (!dev) {
@@ -929,7 +929,7 @@ static void cycx_x25_irq_disconnect_conf
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d\n",
-			  card->devname, __FUNCTION__, lcn);
+			  card->devname, __func__, lcn);
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (!dev) {
 		/* Invalid channel, discard packet */
@@ -950,7 +950,7 @@ static void cycx_x25_irq_disconnect(stru
 	u8 lcn;
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
-	dprintk(1, KERN_INFO "%s:lcn=%d\n", __FUNCTION__, lcn);
+	dprintk(1, KERN_INFO "%s:lcn=%d\n", __func__, lcn);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (dev) {
@@ -1381,7 +1381,7 @@ static void cycx_x25_chan_timer(unsigned
 		cycx_x25_chan_disconnect(dev);
 	else
 		printk(KERN_ERR "%s: %s for svc (%s) not connected!\n",
-				chan->card->devname, __FUNCTION__, dev->name);
+				chan->card->devname, __func__, dev->name);
 }
 
 /* Set logical channel state. */
@@ -1485,7 +1485,7 @@ static void cycx_x25_chan_send_event(str
 	unsigned char *ptr;
 
 	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", __FUNCTION__);
+		printk(KERN_ERR "%s: out of memory\n", __func__);
 		return;
 	}
 
diff -puN drivers/net/wan/dscc4.c~drivers-net-replace-__function__-with-__func__ drivers/net/wan/dscc4.c
--- a/drivers/net/wan/dscc4.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/wan/dscc4.c
@@ -647,7 +647,7 @@ static inline void dscc4_rx_skb(struct d
 
 	skb = dpriv->rx_skbuff[dpriv->rx_current++%RX_RING_SIZE];
 	if (!skb) {
-		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __FUNCTION__);
+		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __func__);
 		goto refill;
 	}
 	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
diff -puN drivers/net/wan/pc300_tty.c~drivers-net-replace-__function__-with-__func__ drivers/net/wan/pc300_tty.c
--- a/drivers/net/wan/pc300_tty.c~drivers-net-replace-__function__-with-__func__
+++ a/drivers/net/wan/pc300_tty.c
@@ -548,7 +548,7 @@ static int pc300_tiocmset(struct tty_str
 {
 	st_cpc_tty_area    *cpc_tty; 
 
-	CPC_TTY_DBG("%s: set:%x clear:%x\n", __FUNCTION__, set, clear);
+	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
 
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");	
_
