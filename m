From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] drivers/net: replace remaining __FUNCTION__ occurances
Date: Mon, 03 Mar 2008 12:33:38 -0800
Message-ID: <1204576418.22933.1.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:17639 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508AbYCCUds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 15:33:48 -0500
Received: by gv-out-0910.google.com with SMTP id s4so175817gve.37
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2008 12:33:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

__FUNCTION__ is gcc-specific, use __func__

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Done with sed and eyeballed the diff afterwards, against
net-2.6.26.git:master

 drivers/net/3c505.c                            |    4 +-
 drivers/net/8139too.c                          |    4 +-
 drivers/net/arcnet/arcnet.c                    |   18 +-
 drivers/net/arcnet/com20020.c                  |   16 +-
 drivers/net/ax88796.c                          |   14 +-
 drivers/net/bfin_mac.c                         |    8 +-
 drivers/net/bnx2x.h                            |    6 +-
 drivers/net/bonding/bonding.h                  |    2 +-
 drivers/net/cxgb3/cxgb3_offload.c              |    8 +-
 drivers/net/e100.c                             |    2 +-
 drivers/net/e1000/e1000.h                      |    2 +-
 drivers/net/enc28j60.c                         |   56 +++---
 drivers/net/ibm_newemac/phy.c                  |    2 +-
 drivers/net/irda/act200l-sir.c                 |   10 +-
 drivers/net/irda/actisys-sir.c                 |    2 +-
 drivers/net/irda/ali-ircc.c                    |  246 ++++++++++++------------
 drivers/net/irda/donauboe.c                    |   68 ++++----
 drivers/net/irda/girbil-sir.c                  |   12 +-
 drivers/net/irda/irda-usb.c                    |   92 +++++-----
 drivers/net/irda/irtty-sir.c                   |   12 +-
 drivers/net/irda/kingsun-sir.c                 |    2 +-
 drivers/net/irda/litelink-sir.c                |    8 +-
 drivers/net/irda/ma600-sir.c                   |   16 +-
 drivers/net/irda/mcp2120-sir.c                 |   12 +-
 drivers/net/irda/nsc-ircc.c                    |  112 ++++++------
 drivers/net/irda/old_belkin-sir.c              |    8 +-
 drivers/net/irda/sir_dev.c                     |   62 +++---
 drivers/net/irda/sir_dongle.c                  |    2 +-
 drivers/net/irda/smsc-ircc2.c                  |  120 ++++++------
 drivers/net/irda/tekram-sir.c                  |   10 +-
 drivers/net/irda/toim3232-sir.c                |   10 +-
 drivers/net/irda/via-ircc.c                    |   80 ++++----
 drivers/net/irda/vlsi_ir.c                     |   92 +++++-----
 drivers/net/irda/vlsi_ir.h                     |    2 +-
 drivers/net/irda/w83977af_ir.c                 |   62 +++---
 drivers/net/ixgb/ixgb.h                        |    2 +-
 drivers/net/ixgbe/ixgbe.h                      |    2 +-
 drivers/net/meth.c                             |    2 +-
 drivers/net/mipsnet.c                          |    2 +-
 drivers/net/netx-eth.c                         |    2 +-
 drivers/net/netxen/netxen_nic.h                |    2 +-
 drivers/net/netxen/netxen_nic_hw.c             |    2 +-
 drivers/net/netxen/netxen_nic_init.c           |    6 +-
 drivers/net/netxen/netxen_nic_isr.c            |    2 +-
 drivers/net/pci-skeleton.c                     |    4 +-
 drivers/net/r8169.c                            |    2 +-
 drivers/net/s2io.c                             |   44 ++--
 drivers/net/smc911x.c                          |   66 ++++----
 drivers/net/smc91x.c                           |   40 ++--
 drivers/net/tehuti.h                           |    8 +-
 drivers/net/tsi108_eth.c                       |    6 +-
 drivers/net/ucc_geth.c                         |  116 ++++++------
 drivers/net/usb/mcs7830.c                      |    2 +-
 drivers/net/usb/pegasus.c                      |   24 ++--
 drivers/net/usb/rtl8150.c                      |    6 +-
 drivers/net/via-velocity.h                     |    2 +-
 drivers/net/wan/cycx_drv.c                     |    6 +-
 drivers/net/wan/cycx_x25.c                     |   12 +-
 drivers/net/wan/dscc4.c                        |    2 +-
 drivers/net/wan/pc300_tty.c                    |    2 +-
 drivers/net/wireless/airo.c                    |   16 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h         |    2 +-
 drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h |    4 +-
 drivers/net/wireless/hermes.c                  |    2 +-
 drivers/net/wireless/ipw2100.c                 |    2 +-
 drivers/net/wireless/ipw2200.h                 |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h  |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h  |    4 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c    |    4 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c    |    4 +-
 drivers/net/wireless/libertas/defs.h           |    8 +-
 drivers/net/wireless/libertas/if_cs.c          |    4 +-
 drivers/net/wireless/prism54/isl_ioctl.c       |    8 +-
 drivers/net/wireless/rt2x00/rt2x00.h           |    4 +-
 drivers/net/wireless/wl3501_cs.c               |    8 +-
 75 files changed, 812 insertions(+), 812 deletions(-)

diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 9c65734..5c8866c 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
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
 
diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
index be6e918..39cb3c3 100644
--- a/drivers/net/8139too.c
+++ b/drivers/net/8139too.c
@@ -134,7 +134,7 @@
 
 #if RTL8139_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -145,7 +145,7 @@
 #  define assert(expr) \
         if(unlikely(!(expr))) {				        \
         printk(KERN_ERR "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		        \
+        #expr,__FILE__,__func__,__LINE__);		        \
         }
 #endif
 
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index c59c806..733f5c5 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -442,24 +442,24 @@ static int arcnet_open(struct net_device *dev)
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
 
@@ -670,14 +670,14 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
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
@@ -798,7 +798,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
                 diagstatus = (status >> 8) & 0xFF;
 
 		BUGMSG(D_DEBUG, "%s: %d: %s: status=%x\n",
-			__FILE__,__LINE__,__FUNCTION__,status);
+			__FILE__,__LINE__,__func__,status);
 		didsomething = 0;
 
 		/*
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 7cf0a25..048faf2 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -238,15 +238,15 @@ static int com20020_reset(struct net_device *dev, int really_reset)
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
@@ -254,22 +254,22 @@ static int com20020_reset(struct net_device *dev, int really_reset)
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
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 194949a..fe0bdca 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -153,7 +153,7 @@ static void ax_reset_8390(struct net_device *dev)
 	while ((ei_inb(addr + EN0_ISR) & ENISR_RESET) == 0) {
 		if (jiffies - reset_start_time > 2*HZ/100) {
 			dev_warn(&ax->dev->dev, "%s: %s did not complete.\n",
-			       __FUNCTION__, dev->name);
+			       __func__, dev->name);
 			break;
 		}
 	}
@@ -173,7 +173,7 @@ static void ax_get_8390_hdr(struct net_device *dev, struct e8390_pkt_hdr *hdr,
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -215,7 +215,7 @@ static void ax_block_input(struct net_device *dev, int count,
 		dev_err(&ax->dev->dev,
 			"%s: DMAing conflict in %s "
 			"[DMAstat:%d][irqlock:%d].\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 			ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -260,7 +260,7 @@ static void ax_block_output(struct net_device *dev, int count,
 	if (ei_status.dmaing) {
 		dev_err(&ax->dev->dev, "%s: DMAing conflict in %s."
 			"[DMAstat:%d][irqlock:%d]\n",
-			dev->name, __FUNCTION__,
+			dev->name, __func__,
 		       ei_status.dmaing, ei_status.irqlock);
 		return;
 	}
@@ -396,7 +396,7 @@ ax_phy_issueaddr(struct net_device *dev, int phy_addr, int reg, int opc)
 {
 	if (phy_debug)
 		pr_debug("%s: dev %p, %04x, %04x, %d\n",
-			__FUNCTION__, dev, phy_addr, reg, opc);
+			__func__, dev, phy_addr, reg, opc);
 
 	ax_mii_ei_outbits(dev, 0x3f, 6);	/* pre-amble */
 	ax_mii_ei_outbits(dev, 1, 2);		/* frame-start */
@@ -422,7 +422,7 @@ ax_phy_read(struct net_device *dev, int phy_addr, int reg)
       	spin_unlock_irqrestore(&ei_local->page_lock, flags);
 
 	if (phy_debug)
-		pr_debug("%s: %04x.%04x => read %04x\n", __FUNCTION__,
+		pr_debug("%s: %04x.%04x => read %04x\n", __func__,
 			 phy_addr, reg, result);
 
 	return result;
@@ -436,7 +436,7 @@ ax_phy_write(struct net_device *dev, int phy_addr, int reg, int value)
 	unsigned long flags;
 
 	dev_dbg(&ax->dev->dev, "%s: %p, %04x, %04x %04x\n",
-		__FUNCTION__, dev, phy_addr, reg, value);
+		__func__, dev, phy_addr, reg, value);
 
       	spin_lock_irqsave(&ei->page_lock, flags);
 
diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index c993a32..7bafd68 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -733,7 +733,7 @@ static void bf537mac_enable(void)
 {
 	u32 opmode;
 
-	pr_debug("%s: %s\n", DRV_NAME, __FUNCTION__);
+	pr_debug("%s: %s\n", DRV_NAME, __func__);
 
 	/* Set RX DMA */
 	bfin_write_DMA1_NEXT_DESC_PTR(&(rx_list_head->desc_a));
@@ -769,7 +769,7 @@ static void bf537mac_enable(void)
 /* Our watchdog timed out. Called by the networking layer */
 static void bf537mac_timeout(struct net_device *dev)
 {
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	bf537mac_disable();
 
@@ -871,7 +871,7 @@ static int bf537mac_open(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
 	int retval;
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -910,7 +910,7 @@ static int bf537mac_open(struct net_device *dev)
 static int bf537mac_close(struct net_device *dev)
 {
 	struct bf537mac_local *lp = netdev_priv(dev);
-	pr_debug("%s: %s\n", dev->name, __FUNCTION__);
+	pr_debug("%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 4f0c0d3..6d56769 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -32,19 +32,19 @@
 /* regular debug print */
 #define DP(__mask, __fmt, __args...) do { \
 	if (bp->msglevel & (__mask)) \
-		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __FUNCTION__, \
+		printk(DP_LEVEL "[%s:%d(%s)]" __fmt, __func__, \
 		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
 /* for errors (never masked) */
 #define BNX2X_ERR(__fmt, __args...) do { \
-	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __FUNCTION__, \
+	printk(KERN_ERR "[%s:%d(%s)]" __fmt, __func__, \
 		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
 /* for logging (never masked) */
 #define BNX2X_LOG(__fmt, __args...) do { \
-	printk(KERN_NOTICE "[%s:%d(%s)]" __fmt, __FUNCTION__, \
+	printk(KERN_NOTICE "[%s:%d(%s)]" __fmt, __func__, \
 		__LINE__, bp->dev?(bp->dev->name):"?", ##__args); \
 	} while (0)
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 67ccad6..e57d977 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -32,7 +32,7 @@
 #ifdef BONDING_DEBUG
 #define dprintk(fmt, args...) \
 	printk(KERN_DEBUG     \
-	       DRV_NAME ": %s() %d: " fmt, __FUNCTION__, __LINE__ , ## args )
+	       DRV_NAME ": %s() %d: " fmt, __func__, __LINE__ , ## args )
 #else
 #define dprintk(fmt, args...)
 #endif /* BONDING_DEBUG */
diff --git a/drivers/net/cxgb3/cxgb3_offload.c b/drivers/net/cxgb3/cxgb3_offload.c
index 901c824..063465f 100644
--- a/drivers/net/cxgb3/cxgb3_offload.c
+++ b/drivers/net/cxgb3/cxgb3_offload.c
@@ -984,7 +984,7 @@ static void set_l2t_ix(struct t3cdev *tdev, u32 tid, struct l2t_entry *e)
 
 	skb = alloc_skb(sizeof(*req), GFP_ATOMIC);
 	if (!skb) {
-		printk(KERN_ERR "%s: cannot allocate skb!\n", __FUNCTION__);
+		printk(KERN_ERR "%s: cannot allocate skb!\n", __func__);
 		return;
 	}
 	skb->priority = CPL_PRIORITY_CONTROL;
@@ -1015,14 +1015,14 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
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
 
@@ -1030,7 +1030,7 @@ void cxgb_redirect(struct dst_entry *old, struct dst_entry *new)
 	e = t3_l2t_get(tdev, new->neighbour, newdev);
 	if (!e) {
 		printk(KERN_ERR "%s: couldn't allocate new l2t entry!\n",
-		       __FUNCTION__);
+		       __func__);
 		return;
 	}
 
diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 36ba6dc..52cfb16 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -191,7 +191,7 @@ MODULE_PARM_DESC(use_io, "Force use of i/o access mode");
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & nic->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, nic->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 #define INTEL_8255X_ETHERNET_DEVICE(device_id, ich) {\
 	PCI_VENDOR_ID_INTEL, device_id, PCI_ANY_ID, PCI_ANY_ID, \
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3b84028..19e00c3 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -93,7 +93,7 @@ struct e1000_adapter;
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 #define E1000_MAX_INTR 10
 
diff --git a/drivers/net/enc28j60.c b/drivers/net/enc28j60.c
index 0809a6a..3dad909 100644
--- a/drivers/net/enc28j60.c
+++ b/drivers/net/enc28j60.c
@@ -110,7 +110,7 @@ spi_read_buf(struct enc28j60_net *priv, int len, u8 *data)
 	}
 	if (ret && netif_msg_drv(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 
 	return ret;
 }
@@ -131,7 +131,7 @@ static int spi_write_buf(struct enc28j60_net *priv, int len,
 		ret = spi_write(priv->spi, priv->spi_transfer_buf, len + 1);
 		if (ret && netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-				__FUNCTION__, ret);
+				__func__, ret);
 	}
 	return ret;
 }
@@ -156,7 +156,7 @@ static u8 spi_read_op(struct enc28j60_net *priv, u8 op,
 	ret = spi_write_then_read(priv->spi, tx_buf, 1, rx_buf, slen);
 	if (ret)
 		printk(KERN_DEBUG DRV_NAME ": %s() failed: ret = %d\n",
-			__FUNCTION__, ret);
+			__func__, ret);
 	else
 		val = rx_buf[slen - 1];
 
@@ -176,14 +176,14 @@ static int spi_write_op(struct enc28j60_net *priv, u8 op,
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
@@ -357,7 +357,7 @@ static void enc28j60_mem_read(struct enc28j60_net *priv,
 		reg = nolock_regw_read(priv, ERDPTL);
 		if (reg != addr)
 			printk(KERN_DEBUG DRV_NAME ": %s() error writing ERDPT "
-				"(0x%04x - 0x%04x)\n", __FUNCTION__, reg, addr);
+				"(0x%04x - 0x%04x)\n", __func__, reg, addr);
 	}
 #endif
 	spi_read_buf(priv, len, data);
@@ -380,7 +380,7 @@ enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
 		if (reg != TXSTART_INIT)
 			printk(KERN_DEBUG DRV_NAME
 				": %s() ERWPT:0x%04x != 0x%04x\n",
-				__FUNCTION__, reg, TXSTART_INIT);
+				__func__, reg, TXSTART_INIT);
 	}
 #endif
 	/* Set the TXND pointer to correspond to the packet size given */
@@ -390,13 +390,13 @@ enc28j60_packet_write(struct enc28j60_net *priv, int len, const u8 *data)
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
 
@@ -490,7 +490,7 @@ static int enc28j60_set_hw_macaddr(struct net_device *ndev)
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME
 				": %s() Hardware must be disabled to set "
-				"Mac address\n", __FUNCTION__);
+				"Mac address\n", __func__);
 		ret = -EBUSY;
 	}
 	mutex_unlock(&priv->lock);
@@ -570,7 +570,7 @@ static void nolock_rxfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) RXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set receive buffer start + end */
@@ -586,7 +586,7 @@ static void nolock_txfifo_init(struct enc28j60_net *priv, u16 start, u16 end)
 	if (start > 0x1FFF || end > 0x1FFF || start > end) {
 		if (netif_msg_drv(priv))
 			printk(KERN_ERR DRV_NAME ": %s(%d, %d) TXFIFO "
-				"bad parameters!\n", __FUNCTION__, start, end);
+				"bad parameters!\n", __func__, start, end);
 		return;
 	}
 	/* set transmit buffer start + end */
@@ -599,7 +599,7 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 	u8 reg;
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __FUNCTION__,
+		printk(KERN_DEBUG DRV_NAME ": %s() - %s\n", __func__,
 			priv->full_duplex ? "FullDuplex" : "HalfDuplex");
 
 	mutex_lock(&priv->lock);
@@ -630,7 +630,7 @@ static int enc28j60_hw_init(struct enc28j60_net *priv)
 	if (reg == 0x00 || reg == 0xff) {
 		if (netif_msg_drv(priv))
 			printk(KERN_DEBUG DRV_NAME ": %s() Invalid RevId %d\n",
-				__FUNCTION__, reg);
+				__func__, reg);
 		return 0;
 	}
 
@@ -693,7 +693,7 @@ static void enc28j60_hw_enable(struct enc28j60_net *priv)
 	/* enable interrutps */
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() enabling interrupts.\n",
-			__FUNCTION__);
+			__func__);
 
 	enc28j60_phy_write(priv, PHIE, PHIE_PGEIE | PHIE_PLNKIE);
 
@@ -860,7 +860,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		if (netif_msg_rx_err(priv))
 			dev_err(&ndev->dev,
 				"%s() Invalid packet address!! 0x%04x\n",
-				__FUNCTION__, priv->next_pk_ptr);
+				__func__, priv->next_pk_ptr);
 		/* packet address corrupted: reset RX logic */
 		mutex_lock(&priv->lock);
 		nolock_reg_bfclr(priv, ECON1, ECON1_RXEN);
@@ -889,7 +889,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 	rxstat |= rsv[4];
 
 	if (netif_msg_rx_status(priv))
-		enc28j60_dump_rsv(priv, __FUNCTION__, next_packet, len, rxstat);
+		enc28j60_dump_rsv(priv, __func__, next_packet, len, rxstat);
 
 	if (!RSV_GETBIT(rxstat, RSV_RXOK)) {
 		if (netif_msg_rx_err(priv))
@@ -912,7 +912,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 			enc28j60_mem_read(priv, priv->next_pk_ptr + sizeof(rsv),
 					len, skb_put(skb, len));
 			if (netif_msg_pktdata(priv))
-				dump_packet(__FUNCTION__, skb->len, skb->data);
+				dump_packet(__func__, skb->len, skb->data);
 			skb->protocol = eth_type_trans(skb, ndev);
 			/* update statistics */
 			ndev->stats.rx_packets++;
@@ -929,7 +929,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 	erxrdpt = erxrdpt_workaround(next_packet, RXSTART_INIT, RXEND_INIT);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT:0x%04x\n",
-			__FUNCTION__, erxrdpt);
+			__func__, erxrdpt);
 
 	mutex_lock(&priv->lock);
 	nolock_regw_write(priv, ERXRDPTL, erxrdpt);
@@ -939,7 +939,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		reg = nolock_regw_read(priv, ERXRDPTL);
 		if (reg != erxrdpt)
 			printk(KERN_DEBUG DRV_NAME ": %s() ERXRDPT verify "
-				"error (0x%04x - 0x%04x)\n", __FUNCTION__,
+				"error (0x%04x - 0x%04x)\n", __func__,
 				reg, erxrdpt);
 	}
 #endif
@@ -977,7 +977,7 @@ static int enc28j60_get_free_rxfifo(struct enc28j60_net *priv)
 	mutex_unlock(&priv->lock);
 	if (netif_msg_rx_status(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() free_space = %d\n",
-			__FUNCTION__, free_space);
+			__func__, free_space);
 	return free_space;
 }
 
@@ -993,7 +993,7 @@ static void enc28j60_check_link_status(struct net_device *ndev)
 	reg = enc28j60_phy_read(priv, PHSTAT2);
 	if (netif_msg_hw(priv))
 		printk(KERN_DEBUG DRV_NAME ": %s() PHSTAT1: %04x, "
-			"PHSTAT2: %04x\n", __FUNCTION__,
+			"PHSTAT2: %04x\n", __func__,
 			enc28j60_phy_read(priv, PHSTAT1), reg);
 	duplex = reg & PHSTAT2_DPXSTAT;
 
@@ -1066,7 +1066,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 	int intflags, loop;
 
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 	/* disable further interrupts */
 	locked_reg_bfclr(priv, EIE, EIE_INTIE);
 
@@ -1169,7 +1169,7 @@ static void enc28j60_irq_work_handler(struct work_struct *work)
 	/* re-enable interrupts */
 	locked_reg_bfset(priv, EIE, EIE_INTIE);
 	if (netif_msg_intr(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() exit\n", __func__);
 }
 
 /*
@@ -1184,7 +1184,7 @@ static void enc28j60_hw_tx(struct enc28j60_net *priv)
 			": Tx Packet Len:%d\n", priv->tx_skb->len);
 
 	if (netif_msg_pktdata(priv))
-		dump_packet(__FUNCTION__,
+		dump_packet(__func__,
 			    priv->tx_skb->len, priv->tx_skb->data);
 	enc28j60_packet_write(priv, priv->tx_skb->len, priv->tx_skb->data);
 
@@ -1225,7 +1225,7 @@ static int enc28j60_send_packet(struct sk_buff *skb, struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_tx_queued(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	/* If some error occurs while trying to transmit this
 	 * packet, you should return '1' from this function.
@@ -1296,7 +1296,7 @@ static int enc28j60_net_open(struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		if (netif_msg_ifup(priv)) {
@@ -1333,7 +1333,7 @@ static int enc28j60_net_close(struct net_device *dev)
 	struct enc28j60_net *priv = netdev_priv(dev);
 
 	if (netif_msg_drv(priv))
-		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __FUNCTION__);
+		printk(KERN_DEBUG DRV_NAME ": %s() enter\n", __func__);
 
 	enc28j60_hw_disable(priv);
 	netif_stop_queue(dev);
diff --git a/drivers/net/ibm_newemac/phy.c b/drivers/net/ibm_newemac/phy.c
index 37bfeea..9164abb 100644
--- a/drivers/net/ibm_newemac/phy.c
+++ b/drivers/net/ibm_newemac/phy.c
@@ -321,7 +321,7 @@ static struct mii_phy_def bcm5248_phy_def = {
 
 static int m88e1111_init(struct mii_phy *phy)
 {
-	pr_debug("%s: Marvell 88E1111 Ethernet\n", __FUNCTION__);
+	pr_debug("%s: Marvell 88E1111 Ethernet\n", __func__);
 	phy_write(phy, 0x14, 0x0ce3);
 	phy_write(phy, 0x18, 0x4101);
 	phy_write(phy, 0x09, 0x0e00);
diff --git a/drivers/net/irda/act200l-sir.c b/drivers/net/irda/act200l-sir.c
index d8b89c7..37ab8c8 100644
--- a/drivers/net/irda/act200l-sir.c
+++ b/drivers/net/irda/act200l-sir.c
@@ -107,7 +107,7 @@ static int act200l_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Power on the dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -124,7 +124,7 @@ static int act200l_open(struct sir_dev *dev)
 
 static int act200l_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Power off the dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -143,7 +143,7 @@ static int act200l_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[3];
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	/* Clear DTR and set RTS to enter command mode */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
@@ -212,7 +212,7 @@ static int act200l_reset(struct sir_dev *dev)
 	};
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s()\n", __func__ );
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -240,7 +240,7 @@ static int act200l_reset(struct sir_dev *dev)
 		dev->speed = 9600;
 		break;
 	default:
-		IRDA_ERROR("%s(), unknown state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), unknown state %d\n", __func__, state);
 		ret = -1;
 		break;
 	}
diff --git a/drivers/net/irda/actisys-sir.c b/drivers/net/irda/actisys-sir.c
index 736d247..50b2141 100644
--- a/drivers/net/irda/actisys-sir.c
+++ b/drivers/net/irda/actisys-sir.c
@@ -165,7 +165,7 @@ static int actisys_change_speed(struct sir_dev *dev, unsigned speed)
 	int ret = 0;
 	int i = 0;
 
-        IRDA_DEBUG(4, "%s(), speed=%d (was %d)\n", __FUNCTION__,
+        IRDA_DEBUG(4, "%s(), speed=%d (was %d)\n", __func__,
         	speed, dev->speed);
 
 	/* dongle was already resetted from irda_request state machine,
diff --git a/drivers/net/irda/ali-ircc.c b/drivers/net/irda/ali-ircc.c
index 9f58452..ee06577 100644
--- a/drivers/net/irda/ali-ircc.c
+++ b/drivers/net/irda/ali-ircc.c
@@ -151,7 +151,7 @@ static int __init ali_ircc_init(void)
 	int reg, revision;
 	int i = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 
 	ret = platform_driver_register(&ali_ircc_driver);
         if (ret) {
@@ -165,7 +165,7 @@ static int __init ali_ircc_init(void)
 	/* Probe for all the ALi chipsets we know about */
 	for (chip= chips; chip->name; chip++, i++) 
 	{
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__, chip->name);
+		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__, chip->name);
 				
 		/* Try all config registers for this chip */
 		for (cfg=0; cfg<2; cfg++)
@@ -195,11 +195,11 @@ static int __init ali_ircc_init(void)
 				
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
@@ -222,14 +222,14 @@ static int __init ali_ircc_init(void)
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
@@ -247,7 +247,7 @@ static void __exit ali_ircc_cleanup(void)
 {
 	int i;
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);	
 
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
@@ -256,7 +256,7 @@ static void __exit ali_ircc_cleanup(void)
 	
 	platform_driver_unregister(&ali_ircc_driver);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 }
 
 /*
@@ -272,11 +272,11 @@ static int ali_ircc_open(int i, chipio_t *info)
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
 	
@@ -287,7 +287,7 @@ static int ali_ircc_open(int i, chipio_t *info)
 	dev = alloc_irdadev(sizeof(*self));
 	if (dev == NULL) {
 		IRDA_ERROR("%s(), can't allocate memory for control block!\n",
-			   __FUNCTION__);
+			   __func__);
 		return -ENOMEM;
 	}
 
@@ -311,7 +311,7 @@ static int ali_ircc_open(int i, chipio_t *info)
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext,
 			    ALI_IRCC_DRIVER_NAME)) {
-		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __FUNCTION__,
+		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n", __func__,
 			self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
@@ -369,19 +369,19 @@ static int ali_ircc_open(int i, chipio_t *info)
 
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
 
@@ -410,7 +410,7 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -420,7 +420,7 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 	unregister_netdev(self->netdev);
 
 	/* Release the PORT that this driver is using */
-	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", __FUNCTION__, self->io.fir_base);
+	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -434,7 +434,7 @@ static int __exit ali_ircc_close(struct ali_ircc_cb *self)
 	dev_self[self->index] = NULL;
 	free_netdev(self->netdev);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End -----------------\n", __func__);
 	
 	return 0;
 }
@@ -477,7 +477,7 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 	int cfg_base = info->cfg_base;
 	int hi, low, reg;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Enter Configuration */
 	outb(chip->entr1, cfg_base);
@@ -496,13 +496,13 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
 	
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
@@ -510,26 +510,26 @@ static int ali_ircc_probe_53(ali_chip_t *chip, chipio_t *info)
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
@@ -547,7 +547,7 @@ static int ali_ircc_setup(chipio_t *info)
 	int version;
 	int iobase = info->fir_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	/* Locking comments :
 	 * Most operations here need to be protected. We are called before
@@ -608,7 +608,7 @@ static int ali_ircc_setup(chipio_t *info)
 	// outb(UART_IER_RDI, iobase+UART_IER); //benjamin 2000/11/23 01:25PM
 	// Turn on the interrupts in ali_ircc_net_open
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);	
 	
 	return 0;
 }
@@ -625,7 +625,7 @@ static int ali_ircc_read_dongle_id (int i, chipio_t *info)
 	int dongle_id, reg;
 	int cfg_base = info->cfg_base;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	/* Enter Configuration */
 	outb(chips[i].entr1, cfg_base);
@@ -639,13 +639,13 @@ static int ali_ircc_read_dongle_id (int i, chipio_t *info)
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
@@ -662,7 +662,7 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 	struct ali_ircc_cb *self;
 	int ret;
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 		
 	self = dev->priv;
 	
@@ -676,7 +676,7 @@ static irqreturn_t ali_ircc_interrupt(int irq, void *dev_id)
 		
 	spin_unlock(&self->lock);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__);
 	return ret;
 }
 /*
@@ -690,7 +690,7 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	__u8 eir, OldMessageCount;
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.fir_base;
 	
@@ -703,10 +703,10 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
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
@@ -717,7 +717,7 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	{		
 		if (self->io.direction == IO_XMIT) /* TX */
 		{
-			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Tx) *******\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ******* IIR_EOM (Tx) *******\n", __func__);
 			
 			if(ali_ircc_dma_xmit_complete(self))
 			{
@@ -736,23 +736,23 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
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
@@ -765,7 +765,7 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 		if(OldMessageCount > ((self->LineStatus+1) & 0x07))
 		{
 			self->rcvFramesOverflow = TRUE;	
-			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******* \n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), ******* self->rcvFramesOverflow = TRUE ******* \n", __func__);
 		}
 		/* Disable Timer */
 		switch_bank(iobase, BANK1);
@@ -797,7 +797,7 @@ static irqreturn_t ali_ircc_fir_interrupt(struct ali_ircc_cb *self)
 	/* Restore Interrupt */	
 	SetCOMInterrupts(self, TRUE);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ---------------\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s(), ----------------- End ---------------\n", __func__);
 	return IRQ_RETVAL(eir);
 }
 
@@ -812,7 +812,7 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
 	int iobase;
 	int iir, lsr;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	
 	iobase = self->io.sir_base;
 
@@ -821,13 +821,13 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
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
@@ -841,14 +841,14 @@ static irqreturn_t ali_ircc_sir_interrupt(struct ali_ircc_cb *self)
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
@@ -865,7 +865,7 @@ static void ali_ircc_sir_receive(struct ali_ircc_cb *self)
 	int boguscount = 0;
 	int iobase;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	iobase = self->io.sir_base;
@@ -880,12 +880,12 @@ static void ali_ircc_sir_receive(struct ali_ircc_cb *self)
 
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
@@ -902,7 +902,7 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	iobase = self->io.sir_base;
 
@@ -921,16 +921,16 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
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
@@ -948,7 +948,7 @@ static void ali_ircc_sir_write_wakeup(struct ali_ircc_cb *self)
 		outb(UART_IER_RDI, iobase+UART_IER);
 	}
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 }
 
 static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
@@ -956,9 +956,9 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 	struct net_device *dev = self->netdev;
 	int iobase;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(2, "%s(), setting speed = %d \n", __FUNCTION__ , baud);
+	IRDA_DEBUG(2, "%s(), setting speed = %d \n", __func__ , baud);
 	
 	/* This function *must* be called with irq off and spin-lock.
 	 * - Jean II */
@@ -997,7 +997,7 @@ static void ali_ircc_change_speed(struct ali_ircc_cb *self, __u32 baud)
 		
 	netif_wake_queue(self->netdev);	
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 }
 
 static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
@@ -1007,14 +1007,14 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
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
@@ -1028,7 +1028,7 @@ static void ali_ircc_fir_change_speed(struct ali_ircc_cb *priv, __u32 baud)
 	// Set Dongle Speed mode
 	ali_ircc_change_dongle_speed(self, baud);
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 }
 
 /*
@@ -1046,9 +1046,9 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ---------------- Start ----------------\n", __func__ );
 	
-	IRDA_DEBUG(1, "%s(), Setting speed to: %d\n", __FUNCTION__ , speed);
+	IRDA_DEBUG(1, "%s(), Setting speed to: %d\n", __func__ , speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1102,7 +1102,7 @@ static void ali_ircc_sir_change_speed(struct ali_ircc_cb *priv, __u32 speed)
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 }
 
 static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
@@ -1112,14 +1112,14 @@ static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
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
@@ -1283,7 +1283,7 @@ static void ali_ircc_change_dongle_speed(struct ali_ircc_cb *priv, int speed)
 			
 	switch_bank(iobase, BANK0);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );		
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );		
 }
 
 /*
@@ -1296,11 +1296,11 @@ static int ali_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
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
         
@@ -1312,7 +1312,7 @@ static int ali_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
 		actual++;
 	}
 	
-        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+        IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	return actual;
 }
 
@@ -1328,7 +1328,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 	int iobase;
 	char hwname[32];
 		
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
@@ -1374,7 +1374,7 @@ static int ali_ircc_net_open(struct net_device *dev)
 	 */
 	self->irlap = irlap_open(dev, &self->qos, hwname);
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	
 	return 0;
 }
@@ -1391,7 +1391,7 @@ static int ali_ircc_net_close(struct net_device *dev)
 	struct ali_ircc_cb *self;
 	//int iobase;
 			
-	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s(), ---------------- Start ----------------\n", __func__ );
 		
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -1414,7 +1414,7 @@ static int ali_ircc_net_close(struct net_device *dev)
 	free_irq(self->io.irq, dev);
 	free_dma(self->io.dma);
 
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	
 	return 0;
 }
@@ -1433,7 +1433,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	__u32 speed;
 	int mtt, diff;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );	
 	
 	self = (struct ali_ircc_cb *) dev->priv;
 	iobase = self->io.fir_base;
@@ -1487,7 +1487,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			diff = self->now.tv_usec - self->stamp.tv_usec;
 			/* self->stamp is set from ali_ircc_dma_receive_complete() */
 							
-			IRDA_DEBUG(1, "%s(), ******* diff = %d ******* \n", __FUNCTION__ , diff);	
+			IRDA_DEBUG(1, "%s(), ******* diff = %d ******* \n", __func__ , diff);	
 			
 			if (diff < 0) 
 				diff += 1000000;
@@ -1509,7 +1509,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 					/* Adjust for timer resolution */
 					mtt = (mtt+250) / 500; 	/* 4 discard, 5 get advanced, Let's round off */
 					
-					IRDA_DEBUG(1, "%s(), ************** mtt = %d ***********\n", __FUNCTION__ , mtt);	
+					IRDA_DEBUG(1, "%s(), ************** mtt = %d ***********\n", __func__ , mtt);	
 					
 					/* Setup timer */
 					if (mtt == 1) /* 500 us */
@@ -1566,7 +1566,7 @@ static int ali_ircc_fir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&self->lock, flags);
 	dev_kfree_skb(skb);
 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 	return 0;	
 }
 
@@ -1577,7 +1577,7 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	unsigned char FIFO_OPTI, Hi, Lo;
 	
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );	
 	
 	iobase = self->io.fir_base;
 	
@@ -1628,7 +1628,7 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	tmp = inb(iobase+FIR_LCR_B);
 	tmp &= ~0x20; // Disable SIP
 	outb(((unsigned char)(tmp & 0x3f) | LCR_B_TX_MODE) & ~LCR_B_BW, iobase+FIR_LCR_B);
-	IRDA_DEBUG(1, "%s(), ******* Change to TX mode: FIR_LCR_B = 0x%x ******* \n", __FUNCTION__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), ******* Change to TX mode: FIR_LCR_B = 0x%x ******* \n", __func__ , inb(iobase+FIR_LCR_B));
 	
 	outb(0, iobase+FIR_LSR);
 			
@@ -1638,7 +1638,7 @@ static void ali_ircc_dma_xmit(struct ali_ircc_cb *self)
 	
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
@@ -1646,7 +1646,7 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 	int iobase;
 	int ret = TRUE;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );	
 	
 	iobase = self->io.fir_base;
 	
@@ -1659,7 +1659,7 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 	if((inb(iobase+FIR_LSR) & LSR_FRAME_ABORT) == LSR_FRAME_ABORT)
 	
 	{
-		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __FUNCTION__);	
+		IRDA_ERROR("%s(), ********* LSR_FRAME_ABORT *********\n", __func__);	
 		self->stats.tx_errors++;
 		self->stats.tx_fifo_errors++;		
 	}
@@ -1702,7 +1702,7 @@ static int  ali_ircc_dma_xmit_complete(struct ali_ircc_cb *self)
 		
 	switch_bank(iobase, BANK0); 
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 	return ret;
 }
 
@@ -1717,7 +1717,7 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 {
 	int iobase, tmp;
 	
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );	
 	
 	iobase = self->io.fir_base;
 	
@@ -1755,7 +1755,7 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 	//switch_bank(iobase, BANK0);
 	tmp = inb(iobase+FIR_LCR_B);
 	outb((unsigned char)(tmp &0x3f) | LCR_B_RX_MODE | LCR_B_BW , iobase + FIR_LCR_B); // 2000/12/1 05:16PM
-	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x *** \n", __FUNCTION__ , inb(iobase+FIR_LCR_B));
+	IRDA_DEBUG(1, "%s(), *** Change To RX mode: FIR_LCR_B = 0x%x *** \n", __func__ , inb(iobase+FIR_LCR_B));
 			
 	/* Set Rx Threshold */
 	switch_bank(iobase, BANK1);
@@ -1767,7 +1767,7 @@ static int ali_ircc_dma_receive(struct ali_ircc_cb *self)
 	outb(CR_DMA_EN | CR_DMA_BURST, iobase+FIR_CR);
 				
 	switch_bank(iobase, BANK0); 
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 	return 0;
 }
 
@@ -1778,7 +1778,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	__u8 status, MessageCount;
 	int len, i, iobase, val;	
 
-	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ---------------- Start -----------------\n", __func__ );	
 
 	st_fifo = &self->st_fifo;		
 	iobase = self->io.fir_base;	
@@ -1787,7 +1787,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	MessageCount = inb(iobase+ FIR_LSR)&0x07;
 	
 	if (MessageCount > 0)	
-		IRDA_DEBUG(0, "%s(), Messsage count = %d,\n", __FUNCTION__ , MessageCount);	
+		IRDA_DEBUG(0, "%s(), Messsage count = %d,\n", __func__ , MessageCount);	
 		
 	for (i=0; i<=MessageCount; i++)
 	{
@@ -1800,11 +1800,11 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
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
 			
@@ -1827,7 +1827,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 		/* Check for errors */
 		if ((status & 0xd8) || self->rcvFramesOverflow || (len==0)) 		
 		{
-			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __FUNCTION__ );	
+			IRDA_DEBUG(0,"%s(), ************* RX Errors ************ \n", __func__ );	
 			
 			/* Skip frame */
 			self->stats.rx_errors++;
@@ -1837,29 +1837,29 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
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
@@ -1871,7 +1871,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 				val = inb(iobase+FIR_BSR);	
 				if ((val& BSR_FIFO_NOT_EMPTY)== 0x80) 
 				{
-					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************ \n", __FUNCTION__ );
+					IRDA_DEBUG(0, "%s(), ************* BSR_FIFO_NOT_EMPTY ************ \n", __func__ );
 					
 					/* Put this entry back in fifo */
 					st_fifo->head--;
@@ -1908,7 +1908,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 			{
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
-					     __FUNCTION__);
+					     __func__);
 				self->stats.rx_dropped++;
 
 				return FALSE;
@@ -1936,7 +1936,7 @@ static int  ali_ircc_dma_receive_complete(struct ali_ircc_cb *self)
 	
 	switch_bank(iobase, BANK0);	
 		
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );	
 	return TRUE;
 }
 
@@ -1955,7 +1955,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 	int iobase;
 	__u32 speed;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return 0;);
 	
@@ -2004,7 +2004,7 @@ static int ali_ircc_sir_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev_kfree_skb(skb);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	
 	return 0;	
 }
@@ -2023,7 +2023,7 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	unsigned long flags;
 	int ret = 0;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2031,11 +2031,11 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
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
@@ -2049,13 +2049,13 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -2063,7 +2063,7 @@ static int ali_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 		ret = -EOPNOTSUPP;
 	}
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	
 	return ret;
 }
@@ -2080,7 +2080,7 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 	int status = FALSE;
 	int iobase;		
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start -----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start -----------------\n", __func__ );
 	
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
@@ -2094,7 +2094,7 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 		if((inb(iobase+FIR_FIFO_FR) & 0x3f) != 0) 		
 		{
 			/* We are receiving something */
-			IRDA_DEBUG(1, "%s(), We are receiving something\n", __FUNCTION__ );
+			IRDA_DEBUG(1, "%s(), We are receiving something\n", __func__ );
 			status = TRUE;
 		}
 		switch_bank(iobase, BANK0);		
@@ -2106,7 +2106,7 @@ static int ali_ircc_is_receiving(struct ali_ircc_cb *self)
 	
 	spin_unlock_irqrestore(&self->lock, flags);
 	
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );
 	
 	return status;
 }
@@ -2115,9 +2115,9 @@ static struct net_device_stats *ali_ircc_net_get_stats(struct net_device *dev)
 {
 	struct ali_ircc_cb *self = (struct ali_ircc_cb *) dev->priv;
 	
-	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __FUNCTION__ );
+	IRDA_DEBUG(2, "%s(), ---------------- Start ----------------\n", __func__ );
 		
-	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __FUNCTION__ );	
+	IRDA_DEBUG(2, "%s(), ----------------- End ------------------\n", __func__ );	
 	
 	return &self->stats;
 }
@@ -2163,7 +2163,7 @@ static void SetCOMInterrupts(struct ali_ircc_cb *self , unsigned char enable)
 	
 	int iobase = self->io.fir_base; /* or sir_base */
 
-	IRDA_DEBUG(2, "%s(), -------- Start -------- ( Enable = %d )\n", __FUNCTION__ , enable);	
+	IRDA_DEBUG(2, "%s(), -------- Start -------- ( Enable = %d )\n", __func__ , enable);	
 	
 	/* Enable the interrupt which we wish to */
 	if (enable){
@@ -2204,14 +2204,14 @@ static void SetCOMInterrupts(struct ali_ircc_cb *self , unsigned char enable)
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
@@ -2227,14 +2227,14 @@ static void SIR2FIR(int iobase)
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
@@ -2250,7 +2250,7 @@ static void FIR2SIR(int iobase)
 	val = inb(iobase+UART_LSR);
 	val = inb(iobase+UART_MSR);
 	
-	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __FUNCTION__ );
+	IRDA_DEBUG(1, "%s(), ----------------- End ------------------\n", __func__ );
 }
 
 MODULE_AUTHOR("Benjamin Kong <benjamin_kong@ali.com.tw>");
diff --git a/drivers/net/irda/donauboe.c b/drivers/net/irda/donauboe.c
index 1257e1a..8dae6bd 100644
--- a/drivers/net/irda/donauboe.c
+++ b/drivers/net/irda/donauboe.c
@@ -249,7 +249,7 @@ toshoboe_dumpregs (struct toshoboe_cb *self)
 {
   __u32 ringbase;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   ringbase = INB (OBOE_RING_BASE0) << 10;
   ringbase |= INB (OBOE_RING_BASE1) << 18;
@@ -297,7 +297,7 @@ static void
 toshoboe_disablebm (struct toshoboe_cb *self)
 {
   __u8 command;
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   pci_read_config_byte (self->pdev, PCI_COMMAND, &command);
   command &= ~PCI_COMMAND_MASTER;
@@ -309,7 +309,7 @@ toshoboe_disablebm (struct toshoboe_cb *self)
 static void
 toshoboe_stopchip (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   /*Disable interrupts */
   OUTB (0x0, OBOE_IER);
@@ -354,7 +354,7 @@ toshoboe_setbaud (struct toshoboe_cb *self)
   __u16 pconfig = 0;
   __u8 config0l = 0;
 
-  IRDA_DEBUG (2, "%s(%d/%d)\n", __FUNCTION__, self->speed, self->io.speed);
+  IRDA_DEBUG (2, "%s(%d/%d)\n", __func__, self->speed, self->io.speed);
 
   switch (self->speed)
     {
@@ -486,7 +486,7 @@ toshoboe_setbaud (struct toshoboe_cb *self)
 static void
 toshoboe_enablebm (struct toshoboe_cb *self)
 {
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
   pci_set_master (self->pdev);
 }
 
@@ -496,7 +496,7 @@ toshoboe_initring (struct toshoboe_cb *self)
 {
   int i;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   for (i = 0; i < TX_SLOTS; ++i)
     {
@@ -554,7 +554,7 @@ toshoboe_startchip (struct toshoboe_cb *self)
 {
   __u32 physaddr;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   toshoboe_initring (self);
   toshoboe_enablebm (self);
@@ -828,7 +828,7 @@ toshoboe_probe (struct toshoboe_cb *self)
 #endif
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (request_irq (self->io.irq, toshoboe_probeinterrupt,
                    self->io.irqflags, "toshoboe", (void *) self))
@@ -987,10 +987,10 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
 
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
@@ -1019,7 +1019,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
         {
           self->new_speed = speed;
           IRDA_DEBUG (1, "%s: Queued TxDone scheduled speed change %d\n" ,
-		      __FUNCTION__, speed);
+		      __func__, speed);
           /* if no data, that's all! */
           if (!skb->len)
             {
@@ -1061,7 +1061,7 @@ toshoboe_hard_xmit (struct sk_buff *skb, struct net_device *dev)
       /* which we will add a wrong checksum to */
 
       mtt = toshoboe_makemttpacket (self, self->tx_bufs[self->txs], mtt);
-      IRDA_DEBUG (1, "%s.mtt:%x(%x)%d\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.mtt:%x(%x)%d\n", __func__
           ,skb->len,mtt,self->txpending);
       if (mtt)
         {
@@ -1105,7 +1105,7 @@ dumpbufs(skb->data,skb->len,'>');
 
   if (self->ring->tx[self->txs].control & OBOE_CTL_TX_HW_OWNS)
     {
-      IRDA_DEBUG (0, "%s.ful:%x(%x)%x\n", __FUNCTION__
+      IRDA_DEBUG (0, "%s.ful:%x(%x)%x\n", __func__
           ,skb->len, self->ring->tx[self->txs].control, self->txpending);
       toshoboe_start_DMA(self, OBOE_CONFIG0H_ENTX);
       spin_unlock_irqrestore(&self->spinlock, flags);
@@ -1183,7 +1183,7 @@ toshoboe_interrupt (int irq, void *dev_id)
           if (self->ring->tx[i].control & OBOE_CTL_TX_HW_OWNS)
               self->txpending++;
         }
-      IRDA_DEBUG (1, "%s.txd(%x)%x/%x\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.txd(%x)%x/%x\n", __func__
           ,irqstat,txp,self->txpending);
 
       txp = INB (OBOE_TXSLOT) & OBOE_SLOT_MASK;
@@ -1213,7 +1213,7 @@ toshoboe_interrupt (int irq, void *dev_id)
         {
           self->speed = self->new_speed;
           IRDA_DEBUG (1, "%s: Executed TxDone scheduled speed change %d\n",
-		      __FUNCTION__, self->speed);
+		      __func__, self->speed);
           toshoboe_setbaud (self);
         }
 
@@ -1228,7 +1228,7 @@ toshoboe_interrupt (int irq, void *dev_id)
         {
           int len = self->ring->rx[self->rxs].len;
           skb = NULL;
-          IRDA_DEBUG (3, "%s.rcv:%x(%x)\n", __FUNCTION__
+          IRDA_DEBUG (3, "%s.rcv:%x(%x)\n", __func__
 		      ,len,self->ring->rx[self->rxs].control);
 
 #ifdef DUMP_PACKETS
@@ -1250,7 +1250,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (1, "%s.SIR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (1, "%s.SIR:%x(%x)\n", __func__, len,enable);
                 }
 
 #ifdef USE_MIR
@@ -1260,7 +1260,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                       len -= 2;
                   else
                       len = 0;
-                  IRDA_DEBUG (2, "%s.MIR:%x(%x)\n", __FUNCTION__, len,enable);
+                  IRDA_DEBUG (2, "%s.MIR:%x(%x)\n", __func__, len,enable);
                 }
 #endif
               else if (enable & OBOE_ENABLEH_FIRON)
@@ -1269,10 +1269,10 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
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
@@ -1293,7 +1293,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
                     {
                       printk (KERN_INFO
                               "%s(), memory squeeze, dropping frame.\n",
-			      __FUNCTION__);
+			      __func__);
                     }
                 }
             }
@@ -1305,7 +1305,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
             /* (SIR) data is splitted in several slots. */
             /* we have to join all the received buffers received */
             /*in a large buffer before checking CRC. */
-            IRDA_DEBUG (0, "%s.err:%x(%x)\n", __FUNCTION__
+            IRDA_DEBUG (0, "%s.err:%x(%x)\n", __func__
                 ,len,self->ring->rx[self->rxs].control);
             }
 
@@ -1333,7 +1333,7 @@ dumpbufs(self->rx_bufs[self->rxs],len,'<');
   if (irqstat & OBOE_INT_SIP)
     {
       self->int_sip++;
-      IRDA_DEBUG (1, "%s.sip:%x(%x)%x\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s.sip:%x(%x)%x\n", __func__
 	      ,self->int_sip,irqstat,self->txpending);
     }
   return IRQ_HANDLED;
@@ -1347,7 +1347,7 @@ toshoboe_net_open (struct net_device *dev)
   unsigned long flags;
   int rc;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   self = netdev_priv(dev);
 
@@ -1385,7 +1385,7 @@ toshoboe_net_close (struct net_device *dev)
 {
   struct toshoboe_cb *self;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (dev != NULL, return -1; );
   self = (struct toshoboe_cb *) dev->priv;
@@ -1430,7 +1430,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 
   IRDA_ASSERT (self != NULL, return -1; );
 
-  IRDA_DEBUG (5, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+  IRDA_DEBUG (5, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
   /* Disable interrupts & save flags */
   spin_lock_irqsave(&self->spinlock, flags);
@@ -1442,7 +1442,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
        * speed, so we still must allow for speed change within
        * interrupt context.
        */
-      IRDA_DEBUG (1, "%s(BANDWIDTH), %s, (%X/%ld\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s(BANDWIDTH), %s, (%X/%ld\n", __func__
           ,dev->name, INB (OBOE_STATUS), irq->ifr_baudrate );
       if (!in_interrupt () && !capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
@@ -1455,7 +1455,7 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
       self->new_speed = irq->ifr_baudrate;
       break;
     case SIOCSMEDIABUSY:       /* Set media busy */
-      IRDA_DEBUG (1, "%s(MEDIABUSY), %s, (%X/%x)\n", __FUNCTION__
+      IRDA_DEBUG (1, "%s(MEDIABUSY), %s, (%X/%x)\n", __func__
           ,dev->name, INB (OBOE_STATUS), capable (CAP_NET_ADMIN) );
       if (!capable (CAP_NET_ADMIN)) {
 	ret = -EPERM;
@@ -1465,11 +1465,11 @@ toshoboe_net_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
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
@@ -1496,7 +1496,7 @@ toshoboe_close (struct pci_dev *pci_dev)
   int i;
   struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   IRDA_ASSERT (self != NULL, return; );
 
@@ -1537,7 +1537,7 @@ toshoboe_open (struct pci_dev *pci_dev, const struct pci_device_id *pdid)
   int ok = 0;
   int err;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if ((err=pci_enable_device(pci_dev)))
     return err;
@@ -1704,7 +1704,7 @@ toshoboe_gotosleep (struct pci_dev *pci_dev, pm_message_t crap)
   unsigned long flags;
   int i = 10;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (!self || self->stopped)
     return 0;
@@ -1732,7 +1732,7 @@ toshoboe_wakeup (struct pci_dev *pci_dev)
   struct toshoboe_cb *self = (struct toshoboe_cb*)pci_get_drvdata(pci_dev);
   unsigned long flags;
 
-  IRDA_DEBUG (4, "%s()\n", __FUNCTION__);
+  IRDA_DEBUG (4, "%s()\n", __func__);
 
   if (!self || !self->stopped)
     return 0;
diff --git a/drivers/net/irda/girbil-sir.c b/drivers/net/irda/girbil-sir.c
index 738531b..a31b8fa 100644
--- a/drivers/net/irda/girbil-sir.c
+++ b/drivers/net/irda/girbil-sir.c
@@ -86,7 +86,7 @@ static int girbil_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -102,7 +102,7 @@ static int girbil_open(struct sir_dev *dev)
 
 static int girbil_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -126,7 +126,7 @@ static int girbil_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* dongle alread reset - port and dongle at default speed */
 
@@ -179,7 +179,7 @@ static int girbil_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -209,7 +209,7 @@ static int girbil_reset(struct sir_dev *dev)
 	u8 control = GIRBIL_TXEN | GIRBIL_RXEN;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -241,7 +241,7 @@ static int girbil_reset(struct sir_dev *dev)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
 		ret = -1;
 		break;
 	}
diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index 9081234..96c2fda 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -177,12 +177,12 @@ static void irda_usb_build_header(struct irda_usb_cb *self,
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
@@ -228,7 +228,7 @@ static void irda_usb_build_header(struct irda_usb_cb *self,
 	
 	/* Set the negotiated additional XBOFS */
 	if (self->new_xbofs != -1) {
-		IRDA_DEBUG(2, "%s(), changing xbofs to %d\n", __FUNCTION__, self->new_xbofs);
+		IRDA_DEBUG(2, "%s(), changing xbofs to %d\n", __func__, self->new_xbofs);
 		self->xbofs = self->new_xbofs;
 		/* We will do ` self->new_xbofs = -1; ' in the completion
 		 * handler just in case the current URB fail - Jean II */
@@ -302,13 +302,13 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
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
 
@@ -334,7 +334,7 @@ static void irda_usb_change_speed_xbofs(struct irda_usb_cb *self)
 
 	/* Irq disabled -> GFP_ATOMIC */
 	if ((ret = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Speed URB\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed Speed URB\n", __func__);
 	}
 }
 
@@ -347,7 +347,7 @@ static void speed_bulk_callback(struct urb *urb)
 {
 	struct irda_usb_cb *self = urb->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
@@ -357,7 +357,7 @@ static void speed_bulk_callback(struct urb *urb)
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __FUNCTION__, urb->status, urb->transfer_flags);
+		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer.
 		 * Instead, we will wait for irda_usb_net_timeout(), the
@@ -392,7 +392,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	int res, mtt;
 	int	err = 1;	/* Failed */
 
-	IRDA_DEBUG(4, "%s() on %s\n", __FUNCTION__, netdev->name);
+	IRDA_DEBUG(4, "%s() on %s\n", __func__, netdev->name);
 
 	netif_stop_queue(netdev);
 
@@ -403,7 +403,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	 * We need to check self->present under the spinlock because
 	 * of irda_usb_disconnect() is synchronous - Jean II */
 	if (!self->present) {
-		IRDA_DEBUG(0, "%s(), Device is gone...\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Device is gone...\n", __func__);
 		goto drop;
 	}
 
@@ -437,7 +437,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	}
 
 	if (urb->status != 0) {
-		IRDA_WARNING("%s(), URB still in use!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), URB still in use!\n", __func__);
 		goto drop;
 	}
 
@@ -524,7 +524,7 @@ static int irda_usb_hard_xmit(struct sk_buff *skb, struct net_device *netdev)
 	
 	/* Ask USB to send the packet - Irq disabled -> GFP_ATOMIC */
 	if ((res = usb_submit_urb(urb, GFP_ATOMIC))) {
-		IRDA_WARNING("%s(), failed Tx URB\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed Tx URB\n", __func__);
 		self->stats.tx_errors++;
 		/* Let USB recover : We will catch that in the watchdog */
 		/*netif_start_queue(netdev);*/
@@ -556,7 +556,7 @@ static void write_bulk_callback(struct urb *urb)
 	struct sk_buff *skb = urb->context;
 	struct irda_usb_cb *self = ((struct irda_skb_cb *) skb->cb)->context;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* We should always have a context */
 	IRDA_ASSERT(self != NULL, return;);
@@ -570,7 +570,7 @@ static void write_bulk_callback(struct urb *urb)
 	/* Check for timeout and other USB nasties */
 	if (urb->status != 0) {
 		/* I get a lot of -ECONNABORTED = -103 here - Jean II */
-		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __FUNCTION__, urb->status, urb->transfer_flags);
+		IRDA_DEBUG(0, "%s(), URB complete status %d, transfer_flags 0x%04X\n", __func__, urb->status, urb->transfer_flags);
 
 		/* Don't do anything here, that might confuse the USB layer,
 		 * and we could go in recursion and blow the kernel stack...
@@ -589,7 +589,7 @@ static void write_bulk_callback(struct urb *urb)
 
 	/* If the network is closed, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone...\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Network is gone...\n", __func__);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
 	}
@@ -600,7 +600,7 @@ static void write_bulk_callback(struct urb *urb)
 		    (self->new_xbofs != self->xbofs)) {
 			/* We haven't changed speed yet (because of
 			 * IUC_SPEED_BUG), so do it now - Jean II */
-			IRDA_DEBUG(1, "%s(), Changing speed now...\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), Changing speed now...\n", __func__);
 			irda_usb_change_speed_xbofs(self);
 		} else {
 			/* New speed and xbof is now commited in hardware */
@@ -632,7 +632,7 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 	struct urb *urb;
 	int	done = 0;	/* If we have made any progress */
 
-	IRDA_DEBUG(0, "%s(), Network layer thinks we timed out!\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), Network layer thinks we timed out!\n", __func__);
 	IRDA_ASSERT(self != NULL, return;);
 
 	/* Protect us from USB callbacks, net Tx and else. */
@@ -640,7 +640,7 @@ static void irda_usb_net_timeout(struct net_device *netdev)
 
 	/* self->present *MUST* be read under spinlock */
 	if (!self->present) {
-		IRDA_WARNING("%s(), device not present!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), device not present!\n", __func__);
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&self->lock, flags);
 		return;
@@ -763,7 +763,7 @@ static void irda_usb_submit(struct irda_usb_cb *self, struct sk_buff *skb, struc
 	struct irda_skb_cb *cb;
 	int ret;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* This should never happen */
 	IRDA_ASSERT(skb != NULL, return;);
@@ -786,7 +786,7 @@ static void irda_usb_submit(struct irda_usb_cb *self, struct sk_buff *skb, struc
 		/* If this ever happen, we are in deep s***.
 		 * Basically, the Rx path will stop... */
 		IRDA_WARNING("%s(), Failed to submit Rx URB %d\n",
-			     __FUNCTION__, ret);
+			     __func__, ret);
 	}
 }
 
@@ -807,7 +807,7 @@ static void irda_usb_receive(struct urb *urb)
 	struct urb *next_urb;
 	unsigned int len, docopy;
 
-	IRDA_DEBUG(2, "%s(), len=%d\n", __FUNCTION__, urb->actual_length);
+	IRDA_DEBUG(2, "%s(), len=%d\n", __func__, urb->actual_length);
 	
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
@@ -817,7 +817,7 @@ static void irda_usb_receive(struct urb *urb)
 
 	/* If the network is closed or the device gone, stop everything */
 	if ((!self->netopen) || (!self->present)) {
-		IRDA_DEBUG(0, "%s(), Network is gone!\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(), Network is gone!\n", __func__);
 		/* Don't re-submit the URB : will stall the Rx path */
 		return;
 	}
@@ -840,7 +840,7 @@ static void irda_usb_receive(struct urb *urb)
 			/* Usually precursor to a hot-unplug on OHCI. */
 		default:
 			self->stats.rx_errors++;
-			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X \n", __FUNCTION__, urb->status, urb->transfer_flags);
+			IRDA_DEBUG(0, "%s(), RX status %d, transfer_flags 0x%04X \n", __func__, urb->status, urb->transfer_flags);
 			break;
 		}
 		/* If we received an error, we don't want to resubmit the
@@ -861,7 +861,7 @@ static void irda_usb_receive(struct urb *urb)
 	
 	/* Check for empty frames */
 	if (urb->actual_length <= self->header_length) {
-		IRDA_WARNING("%s(), empty frame!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), empty frame!\n", __func__);
 		goto done;
 	}
 
@@ -967,7 +967,7 @@ static void irda_usb_rx_defer_expired(unsigned long data)
 	struct irda_skb_cb *cb;
 	struct urb *next_urb;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Find ourselves */
 	cb = (struct irda_skb_cb *) skb->cb;
@@ -1053,7 +1053,7 @@ static int stir421x_fw_upload(struct irda_usb_cb *self,
 				   patch_block, block_size,
 				   &actual_len, msecs_to_jiffies(500));
 		IRDA_DEBUG(3,"%s(): Bulk send %u bytes, ret=%d\n",
-			   __FUNCTION__, actual_len, ret);
+			   __func__, actual_len, ret);
 
 		if (ret < 0)
 			break;
@@ -1092,7 +1092,7 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
 
         /* We get a patch from userspace */
         IRDA_MESSAGE("%s(): Received firmware %s (%zu bytes)\n",
-                     __FUNCTION__, stir421x_fw_name, fw->size);
+                     __func__, stir421x_fw_name, fw->size);
 
         ret = -EINVAL;
 
@@ -1116,7 +1116,7 @@ static int stir421x_patch_device(struct irda_usb_cb *self)
 				+ (build % 10);
 
 			IRDA_DEBUG(3, "%s(): Firmware Product version %ld\n",
-                                   __FUNCTION__, fw_version);
+                                   __func__, fw_version);
                 }
         }
 
@@ -1172,7 +1172,7 @@ static int irda_usb_net_open(struct net_device *netdev)
 	char	hwname[16];
 	int i;
 	
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = (struct irda_usb_cb *) netdev->priv;
@@ -1182,13 +1182,13 @@ static int irda_usb_net_open(struct net_device *netdev)
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
 
@@ -1231,7 +1231,7 @@ static int irda_usb_net_open(struct net_device *netdev)
 			/* If this ever happen, we are in deep s***.
 			 * Basically, we can't start the Rx path... */
 			IRDA_WARNING("%s(), Failed to allocate Rx skb\n",
-				     __FUNCTION__);
+				     __func__);
 			return -1;
 		}
 		//skb_reserve(newskb, USB_IRDA_HEADER - 1);
@@ -1254,7 +1254,7 @@ static int irda_usb_net_close(struct net_device *netdev)
 	struct irda_usb_cb *self;
 	int	i;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(netdev != NULL, return -1;);
 	self = (struct irda_usb_cb *) netdev->priv;
@@ -1309,7 +1309,7 @@ static int irda_usb_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 	self = dev->priv;
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -1367,7 +1367,7 @@ static inline void irda_usb_init_qos(struct irda_usb_cb *self)
 {
 	struct irda_class_desc *desc;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 	
 	desc = self->irda_desc;
 	
@@ -1384,7 +1384,7 @@ static inline void irda_usb_init_qos(struct irda_usb_cb *self)
 	self->qos.data_size.bits       = desc->bmDataSize;
 
 	IRDA_DEBUG(0, "%s(), dongle says speed=0x%X, size=0x%X, window=0x%X, bofs=0x%X, turn=0x%X\n", 
-		__FUNCTION__, self->qos.baud_rate.bits, self->qos.data_size.bits, self->qos.window_size.bits, self->qos.additional_bofs.bits, self->qos.min_turn_time.bits);
+		__func__, self->qos.baud_rate.bits, self->qos.data_size.bits, self->qos.window_size.bits, self->qos.additional_bofs.bits, self->qos.min_turn_time.bits);
 
 	/* Don't always trust what the dongle tell us */
 	if(self->capability & IUC_SIR_ONLY)
@@ -1419,7 +1419,7 @@ static inline int irda_usb_open(struct irda_usb_cb *self)
 {
 	struct net_device *netdev = self->netdev;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	irda_usb_init_qos(self);
 
@@ -1442,7 +1442,7 @@ static inline int irda_usb_open(struct irda_usb_cb *self)
  */
 static inline void irda_usb_close(struct irda_usb_cb *self)
 {
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	/* Remove netdevice */
 	unregister_netdev(self->netdev);
@@ -1515,13 +1515,13 @@ static inline int irda_usb_parse_endpoints(struct irda_usb_cb *self, struct usb_
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
@@ -1583,7 +1583,7 @@ static inline struct irda_class_desc *irda_usb_find_class_desc(struct usb_interf
 		0, intf->altsetting->desc.bInterfaceNumber, desc,
 		sizeof(*desc), 500);
 	
-	IRDA_DEBUG(1, "%s(), ret=%d\n", __FUNCTION__, ret);
+	IRDA_DEBUG(1, "%s(), ret=%d\n", __func__, ret);
 	if (ret < sizeof(*desc)) {
 		IRDA_WARNING("usb-irda: class_descriptor read %s (%d)\n",
 			     (ret<0) ? "failed" : "too short", ret);
@@ -1696,10 +1696,10 @@ static int irda_usb_probe(struct usb_interface *intf,
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
@@ -1708,7 +1708,7 @@ static int irda_usb_probe(struct usb_interface *intf,
 	interface = intf->cur_altsetting;
 	if(!irda_usb_parse_endpoints(self, interface->endpoint,
 				     interface->desc.bNumEndpoints)) {
-		IRDA_ERROR("%s(), Bogus endpoints...\n", __FUNCTION__);
+		IRDA_ERROR("%s(), Bogus endpoints...\n", __func__);
 		ret = -EIO;
 		goto err_out_3;
 	}
@@ -1815,7 +1815,7 @@ static void irda_usb_disconnect(struct usb_interface *intf)
 	struct irda_usb_cb *self = usb_get_intfdata(intf);
 	int i;
 
-	IRDA_DEBUG(1, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	usb_set_intfdata(intf, NULL);
 	if (!self)
@@ -1865,7 +1865,7 @@ static void irda_usb_disconnect(struct usb_interface *intf)
 
 	/* Free self and network device */
 	free_netdev(self->netdev);
-	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s(), USB IrDA Disconnected\n", __func__);
 }
 
 /*------------------------------------------------------------------*/
diff --git a/drivers/net/irda/irtty-sir.c b/drivers/net/irda/irtty-sir.c
index fc753d7..51fd902 100644
--- a/drivers/net/irda/irtty-sir.c
+++ b/drivers/net/irda/irtty-sir.c
@@ -131,7 +131,7 @@ static int irtty_change_speed(struct sir_dev *dev, unsigned speed)
 
 	cflag &= ~CBAUD;
 
-	IRDA_DEBUG(2, "%s(), Setting speed to %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(2, "%s(), Setting speed to %d\n", __func__, speed);
 
 	switch (speed) {
 	case 1200:
@@ -271,7 +271,7 @@ static void irtty_receive_buf(struct tty_struct *tty, const unsigned char *cp,
 
 	dev = priv->dev;
 	if (!dev) {
-		IRDA_WARNING("%s(), not ready yet!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), not ready yet!\n", __func__);
 		return;
 	}
 
@@ -428,7 +428,7 @@ static int irtty_ioctl(struct tty_struct *tty, struct file *file, unsigned int c
 	IRDA_ASSERT(priv != NULL, return -ENODEV;);
 	IRDA_ASSERT(priv->magic == IRTTY_MAGIC, return -EBADR;);
 
-	IRDA_DEBUG(3, "%s(cmd=0x%X)\n", __FUNCTION__, cmd);
+	IRDA_DEBUG(3, "%s(cmd=0x%X)\n", __func__, cmd);
 
 	dev = priv->dev;
 	IRDA_ASSERT(dev != NULL, return -1;);
@@ -517,7 +517,7 @@ static int irtty_open(struct tty_struct *tty)
 
 	mutex_unlock(&irtty_mutex);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline opened\n", __FUNCTION__, tty->name);
+	IRDA_DEBUG(0, "%s - %s: irda line discipline opened\n", __func__, tty->name);
 
 	return 0;
 
@@ -569,7 +569,7 @@ static void irtty_close(struct tty_struct *tty)
 
 	kfree(priv);
 
-	IRDA_DEBUG(0, "%s - %s: irda line discipline closed\n", __FUNCTION__, tty->name);
+	IRDA_DEBUG(0, "%s - %s: irda line discipline closed\n", __func__, tty->name);
 }
 
 /* ------------------------------------------------------- */
@@ -607,7 +607,7 @@ static void __exit irtty_sir_cleanup(void)
 
 	if ((err = tty_unregister_ldisc(N_IRDA))) {
 		IRDA_ERROR("%s(), can't unregister line discipline (err = %d)\n",
-			   __FUNCTION__, err);
+			   __func__, err);
 	}
 }
 
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 648e54b..73fe83b 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -243,7 +243,7 @@ static void kingsun_rcv_irq(struct urb *urb)
 		}
 	} else if (urb->actual_length > 0) {
 		err("%s(): Unexpected response length, expected %d got %d",
-		    __FUNCTION__, kingsun->max_rx, urb->actual_length);
+		    __func__, kingsun->max_rx, urb->actual_length);
 	}
 	/* This urb has already been filled in kingsun_net_open */
 	ret = usb_submit_urb(urb, GFP_ATOMIC);
diff --git a/drivers/net/irda/litelink-sir.c b/drivers/net/irda/litelink-sir.c
index 73261c5..d6d9d2e 100644
--- a/drivers/net/irda/litelink-sir.c
+++ b/drivers/net/irda/litelink-sir.c
@@ -78,7 +78,7 @@ static int litelink_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power up dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -95,7 +95,7 @@ static int litelink_open(struct sir_dev *dev)
 
 static int litelink_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -113,7 +113,7 @@ static int litelink_change_speed(struct sir_dev *dev, unsigned speed)
 {
         int i;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* dongle already reset by irda-thread - current speed (dongle and
 	 * port) is the default speed (115200 for litelink!)
@@ -156,7 +156,7 @@ static int litelink_change_speed(struct sir_dev *dev, unsigned speed)
  */
 static int litelink_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* probably the power-up can be dropped here, but with only
 	 * 15 usec delay it's not worth the risk unless somebody with
diff --git a/drivers/net/irda/ma600-sir.c b/drivers/net/irda/ma600-sir.c
index 809906d..1ceed9c 100644
--- a/drivers/net/irda/ma600-sir.c
+++ b/drivers/net/irda/ma600-sir.c
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
 
@@ -88,7 +88,7 @@ static int ma600_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -106,7 +106,7 @@ static int ma600_open(struct sir_dev *dev)
 
 static int ma600_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -176,7 +176,7 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 {
 	u8	byte;
 	
-	IRDA_DEBUG(2, "%s(), speed=%d (was %d)\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), speed=%d (was %d)\n", __func__,
 		speed, dev->speed);
 
 	/* dongle already reset, dongle and port at default speed (9600) */
@@ -201,12 +201,12 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
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
@@ -238,7 +238,7 @@ static int ma600_change_speed(struct sir_dev *dev, unsigned speed)
 
 int ma600_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Reset the dongle : set DTR low for 10 ms */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE);
diff --git a/drivers/net/irda/mcp2120-sir.c b/drivers/net/irda/mcp2120-sir.c
index 67bd016..5e2f485 100644
--- a/drivers/net/irda/mcp2120-sir.c
+++ b/drivers/net/irda/mcp2120-sir.c
@@ -63,7 +63,7 @@ static int mcp2120_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* seems no explicit power-on required here and reset switching it on anyway */
 
@@ -76,7 +76,7 @@ static int mcp2120_open(struct sir_dev *dev)
 
 static int mcp2120_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
         /* reset and inhibit mcp2120 */
@@ -102,7 +102,7 @@ static int mcp2120_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 control[2];
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -155,7 +155,7 @@ static int mcp2120_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefine state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefine state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -187,7 +187,7 @@ static int mcp2120_reset(struct sir_dev *dev)
 	unsigned delay = 0;
 	int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch (state) {
 	case SIRDEV_STATE_DONGLE_RESET:
@@ -213,7 +213,7 @@ static int mcp2120_reset(struct sir_dev *dev)
 		break;
 
 	default:
-		IRDA_ERROR("%s(), undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s(), undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
diff --git a/drivers/net/irda/nsc-ircc.c b/drivers/net/irda/nsc-ircc.c
index a873d2b..9494970 100644
--- a/drivers/net/irda/nsc-ircc.c
+++ b/drivers/net/irda/nsc-ircc.c
@@ -218,7 +218,7 @@ static int __init nsc_ircc_init(void)
 
 	/* Probe for all the NSC chipsets we know about */
 	for (chip = chips; chip->name ; chip++) {
-		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __FUNCTION__,
+		IRDA_DEBUG(2, "%s(), Probing for %s ...\n", __func__,
 			   chip->name);
 		
 		/* Try all config registers for this chip */
@@ -230,7 +230,7 @@ static int __init nsc_ircc_init(void)
 			/* Read index register */
 			reg = inb(cfg_base);
 			if (reg == 0xff) {
-				IRDA_DEBUG(2, "%s() no chip at 0x%03x\n", __FUNCTION__, cfg_base);
+				IRDA_DEBUG(2, "%s() no chip at 0x%03x\n", __func__, cfg_base);
 				continue;
 			}
 			
@@ -239,7 +239,7 @@ static int __init nsc_ircc_init(void)
 			id = inb(cfg_base+1);
 			if ((id & chip->cid_mask) == chip->cid_value) {
 				IRDA_DEBUG(2, "%s() Found %s chip, revision=%d\n",
-					   __FUNCTION__, chip->name, id & ~chip->cid_mask);
+					   __func__, chip->name, id & ~chip->cid_mask);
 
 				/*
 				 * If we found a correct PnP setting,
@@ -290,7 +290,7 @@ static int __init nsc_ircc_init(void)
 				}
 				i++;
 			} else {
-				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __FUNCTION__, id);
+				IRDA_DEBUG(2, "%s(), Wrong chip id=0x%02x\n", __func__, id);
 			}
 		} 
 	}
@@ -340,7 +340,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 	void *ret;
 	int err, chip_index;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 
  	for (chip_index = 0; chip_index < ARRAY_SIZE(dev_self); chip_index++) {
@@ -349,7 +349,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 	}
 
 	if (chip_index == ARRAY_SIZE(dev_self)) {
-		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), maximum number of supported chips reached!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -364,7 +364,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 	dev = alloc_irdadev(sizeof(struct nsc_ircc_cb));
 	if (dev == NULL) {
 		IRDA_ERROR("%s(), can't allocate memory for "
-			   "control block!\n", __FUNCTION__);
+			   "control block!\n", __func__);
 		return -ENOMEM;
 	}
 
@@ -388,7 +388,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 	ret = request_region(self->io.fir_base, self->io.fir_ext, driver_name);
 	if (!ret) {
 		IRDA_WARNING("%s(), can't get iobase of 0x%03x\n",
-			     __FUNCTION__, self->io.fir_base);
+			     __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto out1;
 	}
@@ -445,7 +445,7 @@ static int __init nsc_ircc_open(chipio_t *info)
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
 		goto out4;
 	}
 	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
@@ -501,7 +501,7 @@ static int __exit nsc_ircc_close(struct nsc_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -514,7 +514,7 @@ static int __exit nsc_ircc_close(struct nsc_ircc_cb *self)
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(4, "%s(), Releasing Region %03x\n", 
-		   __FUNCTION__, self->io.fir_base);
+		   __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -552,7 +552,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 0x2e8: outb(0x15, cfg_base+1); break;
 	case 0x3f8: outb(0x16, cfg_base+1); break;
 	case 0x2f8: outb(0x17, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid base_address", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid base_address", __func__);
 	}
 	
 	/* Control Signal Routing Register (CSRT) */
@@ -564,7 +564,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 9:  temp = 0x05; break;
 	case 11: temp = 0x06; break;
 	case 15: temp = 0x07; break;
-	default: IRDA_ERROR("%s(), invalid irq", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid irq", __func__);
 	}
 	outb(CFG_108_CSRT, cfg_base);
 	
@@ -572,7 +572,7 @@ static int nsc_ircc_init_108(nsc_chip_t *chip, chipio_t *info)
 	case 0: outb(0x08+temp, cfg_base+1); break;
 	case 1: outb(0x10+temp, cfg_base+1); break;
 	case 3: outb(0x18+temp, cfg_base+1); break;
-	default: IRDA_ERROR("%s(), invalid dma", __FUNCTION__);
+	default: IRDA_ERROR("%s(), invalid dma", __func__);
 	}
 	
 	outb(CFG_108_MCTL, cfg_base);      /* Mode Control Register (MCTL) */
@@ -611,7 +611,7 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		break;
 	}
 	info->sir_base = info->fir_base;
-	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s(), probing fir_base=0x%03x\n", __func__,
 		   info->fir_base);
 
 	/* Read control signals routing register (CSRT) */
@@ -644,7 +644,7 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		info->irq = 15;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __FUNCTION__, info->irq);
+	IRDA_DEBUG(2, "%s(), probing irq=%d\n", __func__, info->irq);
 
 	/* Currently we only read Rx DMA but it will also be used for Tx */
 	switch ((reg >> 3) & 0x03) {
@@ -661,7 +661,7 @@ static int nsc_ircc_probe_108(nsc_chip_t *chip, chipio_t *info)
 		info->dma = 3;
 		break;
 	}
-	IRDA_DEBUG(2, "%s(), probing dma=%d\n", __FUNCTION__, info->dma);
+	IRDA_DEBUG(2, "%s(), probing dma=%d\n", __func__, info->dma);
 
 	/* Read mode control register (MCTL) */
 	outb(CFG_108_MCTL, cfg_base);
@@ -818,7 +818,7 @@ static int nsc_ircc_init_39x(nsc_chip_t *chip, chipio_t *info)
 	/* User is sure about his config... accept it. */
 	IRDA_DEBUG(2, "%s(): nsc_ircc_init_39x (user settings): "
 		   "io=0x%04x, irq=%d, dma=%d\n", 
-		   __FUNCTION__, info->fir_base, info->irq, info->dma);
+		   __func__, info->fir_base, info->irq, info->dma);
 
 	/* Access bank for SP2 */
 	outb(CFG_39X_LDN, cfg_base);
@@ -859,7 +859,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t *chip, chipio_t *info)
 	int enabled, susp;
 
 	IRDA_DEBUG(2, "%s(), nsc_ircc_probe_39x, base=%d\n",
-		   __FUNCTION__, cfg_base);
+		   __func__, cfg_base);
 
 	/* This function should be executed with irq off to avoid
 	 * another driver messing with the Super I/O bank - Jean II */
@@ -893,7 +893,7 @@ static int nsc_ircc_probe_39x(nsc_chip_t *chip, chipio_t *info)
 	outb(CFG_39X_SPC, cfg_base);
 	susp = 1 - ((inb(cfg_base+1) & 0x02) >> 1);
 
-	IRDA_DEBUG(2, "%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n", __FUNCTION__, reg1,reg2,irq,irqt,dma1,dma2,enabled,susp);
+	IRDA_DEBUG(2, "%s(): io=0x%02x%02x, irq=%d (type %d), rxdma=%d, txdma=%d, enabled=%d (suspended=%d)\n", __func__, reg1,reg2,irq,irqt,dma1,dma2,enabled,susp);
 
 	/* Configure SP2 */
 
@@ -941,7 +941,7 @@ static int nsc_ircc_pnp_probe(struct pnp_dev *dev, const struct pnp_device_id *i
 		pnp_info.dma = pnp_dma(dev, 0);
 
 	IRDA_DEBUG(0, "%s() : From PnP, found firbase 0x%03X ; irq %d ; dma %d.\n",
-		   __FUNCTION__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
+		   __func__, pnp_info.fir_base, pnp_info.irq, pnp_info.dma);
 
 	if((pnp_info.fir_base == 0) ||
 	   (pnp_info.irq == -1) || (pnp_info.dma == -1)) {
@@ -969,7 +969,7 @@ static int nsc_ircc_setup(chipio_t *info)
 	version = inb(iobase+MID);
 
 	IRDA_DEBUG(2, "%s() Driver %s Found chip version %02x\n",
-		   __FUNCTION__, driver_name, version);
+		   __func__, driver_name, version);
 
 	/* Should be 0x2? */
 	if (0x20 != (version & 0xf0)) {
@@ -1073,30 +1073,30 @@ static void nsc_ircc_init_dongle_interface (int iobase, int dongle_id)
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
@@ -1104,7 +1104,7 @@ static void nsc_ircc_init_dongle_interface (int iobase, int dongle_id)
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]); 
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1119,14 +1119,14 @@ static void nsc_ircc_init_dongle_interface (int iobase, int dongle_id)
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
@@ -1158,30 +1158,30 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
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
@@ -1200,7 +1200,7 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
 	case 0x0A: /* same as */
 	case 0x0B: /* Reserved */
 		IRDA_DEBUG(0, "%s(), %s not defined by irda yet\n",
-			   __FUNCTION__, dongle_types[dongle_id]); 
+			   __func__, dongle_types[dongle_id]); 
 		break;
 	case 0x0C: /* same as */
 	case 0x0D: /* HP HSDL-1100/HSDL-2100 */
@@ -1209,13 +1209,13 @@ static void nsc_ircc_change_dongle_speed(int iobase, int speed, int dongle_id)
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
@@ -1236,7 +1236,7 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
 	__u8 bank;
 	__u8 ier;                  /* Interrupt enable register */
 
-	IRDA_DEBUG(2, "%s(), speed=%d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(2, "%s(), speed=%d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return 0;);
 
@@ -1269,20 +1269,20 @@ static __u8 nsc_ircc_change_speed(struct nsc_ircc_cb *self, __u32 speed)
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
 
@@ -1587,7 +1587,7 @@ static int nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	int actual = 0;
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 
 	/* Save current bank */
 	bank = inb(iobase+BSR);
@@ -1595,7 +1595,7 @@ static int nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	switch_bank(iobase, BANK0);
 	if (!(inb_p(iobase+LSR) & LSR_TXEMP)) {
 		IRDA_DEBUG(4, "%s(), warning, FIFO not empty yet!\n",
-			   __FUNCTION__);
+			   __func__);
 
 		/* FIFO may still be filled to the Tx interrupt threshold */
 		fifo_size -= 17;
@@ -1608,7 +1608,7 @@ static int nsc_ircc_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	}
         
 	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __FUNCTION__, fifo_size, actual, len);
+		   __func__, fifo_size, actual, len);
 	
 	/* Restore bank */
 	outb(bank, iobase+BSR);
@@ -1629,7 +1629,7 @@ static int nsc_ircc_dma_xmit_complete(struct nsc_ircc_cb *self)
 	__u8 bank;
 	int ret = TRUE;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	iobase = self->io.fir_base;
 
@@ -1760,7 +1760,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 		len = inb(iobase+RFLFL) | ((inb(iobase+RFLFH) & 0x1f) << 8);
 
 		if (st_fifo->tail >= MAX_RX_WINDOW) {
-			IRDA_DEBUG(0, "%s(), window is full!\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s(), window is full!\n", __func__);
 			continue;
 		}
 			
@@ -1852,7 +1852,7 @@ static int nsc_ircc_dma_receive_complete(struct nsc_ircc_cb *self, int iobase)
 			if (skb == NULL)  {
 				IRDA_WARNING("%s(), memory squeeze, "
 					     "dropping frame.\n",
-					     __FUNCTION__);
+					     __func__);
 				self->stats.rx_dropped++;
 
 				/* Restore bank register */
@@ -1958,7 +1958,7 @@ static void nsc_ircc_sir_interrupt(struct nsc_ircc_cb *self, int eir)
 		 * Need to be after self->io.direction to avoid race with
 		 * nsc_ircc_hard_xmit_sir() - Jean II */
 		if (self->new_speed) {
-			IRDA_DEBUG(2, "%s(), Changing speed!\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), Changing speed!\n", __func__);
 			self->ier = nsc_ircc_change_speed(self,
 							  self->new_speed);
 			self->new_speed = 0;
@@ -2044,7 +2044,7 @@ static void nsc_ircc_fir_interrupt(struct nsc_ircc_cb *self, int iobase,
 				} else
 					IRDA_WARNING("%s(), potential "
 						     "Tx queue lockup !\n",
-						     __FUNCTION__);
+						     __func__);
 			}
 		} else {
 			/*  Not finished yet, so interrupt on DMA again */
@@ -2153,7 +2153,7 @@ static int nsc_ircc_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 bank;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct nsc_ircc_cb *) dev->priv;
@@ -2215,7 +2215,7 @@ static int nsc_ircc_net_close(struct net_device *dev)
 	int iobase;
 	__u8 bank;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s()\n", __func__);
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 
@@ -2269,7 +2269,7 @@ static int nsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
diff --git a/drivers/net/irda/old_belkin-sir.c b/drivers/net/irda/old_belkin-sir.c
index 8c22c73..75714bc 100644
--- a/drivers/net/irda/old_belkin-sir.c
+++ b/drivers/net/irda/old_belkin-sir.c
@@ -92,7 +92,7 @@ static int old_belkin_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power on dongle */
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
@@ -110,7 +110,7 @@ static int old_belkin_open(struct sir_dev *dev)
 
 static int old_belkin_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -125,7 +125,7 @@ static int old_belkin_close(struct sir_dev *dev)
  */
 static int old_belkin_change_speed(struct sir_dev *dev, unsigned speed)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	dev->speed = 9600;
 	return (speed==dev->speed) ? 0 : -EINVAL;
@@ -139,7 +139,7 @@ static int old_belkin_change_speed(struct sir_dev *dev, unsigned speed)
  */
 static int old_belkin_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* This dongles speed "defaults" to 9600 bps ;-) */
 	dev->speed = 9600;
diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 6078e03..59384f1 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -80,7 +80,7 @@ static int sirdev_tx_complete_fsm(struct sir_dev *dev)
 			return 0;
 
 		default:
-			IRDA_ERROR("%s - undefined state\n", __FUNCTION__);
+			IRDA_ERROR("%s - undefined state\n", __func__);
 			return -EINVAL;
 		}
 		fsm->substate = next_state;
@@ -107,11 +107,11 @@ static void sirdev_config_fsm(struct work_struct *work)
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
@@ -249,12 +249,12 @@ static void sirdev_config_fsm(struct work_struct *work)
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
@@ -284,11 +284,11 @@ int sirdev_schedule_request(struct sir_dev *dev, int initial_state, unsigned par
 {
 	struct sir_fsm *fsm = &dev->fsm;
 
-	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __FUNCTION__, initial_state, param);
+	IRDA_DEBUG(2, "%s - state=0x%04x / param=%u\n", __func__, initial_state, param);
 
 	if (down_trylock(&fsm->sem)) {
 		if (in_interrupt()  ||  in_atomic()  ||  irqs_disabled()) {
-			IRDA_DEBUG(1, "%s(), state machine busy!\n", __FUNCTION__);
+			IRDA_DEBUG(1, "%s(), state machine busy!\n", __func__);
 			return -EWOULDBLOCK;
 		} else
 			down(&fsm->sem);
@@ -296,7 +296,7 @@ int sirdev_schedule_request(struct sir_dev *dev, int initial_state, unsigned par
 
 	if (fsm->state == SIRDEV_STATE_DEAD) {
 		/* race with sirdev_close should never happen */
-		IRDA_ERROR("%s(), instance staled!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), instance staled!\n", __func__);
 		up(&fsm->sem);
 		return -ESTALE;		/* or better EPIPE? */
 	}
@@ -341,7 +341,7 @@ int sirdev_set_dongle(struct sir_dev *dev, IRDA_DONGLE type)
 {
 	int err;
 
-	IRDA_DEBUG(3, "%s : requesting dongle %d.\n", __FUNCTION__, type);
+	IRDA_DEBUG(3, "%s : requesting dongle %d.\n", __func__, type);
 
 	err = sirdev_schedule_dongle_open(dev, type);
 	if (unlikely(err))
@@ -376,7 +376,7 @@ int sirdev_raw_write(struct sir_dev *dev, const char *buf, int len)
 
 	ret = dev->drv->do_write(dev, dev->tx_buff.data, dev->tx_buff.len);
 	if (ret > 0) {
-		IRDA_DEBUG(3, "%s(), raw-tx started\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), raw-tx started\n", __func__);
 
 		dev->tx_buff.data += ret;
 		dev->tx_buff.len -= ret;
@@ -437,7 +437,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 	spin_lock_irqsave(&dev->tx_lock, flags);
 
 	IRDA_DEBUG(3, "%s() - dev->tx_buff.len = %d\n",
-		   __FUNCTION__, dev->tx_buff.len);
+		   __func__, dev->tx_buff.len);
 
 	if (likely(dev->tx_buff.len > 0))  {
 		/* Write data left in transmit buffer */
@@ -450,7 +450,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 		else if (unlikely(actual<0)) {
 			/* could be dropped later when we have tx_timeout to recover */
 			IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-				   __FUNCTION__, actual);
+				   __func__, actual);
 			if ((skb=dev->tx_skb) != NULL) {
 				dev->tx_skb = NULL;
 				dev_kfree_skb_any(skb);
@@ -471,7 +471,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 		 * restarted when the irda-thread has completed the request.
 		 */
 
-		IRDA_DEBUG(3, "%s(), raw-tx done\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), raw-tx done\n", __func__);
 		dev->raw_tx = 0;
 		goto done;	/* no post-frame handling in raw mode */
 	}
@@ -488,7 +488,7 @@ void sirdev_write_complete(struct sir_dev *dev)
 	 * re-activated.
 	 */
 
-	IRDA_DEBUG(5, "%s(), finished with frame!\n", __FUNCTION__);
+	IRDA_DEBUG(5, "%s(), finished with frame!\n", __func__);
 		
 	if ((skb=dev->tx_skb) != NULL) {
 		dev->tx_skb = NULL;
@@ -498,14 +498,14 @@ void sirdev_write_complete(struct sir_dev *dev)
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
 
@@ -548,7 +548,7 @@ int sirdev_receive(struct sir_dev *dev, const unsigned char *cp, size_t count)
 		 */
 		irda_device_set_media_busy(dev->netdev, TRUE);
 		dev->stats.rx_dropped++;
-		IRDA_DEBUG(0, "%s; rx-drop: %zd\n", __FUNCTION__, count);
+		IRDA_DEBUG(0, "%s; rx-drop: %zd\n", __func__, count);
 		return 0;
 	}
 
@@ -600,7 +600,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	netif_stop_queue(ndev);
 
-	IRDA_DEBUG(3, "%s(), skb->len = %d\n", __FUNCTION__, skb->len);
+	IRDA_DEBUG(3, "%s(), skb->len = %d\n", __func__, skb->len);
 
 	speed = irda_get_next_speed(skb);
 	if ((speed != dev->speed) && (speed != -1)) {
@@ -637,7 +637,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	/* Check problems */
 	if(spin_is_locked(&dev->tx_lock)) {
-		IRDA_DEBUG(3, "%s(), write not completed\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s(), write not completed\n", __func__);
 	}
 
 	/* serialize with write completion */
@@ -666,7 +666,7 @@ static int sirdev_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 	else if (unlikely(actual < 0)) {
 		/* could be dropped later when we have tx_timeout to recover */
 		IRDA_ERROR("%s: drv->do_write failed (%d)\n",
-			   __FUNCTION__, actual);
+			   __func__, actual);
 		dev_kfree_skb_any(skb);
 		dev->stats.tx_errors++;		      
 		dev->stats.tx_dropped++;		      
@@ -687,7 +687,7 @@ static int sirdev_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 
-	IRDA_DEBUG(3, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, ndev->name, cmd);
+	IRDA_DEBUG(3, "%s(), %s, (cmd=0x%X)\n", __func__, ndev->name, cmd);
 	
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -804,7 +804,7 @@ static int sirdev_open(struct net_device *ndev)
 	if (!try_module_get(drv->owner))
 		return -ESTALE;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	if (sirdev_alloc_buffers(dev))
 		goto errout_dec;
@@ -822,7 +822,7 @@ static int sirdev_open(struct net_device *ndev)
 
 	netif_wake_queue(ndev);
 
-	IRDA_DEBUG(2, "%s - done, speed = %d\n", __FUNCTION__, dev->speed);
+	IRDA_DEBUG(2, "%s - done, speed = %d\n", __func__, dev->speed);
 
 	return 0;
 
@@ -842,7 +842,7 @@ static int sirdev_close(struct net_device *ndev)
 	struct sir_dev *dev = ndev->priv;
 	const struct sir_driver *drv;
 
-//	IRDA_DEBUG(0, "%s\n", __FUNCTION__);
+//	IRDA_DEBUG(0, "%s\n", __func__);
 
 	netif_stop_queue(ndev);
 
@@ -878,7 +878,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	struct net_device *ndev;
 	struct sir_dev *dev;
 
-	IRDA_DEBUG(0, "%s - %s\n", __FUNCTION__, name);
+	IRDA_DEBUG(0, "%s - %s\n", __func__, name);
 
 	/* instead of adding tests to protect against drv->do_write==NULL
 	 * at several places we refuse to create a sir_dev instance for
@@ -892,7 +892,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	 */
 	ndev = alloc_irdadev(sizeof(*dev));
 	if (ndev == NULL) {
-		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __FUNCTION__);
+		IRDA_ERROR("%s - Can't allocate memory for IrDA control block!\n", __func__);
 		goto out;
 	}
 	dev = ndev->priv;
@@ -921,7 +921,7 @@ struct sir_dev * sirdev_get_instance(const struct sir_driver *drv, const char *n
 	ndev->do_ioctl = sirdev_ioctl;
 
 	if (register_netdev(ndev)) {
-		IRDA_ERROR("%s(), register_netdev() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdev() failed!\n", __func__);
 		goto out_freenetdev;
 	}
 
@@ -938,7 +938,7 @@ int sirdev_put_instance(struct sir_dev *dev)
 {
 	int err = 0;
 
-	IRDA_DEBUG(0, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(0, "%s\n", __func__);
 
 	atomic_set(&dev->enable_rx, 0);
 
@@ -948,7 +948,7 @@ int sirdev_put_instance(struct sir_dev *dev)
 	if (dev->dongle_drv)
 		err = sirdev_schedule_dongle_close(dev);
 	if (err)
-		IRDA_ERROR("%s - error %d\n", __FUNCTION__, err);
+		IRDA_ERROR("%s - error %d\n", __func__, err);
 
 	sirdev_close(dev->netdev);
 
diff --git a/drivers/net/irda/sir_dongle.c b/drivers/net/irda/sir_dongle.c
index 25d5b8a..3603024 100644
--- a/drivers/net/irda/sir_dongle.c
+++ b/drivers/net/irda/sir_dongle.c
@@ -36,7 +36,7 @@ int irda_register_dongle(struct dongle_driver *new)
 	struct dongle_driver *drv;
 
 	IRDA_DEBUG(0, "%s : registering dongle \"%s\" (%d).\n",
-		   __FUNCTION__, new->driver_name, new->type);
+		   __func__, new->driver_name, new->type);
 
 	mutex_lock(&dongle_list_lock);
 	list_for_each(entry, &dongle_list) {
diff --git a/drivers/net/irda/smsc-ircc2.c b/drivers/net/irda/smsc-ircc2.c
index 1f26da7..f4a8127 100644
--- a/drivers/net/irda/smsc-ircc2.c
+++ b/drivers/net/irda/smsc-ircc2.c
@@ -458,7 +458,7 @@ static int __init smsc_ircc_init(void)
 {
 	int ret;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	ret = platform_driver_register(&smsc_ircc_driver);
 	if (ret) {
@@ -498,7 +498,7 @@ static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u
 	struct net_device *dev;
 	int err;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	err = smsc_ircc_present(fir_base, sir_base);
 	if (err)
@@ -506,7 +506,7 @@ static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u
 
 	err = -ENOMEM;
 	if (dev_count >= ARRAY_SIZE(dev_self)) {
-	        IRDA_WARNING("%s(), too many devices!\n", __FUNCTION__);
+	        IRDA_WARNING("%s(), too many devices!\n", __func__);
 		goto err_out1;
 	}
 
@@ -515,7 +515,7 @@ static int __init smsc_ircc_open(unsigned int fir_base, unsigned int sir_base, u
 	 */
 	dev = alloc_irdadev(sizeof(struct smsc_ircc_cb));
 	if (!dev) {
-		IRDA_WARNING("%s() can't allocate net device\n", __FUNCTION__);
+		IRDA_WARNING("%s() can't allocate net device\n", __func__);
 		goto err_out1;
 	}
 
@@ -631,14 +631,14 @@ static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base)
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
 
@@ -654,7 +654,7 @@ static int smsc_ircc_present(unsigned int fir_base, unsigned int sir_base)
 
 	if (high != 0x10 || low != 0xb8 || (chip != 0xf1 && chip != 0xf2)) {
 		IRDA_WARNING("%s(), addr 0x%04x - no device found!\n",
-			     __FUNCTION__, fir_base);
+			     __func__, fir_base);
 		goto out3;
 	}
 	IRDA_MESSAGE("SMsC IrDA Controller found\n IrCC version %d.%d, "
@@ -791,7 +791,7 @@ static int smsc_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name, cmd);
 
 	switch (cmd) {
 	case SIOCSBANDWIDTH: /* Set bandwidth */
@@ -876,7 +876,7 @@ int smsc_ircc_hard_xmit_sir(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 	s32 speed;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return 0;);
 
@@ -951,21 +951,21 @@ static void smsc_ircc_set_fir_speed(struct smsc_ircc_cb *self, u32 speed)
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
@@ -993,7 +993,7 @@ static void smsc_ircc_fir_start(struct smsc_ircc_cb *self)
 	struct net_device *dev;
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1041,7 +1041,7 @@ static void smsc_ircc_fir_stop(struct smsc_ircc_cb *self)
 {
 	int fir_base;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -1065,7 +1065,7 @@ static void smsc_ircc_change_speed(struct smsc_ircc_cb *self, u32 speed)
 	struct net_device *dev;
 	int last_speed_was_sir;
 
-	IRDA_DEBUG(0, "%s() changing speed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(0, "%s() changing speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1133,7 +1133,7 @@ void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 	int lcr;    /* Line control reg */
 	int divisor;
 
-	IRDA_DEBUG(0, "%s(), Setting speed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(0, "%s(), Setting speed to: %d\n", __func__, speed);
 
 	IRDA_ASSERT(self != NULL, return;);
 	iobase = self->io.sir_base;
@@ -1168,7 +1168,7 @@ void smsc_ircc_set_sir_speed(struct smsc_ircc_cb *self, __u32 speed)
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI | UART_IER_THRI, iobase + UART_IER);
 
-	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __FUNCTION__, speed);
+	IRDA_DEBUG(2, "%s() speed changed to: %d\n", __func__, speed);
 }
 
 
@@ -1251,7 +1251,7 @@ static void smsc_ircc_dma_xmit(struct smsc_ircc_cb *self, int bofs)
 	int iobase = self->io.fir_base;
 	u8 ctrl;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 1
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1305,7 +1305,7 @@ static void smsc_ircc_dma_xmit_complete(struct smsc_ircc_cb *self)
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 0
 	/* Disable Tx */
 	register_bank(iobase, 0);
@@ -1409,7 +1409,7 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 
 	register_bank(iobase, 0);
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 #if 0
 	/* Disable Rx */
 	register_bank(iobase, 0);
@@ -1420,7 +1420,7 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
 	lsr= inb(iobase + IRCC_LSR);
 	msgcnt = inb(iobase + IRCC_LCR_B) & 0x08;
 
-	IRDA_DEBUG(2, "%s: dma count = %d\n", __FUNCTION__,
+	IRDA_DEBUG(2, "%s: dma count = %d\n", __func__,
 		   get_dma_residue(self->io.dma));
 
 	len = self->rx_buff.truesize - get_dma_residue(self->io.dma);
@@ -1443,15 +1443,15 @@ static void smsc_ircc_dma_receive_complete(struct smsc_ircc_cb *self)
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
@@ -1492,7 +1492,7 @@ static void smsc_ircc_sir_receive(struct smsc_ircc_cb *self)
 
 		/* Make sure we don't stay here to long */
 		if (boguscount++ > 32) {
-			IRDA_DEBUG(2, "%s(), breaking!\n", __FUNCTION__);
+			IRDA_DEBUG(2, "%s(), breaking!\n", __func__);
 			break;
 		}
 	} while (inb(iobase + UART_LSR) & UART_LSR_DR);
@@ -1534,7 +1534,7 @@ static irqreturn_t smsc_ircc_interrupt(int dummy, void *dev_id)
 	lcra = inb(iobase + IRCC_LCR_A);
 	lsr = inb(iobase + IRCC_LSR);
 
-	IRDA_DEBUG(2, "%s(), iir = 0x%02x\n", __FUNCTION__, iir);
+	IRDA_DEBUG(2, "%s(), iir = 0x%02x\n", __func__, iir);
 
 	if (iir & IRCC_IIR_EOM) {
 		if (self->io.direction == IO_RECV)
@@ -1546,7 +1546,7 @@ static irqreturn_t smsc_ircc_interrupt(int dummy, void *dev_id)
 	}
 
 	if (iir & IRCC_IIR_ACTIVE_FRAME) {
-		/*printk(KERN_WARNING "%s(): Active Frame\n", __FUNCTION__);*/
+		/*printk(KERN_WARNING "%s(): Active Frame\n", __func__);*/
 	}
 
 	/* Enable interrupts again */
@@ -1585,11 +1585,11 @@ static irqreturn_t smsc_ircc_interrupt_sir(struct net_device *dev)
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
@@ -1602,7 +1602,7 @@ static irqreturn_t smsc_ircc_interrupt_sir(struct net_device *dev)
 			break;
 		default:
 			IRDA_DEBUG(0, "%s(), unhandled IIR=%#x\n",
-				   __FUNCTION__, iir);
+				   __func__, iir);
 			break;
 		}
 
@@ -1629,11 +1629,11 @@ static int ircc_is_receiving(struct smsc_ircc_cb *self)
 	int status = FALSE;
 	/* int iobase; */
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return FALSE;);
 
-	IRDA_DEBUG(0, "%s: dma count = %d\n", __FUNCTION__,
+	IRDA_DEBUG(0, "%s: dma count = %d\n", __func__,
 		   get_dma_residue(self->io.dma));
 
 	status = (self->rx_buff.state != OUTSIDE_FRAME);
@@ -1650,7 +1650,7 @@ static int smsc_ircc_request_irq(struct smsc_ircc_cb *self)
 			    self->netdev->name, self->netdev);
 	if (error)
 		IRDA_DEBUG(0, "%s(), unable to allocate irq=%d, err=%d\n",
-			   __FUNCTION__, self->io.irq, error);
+			   __func__, self->io.irq, error);
 
 	return error;
 }
@@ -1694,21 +1694,21 @@ static int smsc_ircc_net_open(struct net_device *dev)
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
 
@@ -1732,7 +1732,7 @@ static int smsc_ircc_net_open(struct net_device *dev)
 		smsc_ircc_net_close(dev);
 
 		IRDA_WARNING("%s(), unable to allocate DMA=%d\n",
-			     __FUNCTION__, self->io.dma);
+			     __func__, self->io.dma);
 		return -EAGAIN;
 	}
 
@@ -1751,7 +1751,7 @@ static int smsc_ircc_net_close(struct net_device *dev)
 {
 	struct smsc_ircc_cb *self;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
@@ -1834,7 +1834,7 @@ static int smsc_ircc_resume(struct platform_device *dev)
  */
 static int __exit smsc_ircc_close(struct smsc_ircc_cb *self)
 {
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -1846,12 +1846,12 @@ static int __exit smsc_ircc_close(struct smsc_ircc_cb *self)
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
@@ -1873,7 +1873,7 @@ static void __exit smsc_ircc_cleanup(void)
 {
 	int i;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	for (i = 0; i < 2; i++) {
 		if (dev_self[i])
@@ -1897,7 +1897,7 @@ void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 	struct net_device *dev;
 	int fir_base, sir_base;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return;);
 	dev = self->netdev;
@@ -1924,7 +1924,7 @@ void smsc_ircc_sir_start(struct smsc_ircc_cb *self)
 	/* Turn on interrups */
 	outb(UART_IER_RLSI | UART_IER_RDI |UART_IER_THRI, sir_base + UART_IER);
 
-	IRDA_DEBUG(3, "%s() - exit\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s() - exit\n", __func__);
 
 	outb(0x00, fir_base + IRCC_MASTER);
 }
@@ -1934,7 +1934,7 @@ void smsc_ircc_sir_stop(struct smsc_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(3, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s\n", __func__);
 	iobase = self->io.sir_base;
 
 	/* Reset UART */
@@ -1960,7 +1960,7 @@ static void smsc_ircc_sir_write_wakeup(struct smsc_ircc_cb *self)
 
 	IRDA_ASSERT(self != NULL, return;);
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(4, "%s\n", __func__);
 
 	iobase = self->io.sir_base;
 
@@ -1982,7 +1982,7 @@ static void smsc_ircc_sir_write_wakeup(struct smsc_ircc_cb *self)
 		 */
 		if (self->new_speed) {
 			IRDA_DEBUG(5, "%s(), Changing speed to %d.\n",
-				   __FUNCTION__, self->new_speed);
+				   __func__, self->new_speed);
 			smsc_ircc_sir_wait_hw_transmitter_finish(self);
 			smsc_ircc_change_speed(self, self->new_speed);
 			self->new_speed = 0;
@@ -2021,7 +2021,7 @@ static int smsc_ircc_sir_write(int iobase, int fifo_size, __u8 *buf, int len)
 
 	/* Tx FIFO should be empty! */
 	if (!(inb(iobase + UART_LSR) & UART_LSR_THRE)) {
-		IRDA_WARNING("%s(), failed, fifo not empty!\n", __FUNCTION__);
+		IRDA_WARNING("%s(), failed, fifo not empty!\n", __func__);
 		return 0;
 	}
 
@@ -2121,7 +2121,7 @@ static void smsc_ircc_sir_wait_hw_transmitter_finish(struct smsc_ircc_cb *self)
 		udelay(1);
 
 	if (count == 0)
-		IRDA_DEBUG(0, "%s(): stuck transmitter\n", __FUNCTION__);
+		IRDA_DEBUG(0, "%s(): stuck transmitter\n", __func__);
 }
 
 
@@ -2143,7 +2143,7 @@ static int __init smsc_ircc_look_for_chips(void)
 	while (address->cfg_base) {
 		cfg_base = address->cfg_base;
 
-		/*printk(KERN_WARNING "%s(): probing: 0x%02x for: 0x%02x\n", __FUNCTION__, cfg_base, address->type);*/
+		/*printk(KERN_WARNING "%s(): probing: 0x%02x for: 0x%02x\n", __func__, cfg_base, address->type);*/
 
 		if (address->type & SMSCSIO_TYPE_FDC) {
 			type = "FDC";
@@ -2182,7 +2182,7 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	u8 mode, dma, irq;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	if (smsc_ircc_probe(cfgbase, SMSCSIOFLAT_DEVICEID_REG, chips, type) == NULL)
 		return ret;
@@ -2190,10 +2190,10 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	outb(SMSCSIOFLAT_UARTMODE0C_REG, cfgbase);
 	mode = inb(cfgbase + 1);
 
-	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __FUNCTION__, mode);*/
+	/*printk(KERN_WARNING "%s(): mode: 0x%02x\n", __func__, mode);*/
 
 	if (!(mode & SMSCSIOFLAT_UART2MODE_VAL_IRDA))
-		IRDA_WARNING("%s(): IrDA not enabled\n", __FUNCTION__);
+		IRDA_WARNING("%s(): IrDA not enabled\n", __func__);
 
 	outb(SMSCSIOFLAT_UART2BASEADDR_REG, cfgbase);
 	sirbase = inb(cfgbase + 1) << 2;
@@ -2210,7 +2210,7 @@ static int __init smsc_superio_flat(const struct smsc_chip *chips, unsigned shor
 	outb(SMSCSIOFLAT_UARTIRQSELECT_REG, cfgbase);
 	irq = inb(cfgbase + 1) & SMSCSIOFLAT_UART2IRQSELECT_MASK;
 
-	IRDA_MESSAGE("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n", __FUNCTION__, firbase, sirbase, dma, irq, mode);
+	IRDA_MESSAGE("%s(): fir: 0x%02x, sir: 0x%02x, dma: %02d, irq: %d, mode: 0x%02x\n", __func__, firbase, sirbase, dma, irq, mode);
 
 	if (firbase && smsc_ircc_open(firbase, sirbase, dma, irq) == 0)
 		ret = 0;
@@ -2232,7 +2232,7 @@ static int __init smsc_superio_paged(const struct smsc_chip *chips, unsigned sho
 	unsigned short fir_io, sir_io;
 	int ret = -ENODEV;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	if (smsc_ircc_probe(cfg_base, 0x20, chips, type) == NULL)
 		return ret;
@@ -2266,7 +2266,7 @@ static int __init smsc_superio_paged(const struct smsc_chip *chips, unsigned sho
 
 static int __init smsc_access(unsigned short cfg_base, unsigned char reg)
 {
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	outb(reg, cfg_base);
 	return inb(cfg_base) != reg ? -1 : 0;
@@ -2276,7 +2276,7 @@ static const struct smsc_chip * __init smsc_ircc_probe(unsigned short cfg_base,
 {
 	u8 devid, xdevid, rev;
 
-	IRDA_DEBUG(1, "%s\n", __FUNCTION__);
+	IRDA_DEBUG(1, "%s\n", __func__);
 
 	/* Leave configuration */
 
@@ -2351,7 +2351,7 @@ static int __init smsc_superio_fdc(unsigned short cfg_base)
 
 	if (!request_region(cfg_base, 2, driver_name)) {
 		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __FUNCTION__, cfg_base);
+			     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(fdc_chips_flat, cfg_base, "FDC") ||
 		    !smsc_superio_paged(fdc_chips_paged, cfg_base, "FDC"))
@@ -2369,7 +2369,7 @@ static int __init smsc_superio_lpc(unsigned short cfg_base)
 
 	if (!request_region(cfg_base, 2, driver_name)) {
 		IRDA_WARNING("%s: can't get cfg_base of 0x%03x\n",
-			     __FUNCTION__, cfg_base);
+			     __func__, cfg_base);
 	} else {
 		if (!smsc_superio_flat(lpc_chips_flat, cfg_base, "LPC") ||
 		    !smsc_superio_paged(lpc_chips_paged, cfg_base, "LPC"))
@@ -2930,7 +2930,7 @@ static void smsc_ircc_set_transceiver_smsc_ircc_atc(int fir_base, u32 speed)
 		/* empty */;
 
 	if (val)
-		IRDA_WARNING("%s(): ATC: 0x%02x\n", __FUNCTION__,
+		IRDA_WARNING("%s(): ATC: 0x%02x\n", __func__,
 			     inb(fir_base + IRCC_ATC));
 }
 
diff --git a/drivers/net/irda/tekram-sir.c b/drivers/net/irda/tekram-sir.c
index d1ce5ae..048a154 100644
--- a/drivers/net/irda/tekram-sir.c
+++ b/drivers/net/irda/tekram-sir.c
@@ -77,7 +77,7 @@ static int tekram_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	sirdev_set_dtr_rts(dev, TRUE, TRUE);
 
@@ -92,7 +92,7 @@ static int tekram_open(struct sir_dev *dev)
 
 static int tekram_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -130,7 +130,7 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 byte;
 	static int ret = 0;
 	
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -179,7 +179,7 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		IRDA_ERROR("%s - undefined state %d\n", __FUNCTION__, state);
+		IRDA_ERROR("%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -204,7 +204,7 @@ static int tekram_change_speed(struct sir_dev *dev, unsigned speed)
 
 static int tekram_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Clear DTR, Set RTS */
 	sirdev_set_dtr_rts(dev, FALSE, TRUE); 
diff --git a/drivers/net/irda/toim3232-sir.c b/drivers/net/irda/toim3232-sir.c
index aa1a9b0..fcf287b 100644
--- a/drivers/net/irda/toim3232-sir.c
+++ b/drivers/net/irda/toim3232-sir.c
@@ -181,7 +181,7 @@ static int toim3232_open(struct sir_dev *dev)
 {
 	struct qos_info *qos = &dev->qos;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Pull the lines high to start with.
 	 *
@@ -209,7 +209,7 @@ static int toim3232_open(struct sir_dev *dev)
 
 static int toim3232_close(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Power off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
@@ -241,7 +241,7 @@ static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
 	u8 byte;
 	static int ret = 0;
 
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	switch(state) {
 	case SIRDEV_STATE_DONGLE_SPEED:
@@ -299,7 +299,7 @@ static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
 		break;
 
 	default:
-		printk(KERN_ERR "%s - undefined state %d\n", __FUNCTION__, state);
+		printk(KERN_ERR "%s - undefined state %d\n", __func__, state);
 		ret = -EINVAL;
 		break;
 	}
@@ -344,7 +344,7 @@ static int toim3232_change_speed(struct sir_dev *dev, unsigned speed)
 
 static int toim3232_reset(struct sir_dev *dev)
 {
-	IRDA_DEBUG(2, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Switch off both DTR and RTS to switch off dongle */
 	sirdev_set_dtr_rts(dev, FALSE, FALSE);
diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index 58e1287..b036ca8 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
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
@@ -170,11 +170,11 @@ static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_devi
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
 
@@ -185,7 +185,7 @@ static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_devi
 		Chipset=0x3076;
 
 	if (Chipset==0x3076) {
-		IRDA_DEBUG(2, "%s(): Chipset = 3076\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(): Chipset = 3076\n", __func__);
 
 		WriteLPCReg(7,0x0c );
 		temp=ReadLPCReg(0x30);//check if BIOS Enable Fir
@@ -222,7 +222,7 @@ static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_devi
 		} else
 			rc = -ENODEV; //IR not turn on	 
 	} else { //Not VT1211
-		IRDA_DEBUG(2, "%s(): Chipset = 3096\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s(): Chipset = 3096\n", __func__);
 
 		pci_read_config_byte(pcidev,0x67,&bTmp);//check if BIOS Enable Fir
 		if((bTmp&0x01)==1) {  // BIOS enable FIR
@@ -262,7 +262,7 @@ static int __devinit via_init_one (struct pci_dev *pcidev, const struct pci_devi
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
@@ -301,7 +301,7 @@ static void __devexit via_remove_one (struct pci_dev *pdev)
 
 static void __exit via_ircc_cleanup(void)
 {
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	/* FIXME : This should be redundant, as pci_unregister_driver()
 	 * should call via_remove_one() on each device.
@@ -324,7 +324,7 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	struct via_ircc_cb *self;
 	int err;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	if (i >= ARRAY_SIZE(dev_self))
 		return -ENOMEM;
@@ -360,7 +360,7 @@ static __devinit int via_ircc_open(int i, chipio_t * info, unsigned int id)
 	/* Reserve the ioports that we need */
 	if (!request_region(self->io.fir_base, self->io.fir_ext, driver_name)) {
 		IRDA_DEBUG(0, "%s(), can't get iobase of 0x%03x\n",
-			   __FUNCTION__, self->io.fir_base);
+			   __func__, self->io.fir_base);
 		err = -ENODEV;
 		goto err_out1;
 	}
@@ -471,7 +471,7 @@ static int via_ircc_close(struct via_ircc_cb *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
@@ -483,7 +483,7 @@ static int via_ircc_close(struct via_ircc_cb *self)
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(2, "%s(), Releasing Region %03x\n",
-		   __FUNCTION__, self->io.fir_base);
+		   __func__, self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 	if (self->tx_buff.head)
 		dma_free_coherent(NULL, self->tx_buff.truesize,
@@ -509,7 +509,7 @@ static void via_hw_init(struct via_ircc_cb *self)
 {
 	int iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	SetMaxRxPacketSize(iobase, 0x0fff);	//set to max:4095
 	// FIFO Init
@@ -582,7 +582,7 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 	speed = speed;
 
 	IRDA_DEBUG(1, "%s(): change_dongle_speed to %d for 0x%x, %d\n",
-		   __FUNCTION__, speed, iobase, dongle_id);
+		   __func__, speed, iobase, dongle_id);
 
 	switch (dongle_id) {
 
@@ -671,7 +671,7 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 
 	case 0x11:		/* Temic TFDS4500 */
 
-		IRDA_DEBUG(2, "%s: Temic TFDS4500: One RX pin, TX normal, RX inverted.\n", __FUNCTION__);
+		IRDA_DEBUG(2, "%s: Temic TFDS4500: One RX pin, TX normal, RX inverted.\n", __func__);
 
 		UseOneRX(iobase, ON);	//use ONE RX....RX1
 		InvertTX(iobase, OFF);
@@ -689,7 +689,7 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 			SlowIRRXLowActive(iobase, OFF);
 
 		} else{
-			IRDA_DEBUG(0, "%s: Warning: TFDS4500 not running in SIR mode !\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s: Warning: TFDS4500 not running in SIR mode !\n", __func__);
 		}
 		break;
 
@@ -707,7 +707,7 @@ static void via_ircc_change_dongle_speed(int iobase, int speed,
 
 	default:
 		IRDA_ERROR("%s: Error: dongle_id %d unsupported !\n",
-			   __FUNCTION__, dongle_id);
+			   __func__, dongle_id);
 	}
 }
 
@@ -726,7 +726,7 @@ static void via_ircc_change_speed(struct via_ircc_cb *self, __u32 speed)
 	iobase = self->io.fir_base;
 	/* Update accounting for new speed */
 	self->io.speed = speed;
-	IRDA_DEBUG(1, "%s: change_speed to %d bps.\n", __FUNCTION__, speed);
+	IRDA_DEBUG(1, "%s: change_speed to %d bps.\n", __func__, speed);
 
 	WriteReg(iobase, I_ST_CT_0, 0x0);
 
@@ -957,7 +957,7 @@ static int via_ircc_dma_xmit(struct via_ircc_cb *self, u16 iobase)
 			self->tx_buff.head) + self->tx_buff_dma,
 		       self->tx_fifo.queue[self->tx_fifo.ptr].len, DMA_TX_MODE);
 	IRDA_DEBUG(1, "%s: tx_fifo.ptr=%x,len=%x,tx_fifo.len=%x..\n",
-		   __FUNCTION__, self->tx_fifo.ptr,
+		   __func__, self->tx_fifo.ptr,
 		   self->tx_fifo.queue[self->tx_fifo.ptr].len,
 		   self->tx_fifo.len);
 
@@ -981,7 +981,7 @@ static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 	int ret = TRUE;
 	u8 Tx_status;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	iobase = self->io.fir_base;
 	/* Disable DMA */
@@ -1014,7 +1014,7 @@ static int via_ircc_dma_xmit_complete(struct via_ircc_cb *self)
 	}
 	IRDA_DEBUG(1,
 		   "%s: tx_fifo.len=%x ,tx_fifo.ptr=%x,tx_fifo.free=%x...\n",
-		   __FUNCTION__,
+		   __func__,
 		   self->tx_fifo.len, self->tx_fifo.ptr, self->tx_fifo.free);
 /* F01_S
 	// Any frames to be sent back-to-back? 
@@ -1050,7 +1050,7 @@ static int via_ircc_dma_receive(struct via_ircc_cb *self)
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	self->tx_fifo.len = self->tx_fifo.ptr = self->tx_fifo.free = 0;
 	self->tx_fifo.tail = self->tx_buff.head;
@@ -1134,13 +1134,13 @@ static int via_ircc_dma_receive_complete(struct via_ircc_cb *self,
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
@@ -1217,7 +1217,7 @@ static int upload_rxdata(struct via_ircc_cb *self, int iobase)
 
 	len = GetRecvByte(iobase, self);
 
-	IRDA_DEBUG(2, "%s(): len=%x\n", __FUNCTION__, len);
+	IRDA_DEBUG(2, "%s(): len=%x\n", __func__, len);
 
 	if ((len - 4) < 2) {
 		self->stats.rx_dropped++;
@@ -1302,7 +1302,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 			skb_put(skb, len - 4);
 			skb_copy_to_linear_data(skb, self->rx_buff.data, len - 4);
 
-			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __FUNCTION__,
+			IRDA_DEBUG(2, "%s(): len=%x.head=%x\n", __func__,
 				   len - 4, st_fifo->head);
 
 			// Move to next frame 
@@ -1318,7 +1318,7 @@ static int RxTimerHandler(struct via_ircc_cb *self, int iobase)
 
 		IRDA_DEBUG(2,
 			   "%s(): End of upload HostStatus=%x,RxStatus=%x\n",
-			   __FUNCTION__,
+			   __func__,
 			   GetHostStatus(iobase), GetRXStatus(iobase));
 
 		/*
@@ -1358,7 +1358,7 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 	iHostIntType = GetHostStatus(iobase);
 
 	IRDA_DEBUG(4, "%s(): iHostIntType %02x:  %s %s %s  %02x\n",
-		   __FUNCTION__, iHostIntType,
+		   __func__, iHostIntType,
 		   (iHostIntType & 0x40) ? "Timer" : "",
 		   (iHostIntType & 0x20) ? "Tx" : "",
 		   (iHostIntType & 0x10) ? "Rx" : "",
@@ -1388,7 +1388,7 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 		iTxIntType = GetTXStatus(iobase);
 
 		IRDA_DEBUG(4, "%s(): iTxIntType %02x:  %s %s %s %s\n",
-			   __FUNCTION__, iTxIntType,
+			   __func__, iTxIntType,
 			   (iTxIntType & 0x08) ? "FIFO underr." : "",
 			   (iTxIntType & 0x04) ? "EOM" : "",
 			   (iTxIntType & 0x02) ? "FIFO ready" : "",
@@ -1412,7 +1412,7 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 		iRxIntType = GetRXStatus(iobase);
 
 		IRDA_DEBUG(4, "%s(): iRxIntType %02x:  %s %s %s %s %s %s %s\n",
-			   __FUNCTION__, iRxIntType,
+			   __func__, iRxIntType,
 			   (iRxIntType & 0x80) ? "PHY err."	: "",
 			   (iRxIntType & 0x40) ? "CRC err"	: "",
 			   (iRxIntType & 0x20) ? "FIFO overr."	: "",
@@ -1421,7 +1421,7 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 			   (iRxIntType & 0x02) ? "RxMaxLen"	: "",
 			   (iRxIntType & 0x01) ? "SIR bad"	: "");
 		if (!iRxIntType)
-			IRDA_DEBUG(3, "%s(): RxIRQ =0\n", __FUNCTION__);
+			IRDA_DEBUG(3, "%s(): RxIRQ =0\n", __func__);
 
 		if (iRxIntType & 0x10) {
 			if (via_ircc_dma_receive_complete(self, iobase)) {
@@ -1431,7 +1431,7 @@ static irqreturn_t via_ircc_interrupt(int dummy, void *dev_id)
 		}		// No ERR     
 		else {		//ERR
 			IRDA_DEBUG(4, "%s(): RxIRQ ERR:iRxIntType=%x,HostIntType=%x,CurCount=%x,RxLastCount=%x_____\n",
-				   __FUNCTION__, iRxIntType, iHostIntType,
+				   __func__, iRxIntType, iHostIntType,
 				   RxCurCount(iobase, self),
 				   self->RxLastCount);
 
@@ -1456,7 +1456,7 @@ static void hwreset(struct via_ircc_cb *self)
 	int iobase;
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	ResetChip(iobase, 5);
 	EnableDMA(iobase, OFF);
@@ -1501,7 +1501,7 @@ static int via_ircc_is_receiving(struct via_ircc_cb *self)
 	if (CkRxRecv(iobase, self))
 		status = TRUE;
 
-	IRDA_DEBUG(2, "%s(): status=%x....\n", __FUNCTION__, status);
+	IRDA_DEBUG(2, "%s(): status=%x....\n", __func__, status);
 
 	return status;
 }
@@ -1519,7 +1519,7 @@ static int via_ircc_net_open(struct net_device *dev)
 	int iobase;
 	char hwname[32];
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct via_ircc_cb *) dev->priv;
@@ -1585,7 +1585,7 @@ static int via_ircc_net_close(struct net_device *dev)
 	struct via_ircc_cb *self;
 	int iobase;
 
-	IRDA_DEBUG(3, "%s()\n", __FUNCTION__);
+	IRDA_DEBUG(3, "%s()\n", __func__);
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct via_ircc_cb *) dev->priv;
@@ -1627,7 +1627,7 @@ static int via_ircc_net_ioctl(struct net_device *dev, struct ifreq *rq,
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = dev->priv;
 	IRDA_ASSERT(self != NULL, return -1;);
-	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__, dev->name,
+	IRDA_DEBUG(1, "%s(), %s, (cmd=0x%X)\n", __func__, dev->name,
 		   cmd);
 	/* Disable interrupts & save flags */
 	spin_lock_irqsave(&self->lock, flags);
diff --git a/drivers/net/irda/vlsi_ir.c b/drivers/net/irda/vlsi_ir.c
index acd082a..9c9dd11 100644
--- a/drivers/net/irda/vlsi_ir.c
+++ b/drivers/net/irda/vlsi_ir.c
@@ -140,15 +140,15 @@ static void vlsi_ring_debug(struct vlsi_ring *r)
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
@@ -435,7 +435,7 @@ static struct vlsi_ring *vlsi_alloc_ring(struct pci_dev *pdev, struct ring_descr
 		    ||  !(busaddr = pci_map_single(pdev, rd->buf, len, dir))) {
 			if (rd->buf) {
 				IRDA_ERROR("%s: failed to create PCI-MAP for %p",
-					   __FUNCTION__, rd->buf);
+					   __func__, rd->buf);
 				kfree(rd->buf);
 				rd->buf = NULL;
 			}
@@ -489,7 +489,7 @@ static int vlsi_create_hwif(vlsi_irda_dev_t *idev)
 	ringarea = pci_alloc_consistent(idev->pdev, HW_RING_AREA_SIZE, &idev->busaddr);
 	if (!ringarea) {
 		IRDA_ERROR("%s: insufficient memory for descriptor rings\n",
-			   __FUNCTION__);
+			   __func__);
 		goto out;
 	}
 	memset(ringarea, 0, HW_RING_AREA_SIZE);
@@ -564,7 +564,7 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
 	crclen = (idev->mode==IFF_FIR) ? sizeof(u32) : sizeof(u16);
 	len -= crclen;		/* remove trailing CRC */
 	if (len <= 0) {
-		IRDA_DEBUG(0, "%s: strange frame (len=%d)\n", __FUNCTION__, len);
+		IRDA_DEBUG(0, "%s: strange frame (len=%d)\n", __func__, len);
 		ret |= VLSI_RX_DROP;
 		goto done;
 	}
@@ -579,14 +579,14 @@ static int vlsi_process_rx(struct vlsi_ring *r, struct ring_descr *rd)
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
@@ -617,7 +617,7 @@ static void vlsi_fill_rx(struct vlsi_ring *r)
 	for (rd = ring_last(r); rd != NULL; rd = ring_put(r)) {
 		if (rd_is_active(rd)) {
 			IRDA_WARNING("%s: driver bug: rx descr race with hw\n",
-				     __FUNCTION__);
+				     __func__);
 			vlsi_ring_debug(r);
 			break;
 		}
@@ -676,7 +676,7 @@ static void vlsi_rx_interrupt(struct net_device *ndev)
 
 	if (ring_first(r) == NULL) {
 		/* we are in big trouble, if this should ever happen */
-		IRDA_ERROR("%s: rx ring exhausted!\n", __FUNCTION__);
+		IRDA_ERROR("%s: rx ring exhausted!\n", __func__);
 		vlsi_ring_debug(r);
 	}
 	else
@@ -697,7 +697,7 @@ static void vlsi_unarm_rx(vlsi_irda_dev_t *idev)
 		if (rd_is_active(rd)) {
 			rd_set_status(rd, 0);
 			if (rd_get_count(rd)) {
-				IRDA_DEBUG(0, "%s - dropping rx packet\n", __FUNCTION__);
+				IRDA_DEBUG(0, "%s - dropping rx packet\n", __func__);
 				ret = -VLSI_RX_DROP;
 			}
 			rd_set_count(rd, 0);
@@ -772,7 +772,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 	int	fifocnt;
 
 	baudrate = idev->new_baud;
-	IRDA_DEBUG(2, "%s: %d -> %d\n", __FUNCTION__, idev->baud, idev->new_baud);
+	IRDA_DEBUG(2, "%s: %d -> %d\n", __func__, idev->baud, idev->new_baud);
 	if (baudrate == 4000000) {
 		mode = IFF_FIR;
 		config = IRCFG_FIR;
@@ -789,7 +789,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 		switch(baudrate) {
 			default:
 				IRDA_WARNING("%s: undefined baudrate %d - fallback to 9600!\n",
-					     __FUNCTION__, baudrate);
+					     __func__, baudrate);
 				baudrate = 9600;
 				/* fallthru */
 			case 2400:
@@ -806,7 +806,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 
 	fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 	if (fifocnt != 0) {
-		IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __FUNCTION__, fifocnt);
+		IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
 	}
 
 	outw(0, iobase+VLSI_PIO_IRENABLE);
@@ -830,14 +830,14 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
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
@@ -849,7 +849,7 @@ static int vlsi_set_baud(vlsi_irda_dev_t *idev, unsigned iobase)
 	}
 
 	if (ret)
-		vlsi_reg_debug(iobase,__FUNCTION__);
+		vlsi_reg_debug(iobase,__func__);
 
 	return ret;
 }
@@ -982,7 +982,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 		if (len >= r->len-5)
 			 IRDA_WARNING("%s: possible buffer overflow with SIR wrapping!\n",
-				      __FUNCTION__);
+				      __func__);
 	}
 	else {
 		/* hw deals with MIR/FIR mode wrapping */
@@ -1027,7 +1027,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 		fifocnt = inw(ndev->base_addr+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
-			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __FUNCTION__, fifocnt);
+			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n", __func__, fifocnt);
 		}
 
 		config = inw(iobase+VLSI_PIO_IRCFG);
@@ -1040,7 +1040,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 
 	if (ring_put(r) == NULL) {
 		netif_stop_queue(ndev);
-		IRDA_DEBUG(3, "%s: tx ring full - queue stopped\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s: tx ring full - queue stopped\n", __func__);
 	}
 	spin_unlock_irqrestore(&idev->lock, flags);
 
@@ -1049,7 +1049,7 @@ static int vlsi_hard_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 drop_unlock:
 	spin_unlock_irqrestore(&idev->lock, flags);
 drop:
-	IRDA_WARNING("%s: dropping packet - %s\n", __FUNCTION__, msg);
+	IRDA_WARNING("%s: dropping packet - %s\n", __func__, msg);
 	dev_kfree_skb_any(skb);
 	idev->stats.tx_errors++;
 	idev->stats.tx_dropped++;
@@ -1106,7 +1106,7 @@ static void vlsi_tx_interrupt(struct net_device *ndev)
 		fifocnt = inw(iobase+VLSI_PIO_RCVBCNT) & RCVBCNT_MASK;
 		if (fifocnt != 0) {
 			IRDA_DEBUG(0, "%s: rx fifo not empty(%d)\n",
-				__FUNCTION__, fifocnt);
+				__func__, fifocnt);
 		}
 		outw(config | IRCFG_ENTX, iobase+VLSI_PIO_IRCFG);
 	}
@@ -1115,7 +1115,7 @@ static void vlsi_tx_interrupt(struct net_device *ndev)
 
 	if (netif_queue_stopped(ndev)  &&  !idev->new_baud) {
 		netif_wake_queue(ndev);
-		IRDA_DEBUG(3, "%s: queue awoken\n", __FUNCTION__);
+		IRDA_DEBUG(3, "%s: queue awoken\n", __func__);
 	}
 }
 
@@ -1138,7 +1138,7 @@ static void vlsi_unarm_tx(vlsi_irda_dev_t *idev)
 				dev_kfree_skb_any(rd->skb);
 				rd->skb = NULL;
 			}
-			IRDA_DEBUG(0, "%s - dropping tx packet\n", __FUNCTION__);
+			IRDA_DEBUG(0, "%s - dropping tx packet\n", __func__);
 			ret = -VLSI_TX_DROP;
 		}
 		else
@@ -1188,7 +1188,7 @@ static int vlsi_start_clock(struct pci_dev *pdev)
 		if (count < 3) {
 			if (clksrc == 1) { /* explicitly asked for PLL hence bail out */
 				IRDA_ERROR("%s: no PLL or failed to lock!\n",
-					   __FUNCTION__);
+					   __func__);
 				clkctl = CLKCTL_CLKSTP;
 				pci_write_config_byte(pdev, VLSI_PCI_CLKCTL, clkctl);
 				return -1;
@@ -1197,7 +1197,7 @@ static int vlsi_start_clock(struct pci_dev *pdev)
 				clksrc = 3;	/* fallback to 40MHz XCLK (OB800) */
 
 			IRDA_DEBUG(0, "%s: PLL not locked, fallback to clksrc=%d\n",
-				__FUNCTION__, clksrc);
+				__func__, clksrc);
 		}
 		else
 			clksrc = 1;	/* got successful PLL lock */
@@ -1269,7 +1269,7 @@ static int vlsi_init_chip(struct pci_dev *pdev)
 	/* start the clock and clean the registers */
 
 	if (vlsi_start_clock(pdev)) {
-		IRDA_ERROR("%s: no valid clock source\n", __FUNCTION__);
+		IRDA_ERROR("%s: no valid clock source\n", __func__);
 		return -1;
 	}
 	iobase = ndev->base_addr;
@@ -1386,7 +1386,7 @@ static void vlsi_tx_timeout(struct net_device *ndev)
 	vlsi_irda_dev_t *idev = ndev->priv;
 
 
-	vlsi_reg_debug(ndev->base_addr, __FUNCTION__);
+	vlsi_reg_debug(ndev->base_addr, __func__);
 	vlsi_ring_debug(idev->tx_ring);
 
 	if (netif_running(ndev))
@@ -1401,7 +1401,7 @@ static void vlsi_tx_timeout(struct net_device *ndev)
 
 	if (vlsi_start_hw(idev))
 		IRDA_ERROR("%s: failed to restart hw - %s(%s) unusable!\n",
-			   __FUNCTION__, pci_name(idev->pdev), ndev->name);
+			   __func__, pci_name(idev->pdev), ndev->name);
 	else
 		netif_start_queue(ndev);
 }
@@ -1446,7 +1446,7 @@ static int vlsi_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
 			break;
 		default:
 			IRDA_WARNING("%s: notsupp - cmd=%04x\n",
-				     __FUNCTION__, cmd);
+				     __func__, cmd);
 			ret = -EOPNOTSUPP;
 	}	
 	
@@ -1491,7 +1491,7 @@ static irqreturn_t vlsi_interrupt(int irq, void *dev_instance)
 
 	if (boguscount <= 0)
 		IRDA_MESSAGE("%s: too much work in interrupt!\n",
-			     __FUNCTION__);
+			     __func__);
 	return IRQ_RETVAL(handled);
 }
 
@@ -1504,7 +1504,7 @@ static int vlsi_open(struct net_device *ndev)
 	char	hwname[32];
 
 	if (pci_request_regions(idev->pdev, drivername)) {
-		IRDA_WARNING("%s: io resource busy\n", __FUNCTION__);
+		IRDA_WARNING("%s: io resource busy\n", __func__);
 		goto errout;
 	}
 	ndev->base_addr = pci_resource_start(idev->pdev,0);
@@ -1519,7 +1519,7 @@ static int vlsi_open(struct net_device *ndev)
 	if (request_irq(ndev->irq, vlsi_interrupt, IRQF_SHARED,
 			drivername, ndev)) {
 		IRDA_WARNING("%s: couldn't get IRQ: %d\n",
-			     __FUNCTION__, ndev->irq);
+			     __func__, ndev->irq);
 		goto errout_io;
 	}
 
@@ -1540,7 +1540,7 @@ static int vlsi_open(struct net_device *ndev)
 
 	netif_start_queue(ndev);
 
-	IRDA_MESSAGE("%s: device %s operational\n", __FUNCTION__, ndev->name);
+	IRDA_MESSAGE("%s: device %s operational\n", __func__, ndev->name);
 
 	return 0;
 
@@ -1574,7 +1574,7 @@ static int vlsi_close(struct net_device *ndev)
 
 	pci_release_regions(idev->pdev);
 
-	IRDA_MESSAGE("%s: device %s stopped\n", __FUNCTION__, ndev->name);
+	IRDA_MESSAGE("%s: device %s stopped\n", __func__, ndev->name);
 
 	return 0;
 }
@@ -1593,7 +1593,7 @@ static int vlsi_irda_init(struct net_device *ndev)
 
 	if (pci_set_dma_mask(pdev,DMA_MASK_USED_BY_HW)
 	    || pci_set_dma_mask(pdev,DMA_MASK_MSTRPAGE)) {
-		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __FUNCTION__);
+		IRDA_ERROR("%s: aborting due to PCI BM-DMA address limitations\n", __func__);
 		return -1;
 	}
 
@@ -1645,14 +1645,14 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
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
 
@@ -1667,7 +1667,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto out_freedev;
 
 	if (register_netdev(ndev) < 0) {
-		IRDA_ERROR("%s: register_netdev failed\n", __FUNCTION__);
+		IRDA_ERROR("%s: register_netdev failed\n", __func__);
 		goto out_freedev;
 	}
 
@@ -1677,7 +1677,7 @@ vlsi_irda_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		ent = create_proc_entry(ndev->name, S_IFREG|S_IRUGO, vlsi_proc_root);
 		if (!ent) {
 			IRDA_WARNING("%s: failed to create proc entry\n",
-				     __FUNCTION__);
+				     __func__);
 		} else {
 			ent->data = ndev;
 			ent->proc_fops = VLSI_PROC_FOPS;
@@ -1746,7 +1746,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	if (!ndev) {
 		IRDA_ERROR("%s - %s: no netdevice \n",
-			   __FUNCTION__, pci_name(pdev));
+			   __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = ndev->priv;	
@@ -1757,7 +1757,7 @@ static int vlsi_irda_suspend(struct pci_dev *pdev, pm_message_t state)
 			pdev->current_state = state.event;
 		}
 		else
-			IRDA_ERROR("%s - %s: invalid suspend request %u -> %u\n", __FUNCTION__, pci_name(pdev), pdev->current_state, state.event);
+			IRDA_ERROR("%s - %s: invalid suspend request %u -> %u\n", __func__, pci_name(pdev), pdev->current_state, state.event);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
@@ -1785,7 +1785,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 
 	if (!ndev) {
 		IRDA_ERROR("%s - %s: no netdevice \n",
-			   __FUNCTION__, pci_name(pdev));
+			   __func__, pci_name(pdev));
 		return 0;
 	}
 	idev = ndev->priv;	
@@ -1793,7 +1793,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 	if (pdev->current_state == 0) {
 		mutex_unlock(&idev->mtx);
 		IRDA_WARNING("%s - %s: already resumed\n",
-			     __FUNCTION__, pci_name(pdev));
+			     __func__, pci_name(pdev));
 		return 0;
 	}
 	
@@ -1812,7 +1812,7 @@ static int vlsi_irda_resume(struct pci_dev *pdev)
 		 * now we explicitly set pdev->current_state = 0 after enabling the
 		 * device and independently resume_ok should catch any garbage config.
 		 */
-		IRDA_WARNING("%s - hm, nothing to resume?\n", __FUNCTION__);
+		IRDA_WARNING("%s - hm, nothing to resume?\n", __func__);
 		mutex_unlock(&idev->mtx);
 		return 0;
 	}
diff --git a/drivers/net/irda/vlsi_ir.h b/drivers/net/irda/vlsi_ir.h
index c8b9c74..9b18843 100644
--- a/drivers/net/irda/vlsi_ir.h
+++ b/drivers/net/irda/vlsi_ir.h
@@ -617,7 +617,7 @@ static inline void rd_set_addr_status(struct ring_descr *rd, dma_addr_t a, u8 s)
 	 */
 
 	if ((a & ~DMA_MASK_MSTRPAGE)>>24 != MSTRPAGE_VALUE) {
-		IRDA_ERROR("%s: pci busaddr inconsistency!\n", __FUNCTION__);
+		IRDA_ERROR("%s: pci busaddr inconsistency!\n", __func__);
 		dump_stack();
 		return;
 	}
diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 9fd2451..5f28320 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -114,7 +114,7 @@ static int __init w83977af_init(void)
 {
         int i;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	for (i=0; (io[i] < 2000) && (i < ARRAY_SIZE(dev_self)); i++) {
 		if (w83977af_open(i, io[i], irq[i], dma[i]) == 0)
@@ -133,7 +133,7 @@ static void __exit w83977af_cleanup(void)
 {
 	int i;
 
-        IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+        IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	for (i=0; i < ARRAY_SIZE(dev_self); i++) {
 		if (dev_self[i])
@@ -154,12 +154,12 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
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
 
@@ -241,7 +241,7 @@ int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 
 	err = register_netdev(dev);
 	if (err) {
-		IRDA_ERROR("%s(), register_netdevice() failed!\n", __FUNCTION__);
+		IRDA_ERROR("%s(), register_netdevice() failed!\n", __func__);
 		goto err_out3;
 	}
 	IRDA_MESSAGE("IrDA: Registered device %s\n", dev->name);
@@ -273,7 +273,7 @@ static int w83977af_close(struct w83977af_ir *self)
 {
 	int iobase;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
         iobase = self->io.fir_base;
 
@@ -294,7 +294,7 @@ static int w83977af_close(struct w83977af_ir *self)
 
 	/* Release the PORT that this driver is using */
 	IRDA_DEBUG(0 , "%s(), Releasing Region %03x\n", 
-	      __FUNCTION__ , self->io.fir_base);
+	      __func__ , self->io.fir_base);
 	release_region(self->io.fir_base, self->io.fir_ext);
 
 	if (self->tx_buff.head)
@@ -316,7 +316,7 @@ int w83977af_probe( int iobase, int irq, int dma)
 	int i;
   	
  	for (i=0; i < 2; i++) {
- 		IRDA_DEBUG( 0, "%s()\n", __FUNCTION__ );
+ 		IRDA_DEBUG( 0, "%s()\n", __func__ );
 #ifdef CONFIG_USE_W977_PNP
  		/* Enter PnP configuration mode */
 		w977_efm_enter(efbase[i]);
@@ -403,7 +403,7 @@ int w83977af_probe( int iobase, int irq, int dma)
 			return 0;
 		} else {
 			/* Try next extented function register address */
-			IRDA_DEBUG( 0, "%s(), Wrong chip version", __FUNCTION__ );
+			IRDA_DEBUG( 0, "%s(), Wrong chip version", __func__ );
 		}
   	}   	
 	return -1;
@@ -439,19 +439,19 @@ void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
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
 
@@ -501,7 +501,7 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	iobase = self->io.fir_base;
 
-	IRDA_DEBUG(4, "%s(%ld), skb->len=%d\n", __FUNCTION__ , jiffies, 
+	IRDA_DEBUG(4, "%s(%ld), skb->len=%d\n", __func__ , jiffies, 
 		   (int) skb->len);
 	
 	/* Lock transmit buffer */
@@ -549,7 +549,7 @@ int w83977af_hard_xmit(struct sk_buff *skb, struct net_device *dev)
 			outb(ICR_ETMRI, iobase+ICR);
 		} else {
 #endif
-			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __FUNCTION__ , jiffies, mtt);
+			IRDA_DEBUG(4, "%s(%ld), mtt=%d\n", __func__ , jiffies, mtt);
 			if (mtt)
 				udelay(mtt);
 
@@ -591,7 +591,7 @@ static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 	unsigned long flags;
 	__u8 hcr;
 #endif
-        IRDA_DEBUG(4, "%s(), len=%d\n", __FUNCTION__ , self->tx_buff.len);
+        IRDA_DEBUG(4, "%s(), len=%d\n", __func__ , self->tx_buff.len);
 
 	/* Save current set */
 	set = inb(iobase+SSR);
@@ -643,7 +643,7 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	int actual = 0;
 	__u8 set;
 	
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	/* Save current bank */
 	set = inb(iobase+SSR);
@@ -651,11 +651,11 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
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
@@ -665,7 +665,7 @@ static int w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size)
 	}
         
 	IRDA_DEBUG(4, "%s(), fifo_size %d ; %d sent of %d\n", 
-		   __FUNCTION__ , fifo_size, actual, len);
+		   __func__ , fifo_size, actual, len);
 
 	/* Restore bank */
 	outb(set, iobase+SSR);
@@ -685,7 +685,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(4, "%s(%ld)\n", __FUNCTION__ , jiffies);
+	IRDA_DEBUG(4, "%s(%ld)\n", __func__ , jiffies);
 
 	IRDA_ASSERT(self != NULL, return;);
 
@@ -700,7 +700,7 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	
 	/* Check for underrrun! */
 	if (inb(iobase+AUDR) & AUDR_UNDR) {
-		IRDA_DEBUG(0, "%s(), Transmit underrun!\n", __FUNCTION__ );
+		IRDA_DEBUG(0, "%s(), Transmit underrun!\n", __func__ );
 		
 		self->stats.tx_errors++;
 		self->stats.tx_fifo_errors++;
@@ -741,7 +741,7 @@ int w83977af_dma_receive(struct w83977af_ir *self)
 #endif
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s\n", __func__ );
 
 	iobase= self->io.fir_base;
 
@@ -812,7 +812,7 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 	__u8 set;
 	__u8 status;
 
-	IRDA_DEBUG(4, "%s\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s\n", __func__ );
 
 	st_fifo = &self->st_fifo;
 
@@ -892,7 +892,7 @@ int w83977af_dma_receive_complete(struct w83977af_ir *self)
 			skb = dev_alloc_skb(len+1);
 			if (skb == NULL)  {
 				printk(KERN_INFO
-				       "%s(), memory squeeze, dropping frame.\n", __FUNCTION__);
+				       "%s(), memory squeeze, dropping frame.\n", __func__);
 				/* Restore set register */
 				outb(set, iobase+SSR);
 
@@ -943,7 +943,7 @@ static void w83977af_pio_receive(struct w83977af_ir *self)
 	__u8 byte = 0x00;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(4, "%s()\n", __func__ );
 
 	IRDA_ASSERT(self != NULL, return;);
 	
@@ -970,7 +970,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 	__u8 set;
 	int iobase;
 
-	IRDA_DEBUG(4, "%s(), isr=%#x\n", __FUNCTION__ , isr);
+	IRDA_DEBUG(4, "%s(), isr=%#x\n", __func__ , isr);
 	
 	iobase = self->io.fir_base;
 	/* Transmit FIFO low on data */
@@ -1007,7 +1007,7 @@ static __u8 w83977af_sir_interrupt(struct w83977af_ir *self, int isr)
 		/* Check if we need to change the speed? */
 		if (self->new_speed) {
 			IRDA_DEBUG(2,
-				   "%s(), Changing speed!\n", __FUNCTION__ );
+				   "%s(), Changing speed!\n", __func__ );
 			w83977af_change_speed(self, self->new_speed);
 			self->new_speed = 0;
 		}
@@ -1189,7 +1189,7 @@ static int w83977af_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 set;
 	
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 	
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = (struct w83977af_ir *) dev->priv;
@@ -1252,7 +1252,7 @@ static int w83977af_net_close(struct net_device *dev)
 	int iobase;
 	__u8 set;
 
-	IRDA_DEBUG(0, "%s()\n", __FUNCTION__ );
+	IRDA_DEBUG(0, "%s()\n", __func__ );
 
 	IRDA_ASSERT(dev != NULL, return -1;);
 	
@@ -1307,7 +1307,7 @@ static int w83977af_net_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	IRDA_ASSERT(self != NULL, return -1;);
 
-	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __FUNCTION__ , dev->name, cmd);
+	IRDA_DEBUG(2, "%s(), %s, (cmd=0x%X)\n", __func__ , dev->name, cmd);
 	
 	spin_lock_irqsave(&self->lock, flags);
 
diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index 3d2e721..a264309 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -85,7 +85,7 @@ struct ixgb_adapter;
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	(void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args))
+		__func__ , ## args))
 
 
 /* TX/RX descriptor defines */
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index d0bf206..986fb49 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -43,7 +43,7 @@
 #define DPRINTK(nlevel, klevel, fmt, args...) \
 	((void)((NETIF_MSG_##nlevel & adapter->msg_enable) && \
 	printk(KERN_##klevel PFX "%s: %s: " fmt, adapter->netdev->name, \
-		__FUNCTION__ , ## args)))
+		__func__ , ## args)))
 
 /* TX/RX descriptor defines */
 #define IXGBE_DEFAULT_TXD		   1024
diff --git a/drivers/net/meth.c b/drivers/net/meth.c
index cdaa8fc..618c4e5 100644
--- a/drivers/net/meth.c
+++ b/drivers/net/meth.c
@@ -41,7 +41,7 @@
 #endif
 
 #if MFE_DEBUG>=1
-#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __FUNCTION__ , ## args)
+#define DPRINTK(str,args...) printk(KERN_DEBUG "meth: %s: " str, __func__ , ## args)
 #define MFE_RX_DEBUG 2
 #else
 #define DPRINTK(str,args...)
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 6d343ef..4e7a5fa 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -203,7 +203,7 @@ static irqreturn_t mipsnet_interrupt(int irq, void *dev_id)
 
 out_badirq:
 	printk(KERN_INFO "%s: %s(): irq %d for unknown device\n",
-	       dev->name, __FUNCTION__, irq);
+	       dev->name, __func__, irq);
 	return ret;
 }
 
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index 78d34af..cb14eee 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -190,7 +190,7 @@ netx_eth_interrupt(int irq, void *dev_id)
 
 		if ((status & ISR_CON_HI) || (status & ISR_IND_HI))
 			printk("%s: unexpected status: 0x%08x\n",
-			    __FUNCTION__, status);
+			    __func__, status);
 
 		fill_level =
 		    readl(NETX_PFIFO_FILL_LEVEL(IND_FIFO_PORT_LO(priv->id)));
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 2bc5eaa..6c70c09 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -712,7 +712,7 @@ extern char netxen_nic_driver_name[];
 	} while (0)
 #else
 #define DPRINTK(klevel, fmt, args...)	do { \
-	printk(KERN_##klevel PFX "%s: %s: " fmt, __FUNCTION__,\
+	printk(KERN_##klevel PFX "%s: %s: " fmt, __func__,\
 		(adapter != NULL && adapter->netdev != NULL) ? \
 		adapter->netdev->name : NULL, \
 		## args); } while(0)
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 0135570..0df9d59 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -690,7 +690,7 @@ void netxen_nic_pci_change_crbwindow(struct netxen_adapter *adapter, u32 wndw)
 	while ((tmp = readl(offset)) != wndw) {
 		printk(KERN_WARNING "%s: %s WARNING: CRB window value not "
 		       "registered properly: 0x%08x.\n",
-		       netxen_nic_driver_name, __FUNCTION__, tmp);
+		       netxen_nic_driver_name, __func__, tmp);
 		mdelay(1);
 		if (count >= 10)
 			break;
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 9e38bcb..ce999e8 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -804,7 +804,7 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				       " in ROM.\n", netxen_nic_driver_name, n);
 		} else {
 			printk("%s:n=0x%x Error! NetXen card flash not"
-			       " initialized.\n", __FUNCTION__, n);
+			       " initialized.\n", __func__, n);
 			return -EIO;
 		}
 		buf = kcalloc(n, sizeof(struct crb_addr_pair), GFP_KERNEL);
@@ -921,7 +921,7 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 				 &adapter->dummy_dma.phys_addr);
 	if (adapter->dummy_dma.addr == NULL) {
 		printk("%s: ERROR: Could not allocate dummy DMA memory\n",
-		       __FUNCTION__);
+		       __func__);
 		return -ENOMEM;
 	}
 
@@ -1359,7 +1359,7 @@ int netxen_process_cmd_ring(unsigned long data)
 
 	spin_unlock(&adapter->tx_lock);
 	DPRINTK(INFO, "last consumer is %d in %s\n", last_consumer,
-		__FUNCTION__);
+		__func__);
 	return (done);
 }
 
diff --git a/drivers/net/netxen/netxen_nic_isr.c b/drivers/net/netxen/netxen_nic_isr.c
index 48a404a..81f32d6 100644
--- a/drivers/net/netxen/netxen_nic_isr.c
+++ b/drivers/net/netxen/netxen_nic_isr.c
@@ -183,7 +183,7 @@ int netxen_nic_link_ok(struct netxen_adapter *adapter)
 
 	default:
 		printk(KERN_ERR"%s: Function: %s, Unknown board type\n",
-			netxen_nic_driver_name, __FUNCTION__);
+			netxen_nic_driver_name, __func__);
 		break;
 	}
 
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index fffc49b..5220578 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -119,7 +119,7 @@ KERN_INFO "  Support available from http://foo.com/bar/baz.html\n";
 
 #ifdef NETDRV_DEBUG
 /* note: prints function name for you */
-#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __FUNCTION__ , ## args)
+#  define DPRINTK(fmt, args...) printk(KERN_DEBUG "%s: " fmt, __func__ , ## args)
 #else
 #  define DPRINTK(fmt, args...)
 #endif
@@ -130,7 +130,7 @@ KERN_INFO "  Support available from http://foo.com/bar/baz.html\n";
 #  define assert(expr) \
         if(!(expr)) {					\
         printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-        #expr,__FILE__,__FUNCTION__,__LINE__);		\
+        #expr,__FILE__,__func__,__LINE__);		\
         }
 #endif
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3acfeea..8a90ba8 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -42,7 +42,7 @@
 #define assert(expr) \
 	if (!(expr)) {					\
 		printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
-		#expr,__FILE__,__FUNCTION__,__LINE__);		\
+		#expr,__FILE__,__func__,__LINE__);		\
 	}
 #define dprintk(fmt, args...) \
 	do { printk(KERN_DEBUG PFX fmt, ## args); } while (0)
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6179a0a..5e686f6 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3032,7 +3032,7 @@ static void tx_intr_handler(struct fifo_info *fifo_data)
 		if (skb == NULL) {
 			spin_unlock_irqrestore(&fifo_data->tx_lock, flags);
 			DBG_PRINT(ERR_DBG, "%s: Null skb ",
-			__FUNCTION__);
+			__func__);
 			DBG_PRINT(ERR_DBG, "in Tx Free Intr\n");
 			return;
 		}
@@ -3392,7 +3392,7 @@ static void s2io_reset(struct s2io_nic * sp)
 	unsigned long long mem_alloc_cnt, mem_free_cnt, watchdog_cnt;
 
 	DBG_PRINT(INIT_DBG,"%s - Resetting XFrame card %s\n",
-			__FUNCTION__, sp->dev->name);
+			__func__, sp->dev->name);
 
 	/* Back up  the PCI-X CMD reg, dont want to lose MMRBC, OST settings */
 	pci_read_config_word(sp->pdev, PCIX_COMMAND_REGISTER, &(pci_cmd));
@@ -3414,7 +3414,7 @@ static void s2io_reset(struct s2io_nic * sp)
 	}
 
 	if (check_pci_device_id(val16) == (u16)PCI_ANY_ID) {
-		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __FUNCTION__);
+		DBG_PRINT(ERR_DBG,"%s SW_Reset failed!\n", __func__);
 	}
 
 	pci_write_config_word(sp->pdev, PCIX_COMMAND_REGISTER, pci_cmd);
@@ -3659,7 +3659,7 @@ static void restore_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(7) | s2BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 	}
@@ -3676,7 +3676,7 @@ static void store_xmsi_data(struct s2io_nic *nic)
 		val64 = (s2BIT(15) | vBIT(i, 26, 6));
 		writeq(val64, &bar0->xmsi_access);
 		if (wait_for_msix_trans(nic, i)) {
-			DBG_PRINT(ERR_DBG, "failed in %s\n", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "failed in %s\n", __func__);
 			continue;
 		}
 		addr = readq(&bar0->xmsi_address);
@@ -3699,7 +3699,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 			       GFP_KERNEL);
 	if (!nic->entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n", \
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		return -ENOMEM;
 	}
@@ -3711,7 +3711,7 @@ static int s2io_enable_msi_x(struct s2io_nic *nic)
 				   GFP_KERNEL);
 	if (!nic->s2io_entries) {
 		DBG_PRINT(INFO_DBG, "%s: Memory allocation failed\n",
-			__FUNCTION__);
+			__func__);
 		nic->mac_control.stats_info->sw_stat.mem_alloc_fail_cnt++;
 		kfree(nic->entries);
 		nic->mac_control.stats_info->sw_stat.mem_freed
@@ -4202,11 +4202,11 @@ static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
 
 		if ((level == PANIC) && (!TASKLET_IN_USE)) {
 			int ret;
-			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __FUNCTION__);
+			DBG_PRINT(INTR_DBG, "%s: Rx BD hit ", __func__);
 			DBG_PRINT(INTR_DBG, "PANIC levels\n");
 			if ((ret = fill_rx_buffers(sp, rng_n)) == -ENOMEM) {
 				DBG_PRINT(INFO_DBG, "Out of memory in %s",
-					  __FUNCTION__);
+					  __func__);
 				clear_bit(0, (&sp->tasklet_status));
 				return -1;
 			}
@@ -6579,7 +6579,7 @@ static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 		ret = s2io_card_up(sp);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Device bring up failed\n",
-				  __FUNCTION__);
+				  __func__);
 			return ret;
 		}
 		if (netif_queue_stopped(dev))
@@ -7397,7 +7397,7 @@ static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t * rxdp)
 					default:
 						DBG_PRINT(ERR_DBG,
 							"%s: Samadhana!!\n",
-							 __FUNCTION__);
+							 __func__);
 						BUG();
 				}
 			}
@@ -7642,7 +7642,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		return -ENOMEM;
 	}
 	if ((ret = pci_request_regions(pdev, s2io_driver_name))) {
-		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __FUNCTION__, ret);
+		DBG_PRINT(ERR_DBG, "%s: Request Regions failed - %x \n", __func__, ret);
 		pci_disable_device(pdev);
 		return -ENODEV;
 	}
@@ -7830,7 +7830,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		mode = s2io_verify_pci_mode(sp);
 		if (mode < 0) {
-			DBG_PRINT(ERR_DBG, "%s: ", __FUNCTION__);
+			DBG_PRINT(ERR_DBG, "%s: ", __func__);
 			DBG_PRINT(ERR_DBG, " Unsupported PCI bus mode\n");
 			ret = -EBADSLT;
 			goto set_swap_failed;
@@ -8068,7 +8068,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 
 	if (!(rxdp->Control_1 & RXD_FRAME_PROTO_TCP)) {
 		DBG_PRINT(INIT_DBG,"%s: Non-TCP frames not supported for LRO\n",
-			  __FUNCTION__);
+			  __func__);
 		return -1;
 	}
 
@@ -8098,7 +8098,7 @@ static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
 static int check_for_socket_match(struct lro *lro, struct iphdr *ip,
 				  struct tcphdr *tcp)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	if ((lro->iph->saddr != ip->saddr) || (lro->iph->daddr != ip->daddr) ||
 	   (lro->tcph->source != tcp->source) || (lro->tcph->dest != tcp->dest))
 		return -1;
@@ -8113,7 +8113,7 @@ static inline int get_l4_pyld_length(struct iphdr *ip, struct tcphdr *tcp)
 static void initiate_new_session(struct lro *lro, u8 *l2h,
 		     struct iphdr *ip, struct tcphdr *tcp, u32 tcp_pyld_len)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->l2h = l2h;
 	lro->iph = ip;
 	lro->tcph = tcp;
@@ -8142,7 +8142,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 	struct tcphdr *tcp = lro->tcph;
 	__sum16 nchk;
 	struct stat_block *statinfo = sp->mac_control.stats_info;
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	/* Update L3 header */
 	ip->tot_len = htons(lro->total_len);
@@ -8170,7 +8170,7 @@ static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
 static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
 		struct tcphdr *tcp, u32 l4_pyld)
 {
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 	lro->total_len += l4_pyld;
 	lro->frags_len += l4_pyld;
 	lro->tcp_next_seq += l4_pyld;
@@ -8194,7 +8194,7 @@ static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr *ip,
 {
 	u8 *ptr;
 
-	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
+	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __func__);
 
 	if (!tcp_pyld_len) {
 		/* Runt frame or a pure ack */
@@ -8274,7 +8274,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 
 			if ((*lro)->tcp_next_seq != ntohl(tcph->seq)) {
 				DBG_PRINT(INFO_DBG, "%s:Out of order. expected "
-					  "0x%x, actual 0x%x\n", __FUNCTION__,
+					  "0x%x, actual 0x%x\n", __func__,
 					  (*lro)->tcp_next_seq,
 					  ntohl(tcph->seq));
 
@@ -8314,7 +8314,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 
 	if (ret == 0) { /* sessions exceeded */
 		DBG_PRINT(INFO_DBG,"%s:All LRO sessions already in use\n",
-			  __FUNCTION__);
+			  __func__);
 		*lro = NULL;
 		return ret;
 	}
@@ -8335,7 +8335,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro **lro,
 			break;
 		default:
 			DBG_PRINT(ERR_DBG,"%s:Dont know, can't say!!\n",
-				__FUNCTION__);
+				__func__);
 			break;
 	}
 
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 76cc1d3..148de86 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -233,7 +233,7 @@ static void smc911x_reset(struct net_device *dev)
 	unsigned int reg, timeout=0, resets=1;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*	 Take out of PM setting first */
 	if ((SMC_GET_PMT_CTRL() & PMT_CTRL_READY_) == 0) {
@@ -323,7 +323,7 @@ static void smc911x_enable(struct net_device *dev)
 	unsigned mask, cfg, cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	SMC_SET_MAC_ADDR(dev->dev_addr);
 
@@ -381,7 +381,7 @@ static void smc911x_shutdown(struct net_device *dev)
 	unsigned cr;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", CARDNAME, __func__);
 
 	/* Disable IRQ's */
 	SMC_SET_INT_EN(0);
@@ -400,7 +400,7 @@ static inline void smc911x_drop_pkt(struct net_device *dev)
 	unsigned long ioaddr = dev->base_addr;
 	unsigned int fifo_count, timeout, reg;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n", CARDNAME, __func__);
 	fifo_count = SMC_GET_RX_FIFO_INF() & 0xFFFF;
 	if (fifo_count <= 4) {
 		/* Manually dump the packet data */
@@ -434,7 +434,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	unsigned char *data;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_RX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 	status = SMC_GET_RX_STS_FIFO();
 	DBG(SMC_DEBUG_RX, "%s: Rx pkt len %d status 0x%08x \n",
 		dev->name, (status & 0x3fff0000) >> 16, status & 0xc000ffff);
@@ -514,7 +514,7 @@ static void smc911x_hardware_send_pkt(struct net_device *dev)
 	unsigned char *buf;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n", dev->name, __func__);
 	BUG_ON(lp->pending_tx_skb == NULL);
 
 	skb = lp->pending_tx_skb;
@@ -579,7 +579,7 @@ static int smc911x_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned long flags;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -652,7 +652,7 @@ static void smc911x_tx(struct net_device *dev)
 	unsigned int tx_status;
 
 	DBG(SMC_DEBUG_FUNC | SMC_DEBUG_TX, "%s: --> %s\n",
-		dev->name, __FUNCTION__);
+		dev->name, __func__);
 
 	/* Collect the TX status */
 	while (((SMC_GET_TX_FIFO_INF() & TX_FIFO_INF_TSUSED_) >> 16) != 0) {
@@ -703,7 +703,7 @@ static int smc911x_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 	SMC_GET_MII(phyreg, phyaddr, phydata);
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%02x, phydata=0x%04x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 	return phydata;
 }
 
@@ -717,7 +717,7 @@ static void smc911x_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 	unsigned long ioaddr = dev->base_addr;
 
 	DBG(SMC_DEBUG_MISC, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SET_MII(phyreg, phyaddr, phydata);
 }
@@ -733,7 +733,7 @@ static void smc911x_phy_detect(struct net_device *dev)
 	int phyaddr;
 	unsigned int cfg, id1, id2;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -804,7 +804,7 @@ static int smc911x_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	SMC_GET_PHY_BMCR(phyaddr, bmcr);
@@ -852,7 +852,7 @@ static int smc911x_phy_reset(struct net_device *dev, int phy)
 	unsigned long flags;
 	unsigned int reg;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	reg = SMC_GET_PMT_CTRL();
@@ -912,7 +912,7 @@ static void smc911x_phy_check_media(struct net_device *dev, int init)
 	int phyaddr = lp->mii.phy_id;
 	unsigned int bmcr, cr;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (mii_check_media(&lp->mii, netif_msg_link(lp), init)) {
 		/* duplex state has changed */
@@ -953,7 +953,7 @@ static void smc911x_phy_configure(struct work_struct *work)
 	int status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s()\n", dev->name, __func__);
 
 	/*
 	 * We should not be called if phy_type is zero.
@@ -1049,7 +1049,7 @@ static void smc911x_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int status;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1078,7 +1078,7 @@ static irqreturn_t smc911x_interrupt(int irq, void *dev_id)
 	unsigned int rx_overrun=0, cr, pkts;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1253,7 +1253,7 @@ smc911x_tx_dma_irq(int dma, void *data)
 	struct sk_buff *skb = lp->current_tx_skb;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	DBG(SMC_DEBUG_TX | SMC_DEBUG_DMA, "%s: TX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
@@ -1289,7 +1289,7 @@ smc911x_rx_dma_irq(int dma, void *data)
 	unsigned long flags;
 	unsigned int pkts;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	DBG(SMC_DEBUG_RX | SMC_DEBUG_DMA, "%s: RX DMA irq handler\n", dev->name);
 	/* Clear the DMA interrupt sources */
 	SMC_DMA_ACK_IRQ(dev, dma);
@@ -1338,7 +1338,7 @@ static void smc911x_timeout(struct net_device *dev)
 	int status, mask;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	status = SMC_GET_INT();
@@ -1380,7 +1380,7 @@ static void smc911x_set_multicast_list(struct net_device *dev)
 	unsigned int mcr, update_multicast = 0;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	spin_lock_irqsave(&lp->lock, flags);
 	SMC_GET_MAC_CR(mcr);
@@ -1482,7 +1482,7 @@ smc911x_open(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1490,7 +1490,7 @@ smc911x_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1519,7 +1519,7 @@ static int smc911x_close(struct net_device *dev)
 {
 	struct smc911x_local *lp = netdev_priv(dev);
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1562,7 +1562,7 @@ smc911x_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 	int ret, status;
 	unsigned long flags;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 	cmd->maxtxpkt = 1;
 	cmd->maxrxpkt = 1;
 
@@ -1701,7 +1701,7 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 	for(timeout=10;(e2p_cmd & E2P_CMD_EPC_BUSY_) && timeout; timeout--) {
 		if (e2p_cmd & E2P_CMD_EPC_TIMEOUT_) {
 			PRINTK("%s: %s timeout waiting for EEPROM to respond\n",
-				dev->name, __FUNCTION__);
+				dev->name, __func__);
 			return -EFAULT;
 		}
 		mdelay(1);
@@ -1709,7 +1709,7 @@ static int smc911x_ethtool_wait_eeprom_ready(struct net_device *dev)
 	}
 	if (timeout == 0) {
 		PRINTK("%s: %s timeout waiting for EEPROM CMD not busy\n",
-			dev->name, __FUNCTION__);
+			dev->name, __func__);
 		return -ETIMEDOUT;
 	}
 	return 0;
@@ -1821,7 +1821,7 @@ static int __init smc911x_findirq(unsigned long ioaddr)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 
 	cookie = probe_irq_on();
 
@@ -1886,7 +1886,7 @@ static int __init smc911x_probe(struct net_device *dev, unsigned long ioaddr)
 	unsigned int val, chip_id, revision;
 	const char *version_string;
 
-	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "%s: --> %s\n", dev->name, __func__);
 
 	/* First, see if the endian word is recognized */
 	val = SMC_GET_BYTE_TEST();
@@ -2130,7 +2130,7 @@ static int smc911x_drv_probe(struct platform_device *pdev)
 	unsigned int *addr;
 	int ret;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n",  __func__);
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (!res) {
 		ret = -ENODEV;
@@ -2191,7 +2191,7 @@ static int smc911x_drv_remove(struct platform_device *pdev)
 	struct net_device *ndev = platform_get_drvdata(pdev);
 	struct resource *res;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
@@ -2222,7 +2222,7 @@ static int smc911x_drv_suspend(struct platform_device *dev, pm_message_t state)
 	struct net_device *ndev = platform_get_drvdata(dev);
 	unsigned long ioaddr = ndev->base_addr;
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		if (netif_running(ndev)) {
 			netif_device_detach(ndev);
@@ -2240,7 +2240,7 @@ static int smc911x_drv_resume(struct platform_device *dev)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
 
-	DBG(SMC_DEBUG_FUNC, "--> %s\n", __FUNCTION__);
+	DBG(SMC_DEBUG_FUNC, "--> %s\n", __func__);
 	if (ndev) {
 		struct smc911x_local *lp = netdev_priv(ndev);
 
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 4020e9e..7ec0c64 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -269,7 +269,7 @@ static void smc_reset(struct net_device *dev)
 	unsigned int ctl, cfg;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* Disable all interrupts, block TX tasklet */
 	spin_lock_irq(&lp->lock);
@@ -362,7 +362,7 @@ static void smc_enable(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int mask;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/* see the header file for options in TCR/RCR DEFAULT */
 	SMC_SELECT_BANK(0);
@@ -396,7 +396,7 @@ static void smc_shutdown(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	struct sk_buff *pending_skb;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* no more interrupts for me */
 	spin_lock_irq(&lp->lock);
@@ -429,7 +429,7 @@ static inline void  smc_rcv(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int packet_number, status, packet_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	packet_number = SMC_GET_RXFIFO();
 	if (unlikely(packet_number & RXFIFO_REMPTY)) {
@@ -576,7 +576,7 @@ static void smc_hardware_send_pkt(unsigned long data)
 	unsigned int packet_no, len;
 	unsigned char *buf;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	if (!smc_special_trylock(&lp->lock)) {
 		netif_stop_queue(dev);
@@ -661,7 +661,7 @@ static int smc_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int numPages, poll_count, status;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	BUG_ON(lp->pending_tx_skb != NULL);
 
@@ -733,7 +733,7 @@ static void smc_tx(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	unsigned int saved_packet, packet_no, tx_status, pkt_len;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* If the TX FIFO is empty then nothing to do */
 	packet_no = SMC_GET_TXFIFO();
@@ -855,7 +855,7 @@ static int smc_phy_read(struct net_device *dev, int phyaddr, int phyreg)
 	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(2);
 	return phydata;
@@ -882,7 +882,7 @@ static void smc_phy_write(struct net_device *dev, int phyaddr, int phyreg,
 	SMC_SET_MII(SMC_GET_MII() & ~(MII_MCLK|MII_MDOE|MII_MDO));
 
 	DBG(3, "%s: phyaddr=0x%x, phyreg=0x%x, phydata=0x%x\n",
-		__FUNCTION__, phyaddr, phyreg, phydata);
+		__func__, phyaddr, phyreg, phydata);
 
 	SMC_SELECT_BANK(2);
 }
@@ -895,7 +895,7 @@ static void smc_phy_detect(struct net_device *dev)
 	struct smc_local *lp = netdev_priv(dev);
 	int phyaddr;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	lp->phy_type = 0;
 
@@ -934,7 +934,7 @@ static int smc_phy_fixed(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int bmcr, cfg1;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	/* Enter Link Disable state */
 	cfg1 = smc_phy_read(dev, phyaddr, PHY_CFG1_REG);
@@ -1175,7 +1175,7 @@ static void smc_phy_interrupt(struct net_device *dev)
 	int phyaddr = lp->mii.phy_id;
 	int phy18;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (lp->phy_type == 0)
 		return;
@@ -1243,7 +1243,7 @@ static irqreturn_t smc_interrupt(int irq, void *dev_id)
 	int status, mask, timeout, card_stats;
 	int saved_pointer;
 
-	DBG(3, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(3, "%s: %s\n", dev->name, __func__);
 
 	spin_lock(&lp->lock);
 
@@ -1363,7 +1363,7 @@ static void smc_timeout(struct net_device *dev)
 	void __iomem *ioaddr = lp->base;
 	int status, mask, eph_st, meminfo, fifo;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	spin_lock_irq(&lp->lock);
 	status = SMC_GET_INT();
@@ -1410,7 +1410,7 @@ static void smc_set_multicast_list(struct net_device *dev)
 	unsigned char multicast_table[8];
 	int update_multicast = 0;
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	if (dev->flags & IFF_PROMISC) {
 		DBG(2, "%s: RCR_PRMS\n", dev->name);
@@ -1513,7 +1513,7 @@ smc_open(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	/*
 	 * Check that the address is valid.  If its not, refuse
@@ -1521,7 +1521,7 @@ smc_open(struct net_device *dev)
 	 * address using ifconfig eth0 hw ether xx:xx:xx:xx:xx:xx
 	 */
 	if (!is_valid_ether_addr(dev->dev_addr)) {
-		PRINTK("%s: no valid ethernet hw addr\n", __FUNCTION__);
+		PRINTK("%s: no valid ethernet hw addr\n", __func__);
 		return -EINVAL;
 	}
 
@@ -1565,7 +1565,7 @@ static int smc_close(struct net_device *dev)
 {
 	struct smc_local *lp = netdev_priv(dev);
 
-	DBG(2, "%s: %s\n", dev->name, __FUNCTION__);
+	DBG(2, "%s: %s\n", dev->name, __func__);
 
 	netif_stop_queue(dev);
 	netif_carrier_off(dev);
@@ -1707,7 +1707,7 @@ static int __init smc_findirq(void __iomem *ioaddr)
 	int timeout = 20;
 	unsigned long cookie;
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	cookie = probe_irq_on();
 
@@ -1785,7 +1785,7 @@ static int __init smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	const char *version_string;
 	DECLARE_MAC_BUF(mac);
 
-	DBG(2, "%s: %s\n", CARDNAME, __FUNCTION__);
+	DBG(2, "%s: %s\n", CARDNAME, __func__);
 
 	/* First, see if the high byte is 0x33 */
 	val = SMC_CURRENT_BANK();
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index efd170f..e1aa703 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
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
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 6f33f84..25ad432 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -262,7 +262,7 @@ static inline void tsi108_write_tbi(struct tsi108_prv_data *data,
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static int mii_speed(struct mii_if_info *mii)
@@ -1057,7 +1057,7 @@ static void tsi108_stop_ethernet(struct net_device *dev)
 			return;
 		udelay(10);
 	}
-	printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+	printk(KERN_ERR "%s function time out \n", __func__);
 }
 
 static void tsi108_reset_ether(struct tsi108_prv_data * data)
@@ -1242,7 +1242,7 @@ static void tsi108_init_phy(struct net_device *dev)
 		udelay(10);
 	}
 	if (i == 0)
-		printk(KERN_ERR "%s function time out \n", __FUNCTION__);
+		printk(KERN_ERR "%s function time out \n", __func__);
 
 	if (data->phy_type == TSI108_PHY_BCM54XX) {
 		tsi108_write_mii(data, 0x09, 0x0300);
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index fba0811..302ccd9 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -396,7 +396,7 @@ static struct enet_addr_container *get_enet_addr_container(void)
 	enet_addr_cont = kmalloc(sizeof(struct enet_addr_container), GFP_KERNEL);
 	if (!enet_addr_cont) {
 		ugeth_err("%s: No memory for enet_addr_container object.",
-			  __FUNCTION__);
+			  __func__);
 		return NULL;
 	}
 
@@ -423,7 +423,7 @@ static int hw_add_addr_in_paddr(struct ucc_geth_private *ugeth,
 	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illegal paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illegal paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -443,7 +443,7 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 	struct ucc_geth_82xx_address_filtering_pram *p_82xx_addr_filt;
 
 	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illagel paddr_num.", __FUNCTION__);
+		ugeth_warn("%s: Illagel paddr_num.", __func__);
 		return -EINVAL;
 	}
 
@@ -1437,7 +1437,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	u32 upsmr, maccfg2, tbiBaseAddress;
 	u16 value;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	ug_info = ugeth->ug_info;
 	ug_regs = ugeth->ug_regs;
@@ -1500,7 +1500,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
-			     __FUNCTION__);
+			     __func__);
 		return ret_val;
 	}
 
@@ -1741,7 +1741,7 @@ static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -1770,7 +1770,7 @@ static int ugeth_disable(struct ucc_geth_private * ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __FUNCTION__);
+			ugeth_err("%s: ucc_num out of range.", __func__);
 		return -EINVAL;
 	}
 
@@ -2058,7 +2058,7 @@ static int ugeth_82xx_filtering_add_addr_in_paddr(struct ucc_geth_private *ugeth
 		ugeth_warn
 		    ("%s: multicast address added to paddr will have no "
 		     "effect - is this what you wanted?",
-		     __FUNCTION__);
+		     __func__);
 
 	ugeth->indAddrRegUsed[paddr_num] = 1;	/* mark this paddr as used */
 	/* store address in our database */
@@ -2274,7 +2274,7 @@ static void ucc_geth_stop(struct ucc_geth_private *ugeth)
 	struct phy_device *phydev = ugeth->phydev;
 	u32 tempval;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	/* Disable the controller */
 	ugeth_disable(ugeth, COMM_DIR_RX_AND_TX);
@@ -2311,7 +2311,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Bad memory partition value.",
-					__FUNCTION__);
+					__func__);
 		return -EINVAL;
 	}
 
@@ -2323,7 +2323,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
-					__FUNCTION__);
+					__func__);
 			return -EINVAL;
 		}
 	}
@@ -2334,7 +2334,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 			if (netif_msg_probe(ugeth))
 				ugeth_err
 				    ("%s: Tx BD ring length must be no smaller than 2.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2345,21 +2345,21 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
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
 
@@ -2370,7 +2370,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: VLAN priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2382,7 +2382,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: IP priority table entry must not be"
 					" larger than number of Rx queues.",
-				     __FUNCTION__);
+				     __func__);
 			return -EINVAL;
 		}
 	}
@@ -2390,7 +2390,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	if (ug_info->cam && !ug_info->ecamptr) {
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2400,7 +2400,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		if (netif_msg_probe(ugeth))
 			ugeth_err("%s: Number of station addresses greater than 1 "
 				  "not allowed in extended parsing mode.",
-				  __FUNCTION__);
+				  __func__);
 		return -EINVAL;
 	}
 
@@ -2414,7 +2414,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Failed to init uccf.", __FUNCTION__);
+			ugeth_err("%s: Failed to init uccf.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2443,7 +2443,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	u8 *bd, *endOfRing;
 	u8 numThreadsRxNumerical, numThreadsTxNumerical;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
 	uf_info = &ug_info->uf_info;
@@ -2469,7 +2469,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Rx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2494,7 +2494,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	default:
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Bad number of Tx threads value.",
-				       	__FUNCTION__);
+				       	__func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 		break;
@@ -2548,7 +2548,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: IPGIFG initialization parameter too large.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2566,7 +2566,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Half Duplex initialization parameter too large.",
-			  __FUNCTION__);
+			  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -2621,7 +2621,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Tx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2657,7 +2657,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				    ("%s: Can not allocate memory for Rx bd rings.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2673,7 +2673,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (ugeth->tx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate tx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2705,7 +2705,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (ugeth->rx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Could not allocate rx_skbuff",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2739,7 +2739,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2762,7 +2762,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2791,7 +2791,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2835,7 +2835,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-				     __FUNCTION__);
+				     __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2885,7 +2885,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				ugeth_err
 				    ("%s: Can not allocate DPRAM memory for"
 					" p_tx_fw_statistics_pram.",
-				       	__FUNCTION__);
+				       	__func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2925,7 +2925,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2947,7 +2947,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -2971,7 +2971,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_rx_fw_statistics_pram.", __FUNCTION__);
+					" p_rx_fw_statistics_pram.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -2994,7 +2994,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for"
-				" p_rx_irq_coalescing_tbl.", __FUNCTION__);
+				" p_rx_irq_coalescing_tbl.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3063,7 +3063,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3140,7 +3140,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (!ug_info->extendedFilteringChainPointer) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return -EINVAL;
 		}
@@ -3154,7 +3154,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			if (netif_msg_ifup(ugeth))
 				ugeth_err
 					("%s: Can not allocate DPRAM memory for"
-					" p_exf_glbl_param.", __FUNCTION__);
+					" p_exf_glbl_param.", __func__);
 			ucc_geth_memclean(ugeth);
 			return -ENOMEM;
 		}
@@ -3202,7 +3202,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate memory for"
-				" p_UccInitEnetParamShadows.", __FUNCTION__);
+				" p_UccInitEnetParamShadows.", __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3237,7 +3237,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Invalid largest External Lookup Key Size.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return -EINVAL;
 	}
@@ -3264,7 +3264,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		ug_info->riscRx, 1)) != 0) {
 		if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-					__FUNCTION__);
+					__func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3280,7 +3280,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    ug_info->riscTx, 0)) != 0) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				  __FUNCTION__);
+				  __func__);
 		ucc_geth_memclean(ugeth);
 		return ret_val;
 	}
@@ -3290,7 +3290,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
 			if (netif_msg_ifup(ugeth))
 				ugeth_err("%s: Can not fill Rx bds with buffers.",
-					  __FUNCTION__);
+					  __func__);
 			ucc_geth_memclean(ugeth);
 			return ret_val;
 		}
@@ -3302,7 +3302,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
 			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-			     __FUNCTION__);
+			     __func__);
 		ucc_geth_memclean(ugeth);
 		return -ENOMEM;
 	}
@@ -3349,7 +3349,7 @@ static void ucc_geth_timeout(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev->stats.tx_errors++;
 
@@ -3375,7 +3375,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u32 bd_status;
 	u8 txQ = 0;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	spin_lock_irq(&ugeth->lock);
 
@@ -3447,7 +3447,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 	u8 *bdBuffer;
 	struct net_device *dev;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	dev = ugeth->dev;
 
@@ -3469,7 +3469,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		    (bd_status & R_ERRORS_FATAL)) {
 			if (netif_msg_rx_err(ugeth))
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
-					   __FUNCTION__, __LINE__, (u32) skb);
+					   __func__, __LINE__, (u32) skb);
 			if (skb)
 				dev_kfree_skb_any(skb);
 
@@ -3499,7 +3499,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
-				ugeth_warn("%s: No Rx Data Buffer", __FUNCTION__);
+				ugeth_warn("%s: No Rx Data Buffer", __func__);
 			dev->stats.rx_dropped++;
 			break;
 		}
@@ -3610,7 +3610,7 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	register u32 tx_mask;
 	u8 i;
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	uccf = ugeth->uccf;
 	ug_info = ugeth->ug_info;
@@ -3690,13 +3690,13 @@ static int ucc_geth_open(struct net_device *dev)
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
 
@@ -3781,7 +3781,7 @@ static int ucc_geth_close(struct net_device *dev)
 {
 	struct ucc_geth_private *ugeth = netdev_priv(dev);
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 #ifdef CONFIG_UGETH_NAPI
 	napi_disable(&ugeth->napi);
@@ -3850,7 +3850,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 		PHY_INTERFACE_MODE_TBI, PHY_INTERFACE_MODE_RTBI,
 	};
 
-	ugeth_vdbg("%s: IN", __FUNCTION__);
+	ugeth_vdbg("%s: IN", __func__);
 
 	prop = of_get_property(np, "device-id", NULL);
 	ucc_num = *prop - 1;
@@ -3861,7 +3861,7 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	if (ug_info == NULL) {
 		if (netif_msg_probe(&debug))
 			ugeth_err("%s: [%d] Missing additional data!",
-				       	__FUNCTION__, ucc_num);
+				       	__func__, ucc_num);
 		return -ENODEV;
 	}
 
diff --git a/drivers/net/usb/mcs7830.c b/drivers/net/usb/mcs7830.c
index c3d119f..aa1ab82 100644
--- a/drivers/net/usb/mcs7830.c
+++ b/drivers/net/usb/mcs7830.c
@@ -114,7 +114,7 @@ static void mcs7830_async_cmd_callback(struct urb *urb)
 
 	if (urb->status < 0)
 		printk(KERN_DEBUG "%s() failed with %d\n",
-		       __FUNCTION__, urb->status);
+		       __func__, urb->status);
 
 	kfree(req);
 	usb_free_urb(urb);
diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index d1ed68a..18cab7c 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -119,7 +119,7 @@ static void ctrl_callback(struct urb *urb)
 	default:
 		if (netif_msg_drv(pegasus))
 			dev_dbg(&pegasus->intf->dev, "%s, status %d\n",
-				__FUNCTION__, urb->status);
+				__func__, urb->status);
 	}
 	pegasus->flags &= ~ETH_REGS_CHANGED;
 	wake_up(&pegasus->ctrl_wait);
@@ -136,7 +136,7 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 	if (!buffer) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	add_wait_queue(&pegasus->ctrl_wait, &wait);
@@ -168,7 +168,7 @@ static int get_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -192,7 +192,7 @@ static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 	if (!buffer) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	memcpy(buffer, data, size);
@@ -224,7 +224,7 @@ static int set_registers(pegasus_t * pegasus, __u16 indx, __u16 size,
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -246,7 +246,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 	if (!tmp) {
 		if (netif_msg_drv(pegasus))
 			dev_warn(&pegasus->intf->dev, "out of memory in %s\n",
-					__FUNCTION__);
+					__func__);
 		return -ENOMEM;
 	}
 	memcpy(tmp, &data, 1);
@@ -277,7 +277,7 @@ static int set_register(pegasus_t * pegasus, __u16 indx, __u8 data)
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 		goto out;
 	}
 
@@ -310,7 +310,7 @@ static int update_eth_regs_async(pegasus_t * pegasus)
 			netif_device_detach(pegasus->net);
 		if (netif_msg_drv(pegasus))
 			dev_err(&pegasus->intf->dev, "%s, status %d\n",
-					__FUNCTION__, ret);
+					__func__, ret);
 	}
 
 	return ret;
@@ -341,7 +341,7 @@ static int read_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 * regd)
 	}
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 
 	return ret;
 }
@@ -378,7 +378,7 @@ static int write_mii_word(pegasus_t * pegasus, __u8 phy, __u8 indx, __u16 regd)
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -415,7 +415,7 @@ static int read_eprom_word(pegasus_t * pegasus, __u8 index, __u16 * retdata)
 
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 
@@ -463,7 +463,7 @@ static int write_eprom_word(pegasus_t * pegasus, __u8 index, __u16 data)
 		return ret;
 fail:
 	if (netif_msg_drv(pegasus))
-		dev_warn(&pegasus->intf->dev, "%s failed\n", __FUNCTION__);
+		dev_warn(&pegasus->intf->dev, "%s failed\n", __func__);
 	return -ETIMEDOUT;
 }
 #endif				/* PEGASUS_WRITE_EEPROM */
diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 7e1f001..bf3d193 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -665,7 +665,7 @@ static int enable_net_traffic(rtl8150_t * dev)
 	u8 cr, tcr, rcr, msr;
 
 	if (!rtl8150_reset(dev)) {
-		warn("%s - device reset failed", __FUNCTION__);
+		warn("%s - device reset failed", __func__);
 	}
 	/* RCR bit7=1 attach Rx info at the end;  =0 HW CRC (which is broken) */
 	rcr = 0x9e;
@@ -783,7 +783,7 @@ static int rtl8150_open(struct net_device *netdev)
 	if ((res = usb_submit_urb(dev->rx_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
 			netif_device_detach(dev->netdev);
-		warn("%s: rx_urb submit failed: %d", __FUNCTION__, res);
+		warn("%s: rx_urb submit failed: %d", __func__, res);
 		return res;
 	}
 	usb_fill_int_urb(dev->intr_urb, dev->udev, usb_rcvintpipe(dev->udev, 3),
@@ -792,7 +792,7 @@ static int rtl8150_open(struct net_device *netdev)
 	if ((res = usb_submit_urb(dev->intr_urb, GFP_KERNEL))) {
 		if (res == -ENODEV)
 			netif_device_detach(dev->netdev);
-		warn("%s: intr_urb submit failed: %d", __FUNCTION__, res);
+		warn("%s: intr_urb submit failed: %d", __func__, res);
 		usb_kill_urb(dev->rx_urb);
 		return res;
 	}
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 7387be4..e5d8d34 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1383,7 +1383,7 @@ enum velocity_msg_level {
 #define ASSERT(x) { \
 	if (!(x)) { \
 		printk(KERN_ERR "assertion %s failed: file %s line %d\n", #x,\
-			__FUNCTION__, __LINE__);\
+			__func__, __LINE__);\
 		BUG(); \
 	}\
 }
diff --git a/drivers/net/wan/cycx_drv.c b/drivers/net/wan/cycx_drv.c
index d14e667..a5ddc6c 100644
--- a/drivers/net/wan/cycx_drv.c
+++ b/drivers/net/wan/cycx_drv.c
@@ -407,7 +407,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	if (cfm->version != CFM_VERSION) {
 		printk(KERN_ERR "%s:%s: firmware format %u rejected! "
 				"Expecting %u.\n",
-				modname, __FUNCTION__, cfm->version, CFM_VERSION);
+				modname, __func__, cfm->version, CFM_VERSION);
 		return -EINVAL;
 	}
 
@@ -420,7 +420,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 */
 	if (cksum != cfm->checksum) {
 		printk(KERN_ERR "%s:%s: firmware corrupted!\n",
-				modname, __FUNCTION__);
+				modname, __func__);
 		printk(KERN_ERR " cdsize = 0x%x (expected 0x%lx)\n",
 				len - (int)sizeof(struct cycx_firmware) - 1,
 				cfm->info.codesize);
@@ -432,7 +432,7 @@ static int load_cyc2x(struct cycx_hw *hw, struct cycx_firmware *cfm, u32 len)
 	/* If everything is ok, set reset, data and code pointers */
 	img_hdr = (struct cycx_fw_header *)&cfm->image;
 #ifdef FIRMWARE_DEBUG
-	printk(KERN_INFO "%s:%s: image sizes\n", __FUNCTION__, modname);
+	printk(KERN_INFO "%s:%s: image sizes\n", __func__, modname);
 	printk(KERN_INFO " reset=%lu\n", img_hdr->reset_size);
 	printk(KERN_INFO "  data=%lu\n", img_hdr->data_size);
 	printk(KERN_INFO "  code=%lu\n", img_hdr->code_size);
diff --git a/drivers/net/wan/cycx_x25.c b/drivers/net/wan/cycx_x25.c
index d3b28b0..5a7303d 100644
--- a/drivers/net/wan/cycx_x25.c
+++ b/drivers/net/wan/cycx_x25.c
@@ -874,7 +874,7 @@ static void cycx_x25_irq_connect(struct cycx_device *card,
 		nibble_to_byte(d + (sizeloc >> 1), rem, sizerem, sizeloc & 1);
 
 	dprintk(1, KERN_INFO "%s:lcn=%d, local=%s, remote=%s\n",
-			  __FUNCTION__, lcn, loc, rem);
+			  __func__, lcn, loc, rem);
 
 	dev = cycx_x25_get_dev_by_dte_addr(wandev, rem);
 	if (!dev) {
@@ -902,7 +902,7 @@ static void cycx_x25_irq_connect_confirm(struct cycx_device *card,
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	cycx_peek(&card->hw, cmd->buf + 1, &key, sizeof(key));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d, key=%d\n",
-			  card->devname, __FUNCTION__, lcn, key);
+			  card->devname, __func__, lcn, key);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, -key);
 	if (!dev) {
@@ -929,7 +929,7 @@ static void cycx_x25_irq_disconnect_confirm(struct cycx_device *card,
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
 	dprintk(1, KERN_INFO "%s: %s:lcn=%d\n",
-			  card->devname, __FUNCTION__, lcn);
+			  card->devname, __func__, lcn);
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (!dev) {
 		/* Invalid channel, discard packet */
@@ -950,7 +950,7 @@ static void cycx_x25_irq_disconnect(struct cycx_device *card,
 	u8 lcn;
 
 	cycx_peek(&card->hw, cmd->buf, &lcn, sizeof(lcn));
-	dprintk(1, KERN_INFO "%s:lcn=%d\n", __FUNCTION__, lcn);
+	dprintk(1, KERN_INFO "%s:lcn=%d\n", __func__, lcn);
 
 	dev = cycx_x25_get_dev_by_lcn(wandev, lcn);
 	if (dev) {
@@ -1381,7 +1381,7 @@ static void cycx_x25_chan_timer(unsigned long d)
 		cycx_x25_chan_disconnect(dev);
 	else
 		printk(KERN_ERR "%s: %s for svc (%s) not connected!\n",
-				chan->card->devname, __FUNCTION__, dev->name);
+				chan->card->devname, __func__, dev->name);
 }
 
 /* Set logical channel state. */
@@ -1485,7 +1485,7 @@ static void cycx_x25_chan_send_event(struct net_device *dev, u8 event)
 	unsigned char *ptr;
 
 	if ((skb = dev_alloc_skb(1)) == NULL) {
-		printk(KERN_ERR "%s: out of memory\n", __FUNCTION__);
+		printk(KERN_ERR "%s: out of memory\n", __func__);
 		return;
 	}
 
diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index c6f26e2..31035cb 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -649,7 +649,7 @@ static inline void dscc4_rx_skb(struct dscc4_dev_priv *dpriv,
 
 	skb = dpriv->rx_skbuff[dpriv->rx_current++%RX_RING_SIZE];
 	if (!skb) {
-		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __FUNCTION__);
+		printk(KERN_DEBUG "%s: skb=0 (%s)\n", dev->name, __func__);
 		goto refill;
 	}
 	pkt_len = TO_SIZE(le32_to_cpu(rx_fd->state2));
diff --git a/drivers/net/wan/pc300_tty.c b/drivers/net/wan/pc300_tty.c
index 63abfd7..de6a46d 100644
--- a/drivers/net/wan/pc300_tty.c
+++ b/drivers/net/wan/pc300_tty.c
@@ -542,7 +542,7 @@ static int pc300_tiocmset(struct tty_struct *tty, struct file *file,
 {
 	st_cpc_tty_area    *cpc_tty; 
 
-	CPC_TTY_DBG("%s: set:%x clear:%x\n", __FUNCTION__, set, clear);
+	CPC_TTY_DBG("%s: set:%x clear:%x\n", __func__, set, clear);
 
 	if (!tty || !tty->driver_data ) {
 	   	CPC_TTY_DBG("hdlcX-tty: no TTY to chars in buffer\n");	
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 932d6b1..a64f3ef 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1916,7 +1916,7 @@ static int mpi_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	struct airo_info *ai = dev->priv;
 
 	if (!skb) {
-		airo_print_err(dev->name, "%s: skb == NULL!",__FUNCTION__);
+		airo_print_err(dev->name, "%s: skb == NULL!",__func__);
 		return 0;
 	}
 	npacks = skb_queue_len (&ai->txq);
@@ -1965,7 +1965,7 @@ static int mpi_send_packet (struct net_device *dev)
 	if ((skb = skb_dequeue(&ai->txq)) == NULL) {
 		airo_print_err(dev->name,
 			"%s: Dequeue'd zero in send_packet()",
-			__FUNCTION__);
+			__func__);
 		return 0;
 	}
 
@@ -2116,7 +2116,7 @@ static int airo_start_xmit(struct sk_buff *skb, struct net_device *dev) {
 	u32 *fids = priv->fids;
 
 	if ( skb == NULL ) {
-		airo_print_err(dev->name, "%s: skb == NULL!", __FUNCTION__);
+		airo_print_err(dev->name, "%s: skb == NULL!", __func__);
 		return 0;
 	}
 
@@ -2187,7 +2187,7 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 	}
 
 	if ( skb == NULL ) {
-		airo_print_err(dev->name, "%s: skb == NULL!", __FUNCTION__);
+		airo_print_err(dev->name, "%s: skb == NULL!", __func__);
 		return 0;
 	}
 
@@ -4125,7 +4125,7 @@ static int PC4500_writerid(struct airo_info *ai, u16 rid,
 		if (test_bit(FLAG_ENABLED, &ai->flags) && (RID_WEP_TEMP != rid))
 			airo_print_err(ai->dev->name,
 				"%s: MAC should be disabled (rid=%04x)",
-				__FUNCTION__, rid);
+				__func__, rid);
 		memset(&cmd, 0, sizeof(cmd));
 		memset(&rsp, 0, sizeof(rsp));
 
@@ -4140,7 +4140,7 @@ static int PC4500_writerid(struct airo_info *ai, u16 rid,
 			&ai->config_desc.rid_desc, sizeof(Rid));
 
 		if (len < 4 || len > 2047) {
-			airo_print_err(ai->dev->name, "%s: len=%d", __FUNCTION__, len);
+			airo_print_err(ai->dev->name, "%s: len=%d", __func__, len);
 			rc = -1;
 		} else {
 			memcpy((char *)ai->config_desc.virtual_host_addr,
@@ -4149,9 +4149,9 @@ static int PC4500_writerid(struct airo_info *ai, u16 rid,
 			rc = issuecommand(ai, &cmd, &rsp);
 			if ((rc & 0xff00) != 0) {
 				airo_print_err(ai->dev->name, "%s: Write rid Error %d",
-						__FUNCTION__, rc);
+						__func__, rc);
 				airo_print_err(ai->dev->name, "%s: Cmd=%04x",
-						__FUNCTION__, cmd.cmd);
+						__func__, cmd.cmd);
 			}
 
 			if ((rsp.status & 0x7f00))
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 2ebd2ed..f21b412 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -424,7 +424,7 @@ enum {
 	do {									\
 		if (unlikely(!(expr))) {					\
 		printk(KERN_ERR PFX "ASSERTION FAILED (%s) at: %s:%d:%s()\n",	\
-			#expr, __FILE__, __LINE__, __FUNCTION__);		\
+			#expr, __FILE__, __LINE__, __func__);		\
 		}								\
 	} while (0)
 #else
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
index a40d1af..9ae31da 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_debugfs.h
@@ -103,7 +103,7 @@ void bcm43xx_printk_bitdump(const unsigned char *data,
 #define TODO()  \
 	do {										\
 		printk(KERN_INFO PFX "TODO: Incomplete code in %s() at %s:%d\n",	\
-		       __FUNCTION__, __FILE__, __LINE__);				\
+		       __func__, __FILE__, __LINE__);				\
 	} while (0)
 
 #ifdef FIXME
@@ -112,7 +112,7 @@ void bcm43xx_printk_bitdump(const unsigned char *data,
 #define FIXME()  \
 	do {										\
 		printk(KERN_INFO PFX "FIXME: Possibly broken code in %s() at %s:%d\n",	\
-		       __FUNCTION__, __FILE__, __LINE__);				\
+		       __func__, __FILE__, __LINE__);				\
 	} while (0)
 
 #endif /* BCM43xx_DEBUGFS_H_ */
diff --git a/drivers/net/wireless/hermes.c b/drivers/net/wireless/hermes.c
index 29d3910..2cd86af 100644
--- a/drivers/net/wireless/hermes.c
+++ b/drivers/net/wireless/hermes.c
@@ -463,7 +463,7 @@ int hermes_read_ltv(hermes_t *hw, int bap, u16 rid, unsigned bufsize,
 	if (rtype != rid)
 		printk(KERN_WARNING "hermes @ %p: %s(): "
 		       "rid (0x%04x) does not match type (0x%04x)\n",
-		       hw->iobase, __FUNCTION__, rid, rtype);
+		       hw->iobase, __func__, rid, rtype);
 	if (HERMES_RECLEN_TO_BYTES(rlength) > bufsize)
 		printk(KERN_WARNING "hermes @ %p: "
 		       "Truncating LTV record from %d to %d bytes. "
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 5bf9e00..c71bb09 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -212,7 +212,7 @@ static u32 ipw2100_debug_level = IPW_DL_NONE;
 do { \
 	if (ipw2100_debug_level & (level)) { \
 		printk(KERN_DEBUG "ipw2100: %c %s ", \
-                       in_interrupt() ? 'I' : 'U',  __FUNCTION__); \
+                       in_interrupt() ? 'I' : 'U',  __func__); \
 		printk(message); \
 	} \
 } while (0)
diff --git a/drivers/net/wireless/ipw2200.h b/drivers/net/wireless/ipw2200.h
index fdc187e..96d2327 100644
--- a/drivers/net/wireless/ipw2200.h
+++ b/drivers/net/wireless/ipw2200.h
@@ -1386,13 +1386,13 @@ BIT_ARG16(x)
 #define IPW_DEBUG(level, fmt, args...) \
 do { if (ipw_debug_level & (level)) \
   printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
-         in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+         in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 
 #ifdef CONFIG_IPW2200_DEBUG
 #define IPW_LL_DEBUG(level, fmt, args...) \
 do { if (ipw_debug_level & (level)) \
   printk(KERN_DEBUG DRV_NAME": %c %s " fmt, \
-         in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+         in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 #else
 #define IPW_LL_DEBUG(level, fmt, args...) do {} while (0)
 #endif				/* CONFIG_IPW2200_DEBUG */
diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-debug.h b/drivers/net/wireless/iwlwifi/iwl-3945-debug.h
index f853c6b..ee4617c 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-debug.h
@@ -34,12 +34,12 @@ extern u32 iwl3945_debug_level;
 #define IWL_DEBUG(level, fmt, args...) \
 do { if (iwl3945_debug_level & (level)) \
   printk(KERN_ERR DRV_NAME": %c %s " fmt, \
-	 in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+	 in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 
 #define IWL_DEBUG_LIMIT(level, fmt, args...) \
 do { if ((iwl3945_debug_level & (level)) && net_ratelimit()) \
   printk(KERN_ERR DRV_NAME": %c %s " fmt, \
-	 in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+	 in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 #else
 static inline void IWL_DEBUG(int level, const char *fmt, ...)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965-debug.h b/drivers/net/wireless/iwlwifi/iwl-4965-debug.h
index 36696bb..e9ea352 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965-debug.h
+++ b/drivers/net/wireless/iwlwifi/iwl-4965-debug.h
@@ -34,12 +34,12 @@ extern u32 iwl4965_debug_level;
 #define IWL_DEBUG(level, fmt, args...) \
 do { if (iwl4965_debug_level & (level)) \
   printk(KERN_ERR DRV_NAME": %c %s " fmt, \
-	 in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+	 in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 
 #define IWL_DEBUG_LIMIT(level, fmt, args...) \
 do { if ((iwl4965_debug_level & (level)) && net_ratelimit()) \
   printk(KERN_ERR DRV_NAME": %c %s " fmt, \
-	 in_interrupt() ? 'I' : 'U', __FUNCTION__ , ## args); } while (0)
+	 in_interrupt() ? 'I' : 'U', __func__ , ## args); } while (0)
 #else
 static inline void IWL_DEBUG(int level, const char *fmt, ...)
 {
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 0fab832..7ab5b0b 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6681,7 +6681,7 @@ static void iwl3945_bg_post_associate(struct work_struct *data)
 	DECLARE_MAC_BUF(mac);
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_AP) {
-		IWL_ERROR("%s Should not be called in AP mode\n", __FUNCTION__);
+		IWL_ERROR("%s Should not be called in AP mode\n", __func__);
 		return;
 	}
 
@@ -6762,7 +6762,7 @@ static void iwl3945_bg_post_associate(struct work_struct *data)
 
 	default:
 		 IWL_ERROR("%s Should not be called in %d mode\n",
-			   __FUNCTION__, priv->iw_mode);
+			   __func__, priv->iw_mode);
 		break;
 	}
 
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 20d012d..8fd8d73 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -7101,7 +7101,7 @@ static void iwl4965_bg_post_associate(struct work_struct *data)
 	DECLARE_MAC_BUF(mac);
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_AP) {
-		IWL_ERROR("%s Should not be called in AP mode\n", __FUNCTION__);
+		IWL_ERROR("%s Should not be called in AP mode\n", __func__);
 		return;
 	}
 
@@ -7183,7 +7183,7 @@ static void iwl4965_bg_post_associate(struct work_struct *data)
 
 	default:
 		IWL_ERROR("%s Should not be called in %d mode\n",
-				__FUNCTION__, priv->iw_mode);
+				__func__, priv->iw_mode);
 		break;
 	}
 
diff --git a/drivers/net/wireless/libertas/defs.h b/drivers/net/wireless/libertas/defs.h
index 3053cc2..8cd4b70 100644
--- a/drivers/net/wireless/libertas/defs.h
+++ b/drivers/net/wireless/libertas/defs.h
@@ -53,14 +53,14 @@ do { if ((lbs_debug & (grp)) == (grp)) \
 #endif
 
 #define lbs_deb_enter(grp) \
-  LBS_DEB_LL(grp | LBS_DEB_ENTER, " enter", "%s():%d\n", __FUNCTION__, __LINE__);
+  LBS_DEB_LL(grp | LBS_DEB_ENTER, " enter", "%s():%d\n", __func__, __LINE__);
 #define lbs_deb_enter_args(grp, fmt, args...) \
-  LBS_DEB_LL(grp | LBS_DEB_ENTER, " enter", "%s(" fmt "):%d\n", __FUNCTION__, ## args, __LINE__);
+  LBS_DEB_LL(grp | LBS_DEB_ENTER, " enter", "%s(" fmt "):%d\n", __func__, ## args, __LINE__);
 #define lbs_deb_leave(grp) \
-  LBS_DEB_LL(grp | LBS_DEB_LEAVE, " leave", "%s():%d\n", __FUNCTION__, __LINE__);
+  LBS_DEB_LL(grp | LBS_DEB_LEAVE, " leave", "%s():%d\n", __func__, __LINE__);
 #define lbs_deb_leave_args(grp, fmt, args...) \
   LBS_DEB_LL(grp | LBS_DEB_LEAVE, " leave", "%s():%d, " fmt "\n", \
-  __FUNCTION__, __LINE__, ##args);
+  __func__, __LINE__, ##args);
 #define lbs_deb_main(fmt, args...)      LBS_DEB_LL(LBS_DEB_MAIN, " main", fmt, ##args)
 #define lbs_deb_net(fmt, args...)       LBS_DEB_LL(LBS_DEB_NET, " net", fmt, ##args)
 #define lbs_deb_mesh(fmt, args...)      LBS_DEB_LL(LBS_DEB_MESH, " mesh", fmt, ##args)
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 5a9cadb..c7c7484 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -396,7 +396,7 @@ static struct sk_buff *if_cs_receive_data(struct lbs_private *priv)
 	if (len == 0 || len > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
 		lbs_pr_err("card data buffer has invalid # of bytes (%d)\n", len);
 		priv->stats.rx_dropped++;
-		printk(KERN_INFO "##HS %s:%d TODO\n", __FUNCTION__, __LINE__);
+		printk(KERN_INFO "##HS %s:%d TODO\n", __func__, __LINE__);
 		goto dat_err;
 	}
 
@@ -634,7 +634,7 @@ static int if_cs_host_to_card(struct lbs_private *priv,
 		ret = if_cs_send_cmd(priv, buf, nb);
 		break;
 	default:
-		lbs_pr_err("%s: unsupported type %d\n", __FUNCTION__, type);
+		lbs_pr_err("%s: unsupported type %d\n", __func__, type);
 	}
 
 	lbs_deb_leave_args(LBS_DEB_CS, "ret %d", ret);
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index 2d91a56..f193ab0 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -71,7 +71,7 @@ prism54_mib_mode_helper(islpci_private *priv, u32 iw_mode)
 	if (iw_mode == IW_MODE_REPEAT || iw_mode == IW_MODE_SECOND) {
 		printk(KERN_DEBUG
 		       "%s(): Sorry, Repeater mode and Secondary mode "
-		       "are not yet supported by this driver.\n", __FUNCTION__);
+		       "are not yet supported by this driver.\n", __func__);
 		return -EINVAL;
 	}
 
@@ -333,7 +333,7 @@ prism54_set_mode(struct net_device *ndev, struct iw_request_info *info,
 	if (*uwrq > IW_MODE_MONITOR || *uwrq < IW_MODE_AUTO) {
 		printk(KERN_DEBUG
 		       "%s: %s() You passed a non-valid init_mode.\n",
-		       priv->ndev->name, __FUNCTION__);
+		       priv->ndev->name, __func__);
 		return -EINVAL;
 	}
 
@@ -1233,7 +1233,7 @@ prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
 		/* don't know how to disable radio */
 		printk(KERN_DEBUG
 		       "%s: %s() disabling radio is not yet supported.\n",
-		       priv->ndev->name, __FUNCTION__);
+		       priv->ndev->name, __func__);
 		return -ENOTSUPP;
 	} else if (vwrq->fixed)
 		/* currently only fixed value is supported */
@@ -1241,7 +1241,7 @@ prism54_set_txpower(struct net_device *ndev, struct iw_request_info *info,
 	else {
 		printk(KERN_DEBUG
 		       "%s: %s() auto power will be implemented later.\n",
-		       priv->ndev->name, __FUNCTION__);
+		       priv->ndev->name, __func__);
 		return -ENOTSUPP;
 	}
 }
diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index fd65fcc..4b7ddd2 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -53,11 +53,11 @@
  */
 #define DEBUG_PRINTK_MSG(__dev, __kernlvl, __lvl, __msg, __args...)	\
 	printk(__kernlvl "%s -> %s: %s - " __msg,			\
-	       wiphy_name((__dev)->hw->wiphy), __FUNCTION__, __lvl, ##__args)
+	       wiphy_name((__dev)->hw->wiphy), __func__, __lvl, ##__args)
 
 #define DEBUG_PRINTK_PROBE(__kernlvl, __lvl, __msg, __args...)	\
 	printk(__kernlvl "%s -> %s: %s - " __msg,		\
-	       KBUILD_MODNAME, __FUNCTION__, __lvl, ##__args)
+	       KBUILD_MODNAME, __func__, __lvl, ##__args)
 
 #ifdef CONFIG_RT2X00_DEBUG
 #define DEBUG_PRINTK(__dev, __kernlvl, __lvl, __msg, __args...)	\
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 42a36b3..58ce916 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -79,7 +79,7 @@ static int pc_debug = PCMCIA_DEBUG;
 module_param(pc_debug, int, 0);
 #define dprintk(n, format, args...) \
 	{ if (pc_debug > (n)) \
-		printk(KERN_INFO "%s: " format "\n", __FUNCTION__ , ##args); }
+		printk(KERN_INFO "%s: " format "\n", __func__ , ##args); }
 #else
 #define dprintk(n, format, args...)
 #endif
@@ -470,7 +470,7 @@ static int wl3501_pwr_mgmt(struct wl3501_card *this, int suspend)
 			spin_unlock_irqrestore(&this->lock, flags);
 			rc = wait_event_interruptible(this->wait,
 				this->sig_pwr_mgmt_confirm.status != 255);
-			printk(KERN_INFO "%s: %s status=%d\n", __FUNCTION__,
+			printk(KERN_INFO "%s: %s status=%d\n", __func__,
 			       suspend ? "suspend" : "resume",
 			       this->sig_pwr_mgmt_confirm.status);
 			goto out;
@@ -1199,7 +1199,7 @@ static int wl3501_reset_board(struct wl3501_card *this)
 		}
 		WL3501_NOPLOOP(10);
 	}
-	printk(KERN_WARNING "%s: failed to reset the board!\n", __FUNCTION__);
+	printk(KERN_WARNING "%s: failed to reset the board!\n", __func__);
 	rc = -ENODEV;
 out:
 	return rc;
@@ -1250,7 +1250,7 @@ static int wl3501_init_firmware(struct wl3501_card *this)
 out:
 	return rc;
 fail:
-	printk(KERN_WARNING "%s: failed!\n", __FUNCTION__);
+	printk(KERN_WARNING "%s: failed!\n", __func__);
 	goto out;
 }
 
-- 
1.5.4.3.500.g83a2c



