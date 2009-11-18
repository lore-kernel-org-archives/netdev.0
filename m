From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] drivers/net: request_irq - Remove unnecessary
 leading & from second arg
Date: Wed, 18 Nov 2009 15:45:57 -0800
Message-ID: <1258587958.24178.222.camel@Joe-Laptop.home>
References: <Pine.LNX.4.64.0911181925440.20943@ask.diku.dk>
	 <20091118.105237.127029548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Julia Lawall <julia@diku.dk>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1039 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756261AbZKRXpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 18:45:53 -0500
In-Reply-To: <20091118.105237.127029548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not as fancy as coccinelle.  Checkpatch errors ignored.
Compile tested allyesconfig x86, not all files compiled.

grep -rPl --include=*.[ch] "\brequest_irq\s*\([^,\)]+,\s*\&" drivers/net | while read file ; do \
	perl -i -e 'local $/; while (<>) { s@(\brequest_irq\s*\([^,\)]+,\s*)\&@\1@g ; print ; }' $file ;\
done

Signed-off-by: Joe Perches <joe@perches.com>

 drivers/net/3c501.c                           |    2 +-
 drivers/net/3c505.c                           |    2 +-
 drivers/net/3c507.c                           |    2 +-
 drivers/net/3c509.c                           |    2 +-
 drivers/net/3c515.c                           |    4 ++--
 drivers/net/3c523.c                           |    2 +-
 drivers/net/3c527.c                           |    2 +-
 drivers/net/appletalk/cops.c                  |    2 +-
 drivers/net/appletalk/ltpc.c                  |    2 +-
 drivers/net/arcnet/arc-rimi.c                 |    2 +-
 drivers/net/arcnet/com20020.c                 |    2 +-
 drivers/net/arcnet/com90io.c                  |    2 +-
 drivers/net/arcnet/com90xx.c                  |    2 +-
 drivers/net/at1700.c                          |    2 +-
 drivers/net/atl1e/atl1e_main.c                |    2 +-
 drivers/net/atlx/atl1.c                       |    2 +-
 drivers/net/atlx/atl2.c                       |    2 +-
 drivers/net/atp.c                             |    2 +-
 drivers/net/au1000_eth.c                      |    2 +-
 drivers/net/cs89x0.c                          |    2 +-
 drivers/net/declance.c                        |    4 ++--
 drivers/net/depca.c                           |    2 +-
 drivers/net/dl2k.c                            |    2 +-
 drivers/net/dm9000.c                          |    2 +-
 drivers/net/e1000/e1000_ethtool.c             |    4 ++--
 drivers/net/e1000e/ethtool.c                  |    4 ++--
 drivers/net/e1000e/netdev.c                   |   12 ++++++------
 drivers/net/eepro.c                           |    2 +-
 drivers/net/eexpress.c                        |    2 +-
 drivers/net/epic100.c                         |    2 +-
 drivers/net/fealnx.c                          |    2 +-
 drivers/net/fec_mpc52xx.c                     |    6 +++---
 drivers/net/forcedeth.c                       |    6 +++---
 drivers/net/hamachi.c                         |    2 +-
 drivers/net/ibmveth.c                         |    2 +-
 drivers/net/igb/igb_ethtool.c                 |    8 ++++----
 drivers/net/igb/igb_main.c                    |    8 ++++----
 drivers/net/igbvf/netdev.c                    |    6 +++---
 drivers/net/irda/au1k_ir.c                    |    4 ++--
 drivers/net/isa-skeleton.c                    |    4 ++--
 drivers/net/ixgb/ixgb_main.c                  |    2 +-
 drivers/net/ixgbe/ixgbe_ethtool.c             |    6 +++---
 drivers/net/ixgbe/ixgbe_main.c                |    6 +++---
 drivers/net/jazzsonic.c                       |    2 +-
 drivers/net/korina.c                          |    8 ++++----
 drivers/net/lance.c                           |    2 +-
 drivers/net/lib82596.c                        |    2 +-
 drivers/net/lp486e.c                          |    2 +-
 drivers/net/mac89x0.c                         |    2 +-
 drivers/net/macsonic.c                        |    4 ++--
 drivers/net/mipsnet.c                         |    2 +-
 drivers/net/myri_sbus.c                       |    2 +-
 drivers/net/natsemi.c                         |    2 +-
 drivers/net/netx-eth.c                        |    2 +-
 drivers/net/ni5010.c                          |    2 +-
 drivers/net/ni52.c                            |    2 +-
 drivers/net/ni65.c                            |    2 +-
 drivers/net/pasemi_mac.c                      |    4 ++--
 drivers/net/pcnet32.c                         |    2 +-
 drivers/net/s6gmac.c                          |    2 +-
 drivers/net/sb1000.c                          |    2 +-
 drivers/net/sb1250-mac.c                      |    2 +-
 drivers/net/seeq8005.c                        |    4 ++--
 drivers/net/sh_eth.c                          |    2 +-
 drivers/net/sis900.c                          |    2 +-
 drivers/net/smc911x.c                         |    2 +-
 drivers/net/smc9194.c                         |    2 +-
 drivers/net/smc91x.c                          |    2 +-
 drivers/net/starfire.c                        |    2 +-
 drivers/net/stmmac/stmmac_main.c              |    2 +-
 drivers/net/sun3_82586.c                      |    2 +-
 drivers/net/sunbmac.c                         |    2 +-
 drivers/net/sundance.c                        |    2 +-
 drivers/net/sunhme.c                          |    2 +-
 drivers/net/sunlance.c                        |    2 +-
 drivers/net/sunqe.c                           |    2 +-
 drivers/net/tc35815.c                         |    2 +-
 drivers/net/tehuti.c                          |    2 +-
 drivers/net/tokenring/ibmtr.c                 |    2 +-
 drivers/net/tokenring/lanstreamer.c           |    2 +-
 drivers/net/tulip/dmfe.c                      |    2 +-
 drivers/net/tulip/tulip_core.c                |    4 ++--
 drivers/net/tulip/uli526x.c                   |    2 +-
 drivers/net/tulip/winbond-840.c               |    2 +-
 drivers/net/tulip/xircom_cb.c                 |    2 +-
 drivers/net/wan/hostess_sv11.c                |    2 +-
 drivers/net/wan/lmc/lmc_main.c                |    2 +-
 drivers/net/wan/n2.c                          |    2 +-
 drivers/net/wan/sdla.c                        |    2 +-
 drivers/net/wan/sealevel.c                    |    2 +-
 drivers/net/wireless/mwl8k.c                  |    4 ++--
 drivers/net/wireless/prism54/islpci_hotplug.c |    2 +-
 drivers/net/xilinx_emaclite.c                 |    2 +-
 drivers/net/xtsonic.c                         |    2 +-
 drivers/net/yellowfin.c                       |    2 +-
 drivers/net/znet.c                            |    2 +-
 96 files changed, 131 insertions(+), 131 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index f603091..62ceb2b 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -345,7 +345,7 @@ static int el_open(struct net_device *dev)
 	if (el_debug > 2)
 		pr_debug("%s: Doing el_open()...\n", dev->name);
 
-	retval = request_irq(dev->irq, &el_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, el_interrupt, 0, dev->name, dev);
 	if (retval)
 		return retval;
 
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index a21c9d1..9257d7c 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -886,7 +886,7 @@ static int elp_open(struct net_device *dev)
 	/*
 	 * install our interrupt service routine
 	 */
-	if ((retval = request_irq(dev->irq, &elp_interrupt, 0, dev->name, dev))) {
+	if ((retval = request_irq(dev->irq, elp_interrupt, 0, dev->name, dev))) {
 		pr_err("%s: could not allocate IRQ%d\n", dev->name, dev->irq);
 		return retval;
 	}
diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index a6dc8bc..605f1d1 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -399,7 +399,7 @@ static int __init el16_probe1(struct net_device *dev, int ioaddr)
 
 	irq = inb(ioaddr + IRQ_CONFIG) & 0x0f;
 
-	irqval = request_irq(irq, &el16_interrupt, 0, DRV_NAME, dev);
+	irqval = request_irq(irq, el16_interrupt, 0, DRV_NAME, dev);
 	if (irqval) {
 		pr_cont("\n");
 		pr_err("3c507: unable to get IRQ %d (irqval=%d).\n", irq, irqval);
diff --git a/drivers/net/3c509.c b/drivers/net/3c509.c
index 3b00a4e..8d4ce09 100644
--- a/drivers/net/3c509.c
+++ b/drivers/net/3c509.c
@@ -780,7 +780,7 @@ el3_open(struct net_device *dev)
 	outw(RxReset, ioaddr + EL3_CMD);
 	outw(SetStatusEnb | 0x00, ioaddr + EL3_CMD);
 
-	i = request_irq(dev->irq, &el3_interrupt, 0, dev->name, dev);
+	i = request_irq(dev->irq, el3_interrupt, 0, dev->name, dev);
 	if (i)
 		return i;
 
diff --git a/drivers/net/3c515.c b/drivers/net/3c515.c
index 4adcb95..37faf36 100644
--- a/drivers/net/3c515.c
+++ b/drivers/net/3c515.c
@@ -766,11 +766,11 @@ static int corkscrew_open(struct net_device *dev)
 		/* Corkscrew: Cannot share ISA resources. */
 		if (dev->irq == 0
 		    || dev->dma == 0
-		    || request_irq(dev->irq, &corkscrew_interrupt, 0,
+		    || request_irq(dev->irq, corkscrew_interrupt, 0,
 				   vp->product_name, dev)) return -EAGAIN;
 		enable_dma(dev->dma);
 		set_dma_mode(dev->dma, DMA_MODE_CASCADE);
-	} else if (request_irq(dev->irq, &corkscrew_interrupt, IRQF_SHARED,
+	} else if (request_irq(dev->irq, corkscrew_interrupt, IRQF_SHARED,
 			       vp->product_name, dev)) {
 		return -EAGAIN;
 	}
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index cb0b730..27d80ca 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -288,7 +288,7 @@ static int elmc_open(struct net_device *dev)
 
 	elmc_id_attn586();	/* disable interrupts */
 
-	ret = request_irq(dev->irq, &elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
+	ret = request_irq(dev->irq, elmc_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM,
 			  dev->name, dev);
 	if (ret) {
 		pr_err("%s: couldn't get irq %d\n", dev->name, dev->irq);
diff --git a/drivers/net/3c527.c b/drivers/net/3c527.c
index 6021e6d..d91c346 100644
--- a/drivers/net/3c527.c
+++ b/drivers/net/3c527.c
@@ -443,7 +443,7 @@ static int __init mc32_probe1(struct net_device *dev, int slot)
 	 *	Grab the IRQ
 	 */
 
-	err = request_irq(dev->irq, &mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
+	err = request_irq(dev->irq, mc32_interrupt, IRQF_SHARED | IRQF_SAMPLE_RANDOM, DRV_NAME, dev);
 	if (err) {
 		release_region(dev->base_addr, MC32_IO_EXTENT);
 		pr_err("%s: unable to get IRQ %d.\n", DRV_NAME, dev->irq);
diff --git a/drivers/net/appletalk/cops.c b/drivers/net/appletalk/cops.c
index b5dc7f5..50cecf4 100644
--- a/drivers/net/appletalk/cops.c
+++ b/drivers/net/appletalk/cops.c
@@ -328,7 +328,7 @@ static int __init cops_probe1(struct net_device *dev, int ioaddr)
 
 	/* Reserve any actual interrupt. */
 	if (dev->irq) {
-		retval = request_irq(dev->irq, &cops_interrupt, 0, dev->name, dev);
+		retval = request_irq(dev->irq, cops_interrupt, 0, dev->name, dev);
 		if (retval)
 			goto err_out;
 	}
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 08760ba..dbfbd3b 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -1158,7 +1158,7 @@ struct net_device * __init ltpc_probe(void)
 	}
 
 	/* grab it and don't let go :-) */
-	if (irq && request_irq( irq, &ltpc_interrupt, 0, "ltpc", dev) >= 0)
+	if (irq && request_irq( irq, ltpc_interrupt, 0, "ltpc", dev) >= 0)
 	{
 		(void) inb_p(io+7);  /* enable interrupts from board */
 		(void) inb_p(io+7);  /* and reset irq line */
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index e3082a9..c5b9881 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -156,7 +156,7 @@ static int __init arcrimi_found(struct net_device *dev)
 	}
 
 	/* reserve the irq */
-	if (request_irq(dev->irq, &arcnet_interrupt, 0, "arcnet (RIM I)", dev)) {
+	if (request_irq(dev->irq, arcnet_interrupt, 0, "arcnet (RIM I)", dev)) {
 		iounmap(p);
 		release_mem_region(dev->mem_start, MIRROR_SIZE);
 		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 651275a..0a74f21 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -200,7 +200,7 @@ int com20020_found(struct net_device *dev, int shared)
 	outb(dev->dev_addr[0], _XREG);
 
 	/* reserve the irq */
-	if (request_irq(dev->irq, &arcnet_interrupt, shared,
+	if (request_irq(dev->irq, arcnet_interrupt, shared,
 			"arcnet (COM20020)", dev)) {
 		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 89de29b..28dea51 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -238,7 +238,7 @@ static int __init com90io_found(struct net_device *dev)
 	int err;
 
 	/* Reserve the irq */
-	if (request_irq(dev->irq, &arcnet_interrupt, 0, "arcnet (COM90xx-IO)", dev)) {
+	if (request_irq(dev->irq, arcnet_interrupt, 0, "arcnet (COM90xx-IO)", dev)) {
 		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", dev->irq);
 		return -ENODEV;
 	}
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index d762fe4..112e230 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -501,7 +501,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 		goto err_free_dev;
 
 	/* reserve the irq */
-	if (request_irq(airq, &arcnet_interrupt, 0, "arcnet (90xx)", dev)) {
+	if (request_irq(airq, arcnet_interrupt, 0, "arcnet (90xx)", dev)) {
 		BUGMSG(D_NORMAL, "Can't get IRQ %d!\n", airq);
 		goto err_release_mem;
 	}
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 544d5af..d4ab69f 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -468,7 +468,7 @@ found:
 	lp->jumpered = is_fmv18x;
 	lp->mca_slot = slot;
 	/* Snarf the interrupt vector now. */
-	ret = request_irq(irq, &net_interrupt, 0, DRV_NAME, dev);
+	ret = request_irq(irq, net_interrupt, 0, DRV_NAME, dev);
 	if (ret) {
 		printk(KERN_ERR "AT1700 at %#3x is unusable due to a "
 		       "conflict on IRQ %d.\n",
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 8b889ab..ad17e74 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1930,7 +1930,7 @@ static int atl1e_request_irq(struct atl1e_adapter *adapter)
 
 	if (!adapter->have_msi)
 		flags |= IRQF_SHARED;
-	err = request_irq(adapter->pdev->irq, &atl1e_intr, flags,
+	err = request_irq(adapter->pdev->irq, atl1e_intr, flags,
 			netdev->name, netdev);
 	if (err) {
 		dev_dbg(&pdev->dev,
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 963df50..e547f78 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2589,7 +2589,7 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 		irq_flags |= IRQF_SHARED;
 	}
 
-	err = request_irq(adapter->pdev->irq, &atl1_intr, irq_flags,
+	err = request_irq(adapter->pdev->irq, atl1_intr, irq_flags,
 			netdev->name, netdev);
 	if (unlikely(err))
 		goto err_up;
diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
index 0d26807..c0451d7 100644
--- a/drivers/net/atlx/atl2.c
+++ b/drivers/net/atlx/atl2.c
@@ -651,7 +651,7 @@ static int atl2_request_irq(struct atl2_adapter *adapter)
 	if (adapter->have_msi)
 		flags &= ~IRQF_SHARED;
 
-	return request_irq(adapter->pdev->irq, &atl2_intr, flags, netdev->name,
+	return request_irq(adapter->pdev->irq, atl2_intr, flags, netdev->name,
 		netdev);
 }
 
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 9043294..0017917 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -437,7 +437,7 @@ static int net_open(struct net_device *dev)
 	/* The interrupt line is turned off (tri-stated) when the device isn't in
 	   use.  That's especially important for "attached" interfaces where the
 	   port or interrupt may be shared. */
-	ret = request_irq(dev->irq, &atp_interrupt, 0, dev->name, dev);
+	ret = request_irq(dev->irq, atp_interrupt, 0, dev->name, dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index ce6f1ac..e67533c 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -881,7 +881,7 @@ static int au1000_open(struct net_device *dev)
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
 
-	if ((retval = request_irq(dev->irq, &au1000_interrupt, 0,
+	if ((retval = request_irq(dev->irq, au1000_interrupt, 0,
 					dev->name, dev))) {
 		printk(KERN_ERR "%s: unable to get IRQ %d\n",
 				dev->name, dev->irq);
diff --git a/drivers/net/cs89x0.c b/drivers/net/cs89x0.c
index 0c54219..af93216 100644
--- a/drivers/net/cs89x0.c
+++ b/drivers/net/cs89x0.c
@@ -1323,7 +1323,7 @@ net_open(struct net_device *dev)
 		writereg(dev, PP_BusCTL, ENABLE_IRQ | MEMORY_ON);
 #endif
 		write_irq(dev, lp->chip_type, dev->irq);
-		ret = request_irq(dev->irq, &net_interrupt, 0, dev->name, dev);
+		ret = request_irq(dev->irq, net_interrupt, 0, dev->name, dev);
 		if (ret) {
 			if (net_debug)
 				printk(KERN_DEBUG "cs89x0: request_irq(%d) failed\n", dev->irq);
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index a31696a..be95902 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -801,14 +801,14 @@ static int lance_open(struct net_device *dev)
 	netif_start_queue(dev);
 
 	/* Associate IRQ with lance_interrupt */
-	if (request_irq(dev->irq, &lance_interrupt, 0, "lance", dev)) {
+	if (request_irq(dev->irq, lance_interrupt, 0, "lance", dev)) {
 		printk("%s: Can't get IRQ %d\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
 	if (lp->dma_irq >= 0) {
 		unsigned long flags;
 
-		if (request_irq(lp->dma_irq, &lance_dma_merr_int, 0,
+		if (request_irq(lp->dma_irq, lance_dma_merr_int, 0,
 				"lance error", dev)) {
 			free_irq(dev->irq, dev);
 			printk("%s: Can't get DMA IRQ %d\n", dev->name,
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 9686c1f..b158be4 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -848,7 +848,7 @@ static int depca_open(struct net_device *dev)
 
 	depca_dbg_open(dev);
 
-	if (request_irq(dev->irq, &depca_interrupt, 0, lp->adapter_name, dev)) {
+	if (request_irq(dev->irq, depca_interrupt, 0, lp->adapter_name, dev)) {
 		printk("depca_open(): Requested IRQ%d is busy\n", dev->irq);
 		status = -EAGAIN;
 	} else {
diff --git a/drivers/net/dl2k.c b/drivers/net/dl2k.c
index ce8fef1..a2f1860 100644
--- a/drivers/net/dl2k.c
+++ b/drivers/net/dl2k.c
@@ -411,7 +411,7 @@ rio_open (struct net_device *dev)
 	int i;
 	u16 macctrl;
 
-	i = request_irq (dev->irq, &rio_interrupt, IRQF_SHARED, dev->name, dev);
+	i = request_irq (dev->irq, rio_interrupt, IRQF_SHARED, dev->name, dev);
 	if (i)
 		return i;
 
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index 3aab2e4..81590fb 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -1175,7 +1175,7 @@ dm9000_open(struct net_device *dev)
 
 	irqflags |= IRQF_SHARED;
 
-	if (request_irq(dev->irq, &dm9000_interrupt, irqflags, dev->name, dev))
+	if (request_irq(dev->irq, dm9000_interrupt, irqflags, dev->name, dev))
 		return -EAGAIN;
 
 	/* Initialize DM9000 board */
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index ffbae0a..13e9ece 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -869,10 +869,10 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 
 	/* NOTE: we don't test MSI interrupts here, yet */
 	/* Hook up test interrupt handler just for this test */
-	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
+	if (!request_irq(irq, e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
 	                 netdev))
 		shared_int = false;
-	else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
+	else if (request_irq(irq, e1000_test_intr, IRQF_SHARED,
 	         netdev->name, netdev)) {
 		*data = 1;
 		return -1;
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 0364b91..c430dc8 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -937,10 +937,10 @@ static int e1000_intr_test(struct e1000_adapter *adapter, u64 *data)
 		e1000e_set_interrupt_capability(adapter);
 	}
 	/* Hook up test interrupt handler just for this test */
-	if (!request_irq(irq, &e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
+	if (!request_irq(irq, e1000_test_intr, IRQF_PROBE_SHARED, netdev->name,
 			 netdev)) {
 		shared_int = 0;
-	} else if (request_irq(irq, &e1000_test_intr, IRQF_SHARED,
+	} else if (request_irq(irq, e1000_test_intr, IRQF_SHARED,
 		 netdev->name, netdev)) {
 		*data = 1;
 		ret_val = -1;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3769248..3caa1d5 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1458,7 +1458,7 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	else
 		memcpy(adapter->rx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &e1000_intr_msix_rx, 0, adapter->rx_ring->name,
+			  e1000_intr_msix_rx, 0, adapter->rx_ring->name,
 			  netdev);
 	if (err)
 		goto out;
@@ -1471,7 +1471,7 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	else
 		memcpy(adapter->tx_ring->name, netdev->name, IFNAMSIZ);
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &e1000_intr_msix_tx, 0, adapter->tx_ring->name,
+			  e1000_intr_msix_tx, 0, adapter->tx_ring->name,
 			  netdev);
 	if (err)
 		goto out;
@@ -1480,7 +1480,7 @@ static int e1000_request_msix(struct e1000_adapter *adapter)
 	vector++;
 
 	err = request_irq(adapter->msix_entries[vector].vector,
-			  &e1000_msix_other, 0, netdev->name, netdev);
+			  e1000_msix_other, 0, netdev->name, netdev);
 	if (err)
 		goto out;
 
@@ -1511,7 +1511,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 		e1000e_set_interrupt_capability(adapter);
 	}
 	if (adapter->flags & FLAG_MSI_ENABLED) {
-		err = request_irq(adapter->pdev->irq, &e1000_intr_msi, 0,
+		err = request_irq(adapter->pdev->irq, e1000_intr_msi, 0,
 				  netdev->name, netdev);
 		if (!err)
 			return err;
@@ -1521,7 +1521,7 @@ static int e1000_request_irq(struct e1000_adapter *adapter)
 		adapter->int_mode = E1000E_INT_MODE_LEGACY;
 	}
 
-	err = request_irq(adapter->pdev->irq, &e1000_intr, IRQF_SHARED,
+	err = request_irq(adapter->pdev->irq, e1000_intr, IRQF_SHARED,
 			  netdev->name, netdev);
 	if (err)
 		e_err("Unable to allocate interrupt, Error: %d\n", err);
@@ -2970,7 +2970,7 @@ static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
 	if (err)
 		goto msi_test_failed;
 
-	err = request_irq(adapter->pdev->irq, &e1000_intr_msi_test, 0,
+	err = request_irq(adapter->pdev->irq, e1000_intr_msi_test, 0,
 			  netdev->name, netdev);
 	if (err) {
 		pci_disable_msi(adapter->pdev);
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 1e93416..94c5949 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -990,7 +990,7 @@ static int eepro_open(struct net_device *dev)
 		return -EAGAIN;
 	}
 
-	if (request_irq(dev->irq , &eepro_interrupt, 0, dev->name, dev)) {
+	if (request_irq(dev->irq , eepro_interrupt, 0, dev->name, dev)) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 592de8f..6fbfc8e 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -457,7 +457,7 @@ static int eexp_open(struct net_device *dev)
 	if (!dev->irq || !irqrmap[dev->irq])
 		return -ENXIO;
 
-	ret = request_irq(dev->irq, &eexp_irq, 0, dev->name, dev);
+	ret = request_irq(dev->irq, eexp_irq, 0, dev->name, dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 641a10d..703b4c8 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -668,7 +668,7 @@ static int epic_open(struct net_device *dev)
 	outl(0x4001, ioaddr + GENCTL);
 
 	napi_enable(&ep->napi);
-	if ((retval = request_irq(dev->irq, &epic_interrupt, IRQF_SHARED, dev->name, dev))) {
+	if ((retval = request_irq(dev->irq, epic_interrupt, IRQF_SHARED, dev->name, dev))) {
 		napi_disable(&ep->napi);
 		return retval;
 	}
diff --git a/drivers/net/fealnx.c b/drivers/net/fealnx.c
index 18d5fbb..e173515 100644
--- a/drivers/net/fealnx.c
+++ b/drivers/net/fealnx.c
@@ -839,7 +839,7 @@ static int netdev_open(struct net_device *dev)
 
 	iowrite32(0x00000001, ioaddr + BCR);	/* Reset */
 
-	if (request_irq(dev->irq, &intr_handler, IRQF_SHARED, dev->name, dev))
+	if (request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev))
 		return -EAGAIN;
 
 	for (i = 0; i < 3; i++)
diff --git a/drivers/net/fec_mpc52xx.c b/drivers/net/fec_mpc52xx.c
index 66dace6..6407672 100644
--- a/drivers/net/fec_mpc52xx.c
+++ b/drivers/net/fec_mpc52xx.c
@@ -226,17 +226,17 @@ static int mpc52xx_fec_open(struct net_device *dev)
 		phy_start(priv->phydev);
 	}
 
-	if (request_irq(dev->irq, &mpc52xx_fec_interrupt, IRQF_SHARED,
+	if (request_irq(dev->irq, mpc52xx_fec_interrupt, IRQF_SHARED,
 	                DRIVER_NAME "_ctrl", dev)) {
 		dev_err(&dev->dev, "ctrl interrupt request failed\n");
 		goto free_phy;
 	}
-	if (request_irq(priv->r_irq, &mpc52xx_fec_rx_interrupt, 0,
+	if (request_irq(priv->r_irq, mpc52xx_fec_rx_interrupt, 0,
 	                DRIVER_NAME "_rx", dev)) {
 		dev_err(&dev->dev, "rx interrupt request failed\n");
 		goto free_ctrl_irq;
 	}
-	if (request_irq(priv->t_irq, &mpc52xx_fec_tx_interrupt, 0,
+	if (request_irq(priv->t_irq, mpc52xx_fec_tx_interrupt, 0,
 	                DRIVER_NAME "_tx", dev)) {
 		dev_err(&dev->dev, "tx interrupt request failed\n");
 		goto free_2irqs;
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 73fe977..59ade97 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4003,7 +4003,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				/* Request irq for rx handling */
 				sprintf(np->name_rx, "%s-rx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
-						&nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
+						nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for rx %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -4012,7 +4012,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				/* Request irq for tx handling */
 				sprintf(np->name_tx, "%s-tx", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
-						&nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
+						nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for tx %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -4021,7 +4021,7 @@ static int nv_request_irq(struct net_device *dev, int intr_test)
 				/* Request irq for link and timer handling */
 				sprintf(np->name_other, "%s-other", dev->name);
 				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
-						&nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
+						nv_nic_irq_other, IRQF_SHARED, np->name_other, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed for link %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
index 18bd9fe..0281227 100644
--- a/drivers/net/hamachi.c
+++ b/drivers/net/hamachi.c
@@ -871,7 +871,7 @@ static int hamachi_open(struct net_device *dev)
 	u32 rx_int_var, tx_int_var;
 	u16 fifo_info;
 
-	i = request_irq(dev->irq, &hamachi_interrupt, IRQF_SHARED, dev->name, dev);
+	i = request_irq(dev->irq, hamachi_interrupt, IRQF_SHARED, dev->name, dev);
 	if (i)
 		return i;
 
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index 5862282..a866939 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -625,7 +625,7 @@ static int ibmveth_open(struct net_device *netdev)
 	}
 
 	ibmveth_debug_printk("registering irq 0x%x\n", netdev->irq);
-	if((rc = request_irq(netdev->irq, &ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
+	if((rc = request_irq(netdev->irq, ibmveth_interrupt, 0, netdev->name, netdev)) != 0) {
 		ibmveth_error_printk("unable to request irq 0x%x, rc %d\n", netdev->irq, rc);
 		do {
 			rc = h_free_logical_lan(adapter->vdev->unit_address);
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index c1cde5b..02f1eb2 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1132,21 +1132,21 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	/* Hook up test interrupt handler just for this test */
 	if (adapter->msix_entries) {
 		if (request_irq(adapter->msix_entries[0].vector,
-		                &igb_test_intr, 0, netdev->name, adapter)) {
+		                igb_test_intr, 0, netdev->name, adapter)) {
 			*data = 1;
 			return -1;
 		}
 	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int = false;
 		if (request_irq(irq,
-		                &igb_test_intr, 0, netdev->name, adapter)) {
+		                igb_test_intr, 0, netdev->name, adapter)) {
 			*data = 1;
 			return -1;
 		}
-	} else if (!request_irq(irq, &igb_test_intr, IRQF_PROBE_SHARED,
+	} else if (!request_irq(irq, igb_test_intr, IRQF_PROBE_SHARED,
 				netdev->name, adapter)) {
 		shared_int = false;
-	} else if (request_irq(irq, &igb_test_intr, IRQF_SHARED,
+	} else if (request_irq(irq, igb_test_intr, IRQF_SHARED,
 		 netdev->name, adapter)) {
 		*data = 1;
 		return -1;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 0cab5e2..958305e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -525,7 +525,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 	int i, err = 0, vector = 0;
 
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  &igb_msix_other, 0, netdev->name, adapter);
+	                  igb_msix_other, 0, netdev->name, adapter);
 	if (err)
 		goto out;
 	vector++;
@@ -548,7 +548,7 @@ static int igb_request_msix(struct igb_adapter *adapter)
 			sprintf(q_vector->name, "%s-unused", netdev->name);
 
 		err = request_irq(adapter->msix_entries[vector].vector,
-		                  &igb_msix_ring, 0, q_vector->name,
+		                  igb_msix_ring, 0, q_vector->name,
 		                  q_vector);
 		if (err)
 			goto out;
@@ -875,7 +875,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	}
 
 	if (adapter->flags & IGB_FLAG_HAS_MSI) {
-		err = request_irq(adapter->pdev->irq, &igb_intr_msi, 0,
+		err = request_irq(adapter->pdev->irq, igb_intr_msi, 0,
 				  netdev->name, adapter);
 		if (!err)
 			goto request_done;
@@ -885,7 +885,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		adapter->flags &= ~IGB_FLAG_HAS_MSI;
 	}
 
-	err = request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
+	err = request_irq(adapter->pdev->irq, igb_intr, IRQF_SHARED,
 			  netdev->name, adapter);
 
 	if (err)
diff --git a/drivers/net/igbvf/netdev.c b/drivers/net/igbvf/netdev.c
index fad7f34..e01f445 100644
--- a/drivers/net/igbvf/netdev.c
+++ b/drivers/net/igbvf/netdev.c
@@ -1043,7 +1043,7 @@ static int igbvf_request_msix(struct igbvf_adapter *adapter)
 	}
 
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  &igbvf_intr_msix_tx, 0, adapter->tx_ring->name,
+	                  igbvf_intr_msix_tx, 0, adapter->tx_ring->name,
 	                  netdev);
 	if (err)
 		goto out;
@@ -1053,7 +1053,7 @@ static int igbvf_request_msix(struct igbvf_adapter *adapter)
 	vector++;
 
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  &igbvf_intr_msix_rx, 0, adapter->rx_ring->name,
+	                  igbvf_intr_msix_rx, 0, adapter->rx_ring->name,
 	                  netdev);
 	if (err)
 		goto out;
@@ -1063,7 +1063,7 @@ static int igbvf_request_msix(struct igbvf_adapter *adapter)
 	vector++;
 
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  &igbvf_msix_other, 0, netdev->name, netdev);
+	                  igbvf_msix_other, 0, netdev->name, netdev);
 	if (err)
 		goto out;
 
diff --git a/drivers/net/irda/au1k_ir.c b/drivers/net/irda/au1k_ir.c
index eb42468..9b2eebd 100644
--- a/drivers/net/irda/au1k_ir.c
+++ b/drivers/net/irda/au1k_ir.c
@@ -353,13 +353,13 @@ static int au1k_irda_start(struct net_device *dev)
 		return retval;
 	}
 
-	if ((retval = request_irq(AU1000_IRDA_TX_INT, &au1k_irda_interrupt, 
+	if ((retval = request_irq(AU1000_IRDA_TX_INT, au1k_irda_interrupt, 
 					0, dev->name, dev))) {
 		printk(KERN_ERR "%s: unable to get IRQ %d\n", 
 				dev->name, dev->irq);
 		return retval;
 	}
-	if ((retval = request_irq(AU1000_IRDA_RX_INT, &au1k_irda_interrupt, 
+	if ((retval = request_irq(AU1000_IRDA_RX_INT, au1k_irda_interrupt, 
 					0, dev->name, dev))) {
 		free_irq(AU1000_IRDA_TX_INT, dev);
 		printk(KERN_ERR "%s: unable to get IRQ %d\n", 
diff --git a/drivers/net/isa-skeleton.c b/drivers/net/isa-skeleton.c
index 9706e64..0e71e2a 100644
--- a/drivers/net/isa-skeleton.c
+++ b/drivers/net/isa-skeleton.c
@@ -260,7 +260,7 @@ static int __init netcard_probe1(struct net_device *dev, int ioaddr)
 		dev->irq = 9;
 
 	{
-		int irqval = request_irq(dev->irq, &net_interrupt, 0, cardname, dev);
+		int irqval = request_irq(dev->irq, net_interrupt, 0, cardname, dev);
 		if (irqval) {
 			printk("%s: unable to get IRQ %d (irqval=%d).\n",
 				   dev->name, dev->irq, irqval);
@@ -378,7 +378,7 @@ net_open(struct net_device *dev)
 	 * This is used if the interrupt line can turned off (shared).
 	 * See 3c503.c for an example of selecting the IRQ at config-time.
 	 */
-	if (request_irq(dev->irq, &net_interrupt, 0, cardname, dev)) {
+	if (request_irq(dev->irq, net_interrupt, 0, cardname, dev)) {
 		return -EAGAIN;
 	}
 	/*
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 1bd0ca1..7364606 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -233,7 +233,7 @@ ixgb_up(struct ixgb_adapter *adapter)
 		/* proceed to try to request regular interrupt */
 	}
 
-	err = request_irq(adapter->pdev->irq, &ixgb_intr, irq_flags,
+	err = request_irq(adapter->pdev->irq, ixgb_intr, irq_flags,
 	                  netdev->name, netdev);
 	if (err) {
 		if (adapter->have_msi)
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 9d2cc83..74f04e1 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1274,15 +1274,15 @@ static int ixgbe_intr_test(struct ixgbe_adapter *adapter, u64 *data)
 		return 0;
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
 		shared_int = false;
-		if (request_irq(irq, &ixgbe_test_intr, 0, netdev->name,
+		if (request_irq(irq, ixgbe_test_intr, 0, netdev->name,
 				netdev)) {
 			*data = 1;
 			return -1;
 		}
-	} else if (!request_irq(irq, &ixgbe_test_intr, IRQF_PROBE_SHARED,
+	} else if (!request_irq(irq, ixgbe_test_intr, IRQF_PROBE_SHARED,
 	                        netdev->name, netdev)) {
 		shared_int = false;
-	} else if (request_irq(irq, &ixgbe_test_intr, IRQF_SHARED,
+	} else if (request_irq(irq, ixgbe_test_intr, IRQF_SHARED,
 	                       netdev->name, netdev)) {
 		*data = 1;
 		return -1;
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index dceed80..ebcec30 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1661,7 +1661,7 @@ static int ixgbe_request_msix_irqs(struct ixgbe_adapter *adapter)
 
 	sprintf(adapter->name[vector], "%s:lsc", netdev->name);
 	err = request_irq(adapter->msix_entries[vector].vector,
-	                  &ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
+	                  ixgbe_msix_lsc, 0, adapter->name[vector], netdev);
 	if (err) {
 		DPRINTK(PROBE, ERR,
 			"request_irq for msix_lsc failed: %d\n", err);
@@ -1832,10 +1832,10 @@ static int ixgbe_request_irq(struct ixgbe_adapter *adapter)
 	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
 		err = ixgbe_request_msix_irqs(adapter);
 	} else if (adapter->flags & IXGBE_FLAG_MSI_ENABLED) {
-		err = request_irq(adapter->pdev->irq, &ixgbe_intr, 0,
+		err = request_irq(adapter->pdev->irq, ixgbe_intr, 0,
 		                  netdev->name, netdev);
 	} else {
-		err = request_irq(adapter->pdev->irq, &ixgbe_intr, IRQF_SHARED,
+		err = request_irq(adapter->pdev->irq, ixgbe_intr, IRQF_SHARED,
 		                  netdev->name, netdev);
 	}
 
diff --git a/drivers/net/jazzsonic.c b/drivers/net/jazzsonic.c
index 6e5b3f3..35d5bed 100644
--- a/drivers/net/jazzsonic.c
+++ b/drivers/net/jazzsonic.c
@@ -81,7 +81,7 @@ static unsigned short known_revisions[] =
 
 static int jazzsonic_open(struct net_device* dev)
 {
-	if (request_irq(dev->irq, &sonic_interrupt, IRQF_DISABLED, "sonic", dev)) {
+	if (request_irq(dev->irq, sonic_interrupt, IRQF_DISABLED, "sonic", dev)) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
diff --git a/drivers/net/korina.c b/drivers/net/korina.c
index a07a597..25e2af6 100644
--- a/drivers/net/korina.c
+++ b/drivers/net/korina.c
@@ -1014,14 +1014,14 @@ static int korina_open(struct net_device *dev)
 	/* Install the interrupt handler
 	 * that handles the Done Finished
 	 * Ovr and Und Events */
-	ret = request_irq(lp->rx_irq, &korina_rx_dma_interrupt,
+	ret = request_irq(lp->rx_irq, korina_rx_dma_interrupt,
 			IRQF_DISABLED, "Korina ethernet Rx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Rx DMA IRQ %d\n",
 		    dev->name, lp->rx_irq);
 		goto err_release;
 	}
-	ret = request_irq(lp->tx_irq, &korina_tx_dma_interrupt,
+	ret = request_irq(lp->tx_irq, korina_tx_dma_interrupt,
 			IRQF_DISABLED, "Korina ethernet Tx", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get Tx DMA IRQ %d\n",
@@ -1030,7 +1030,7 @@ static int korina_open(struct net_device *dev)
 	}
 
 	/* Install handler for overrun error. */
-	ret = request_irq(lp->ovr_irq, &korina_ovr_interrupt,
+	ret = request_irq(lp->ovr_irq, korina_ovr_interrupt,
 			IRQF_DISABLED, "Ethernet Overflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get OVR IRQ %d\n",
@@ -1039,7 +1039,7 @@ static int korina_open(struct net_device *dev)
 	}
 
 	/* Install handler for underflow error. */
-	ret = request_irq(lp->und_irq, &korina_und_interrupt,
+	ret = request_irq(lp->und_irq, korina_und_interrupt,
 			IRQF_DISABLED, "Ethernet Underflow", dev);
 	if (ret < 0) {
 		printk(KERN_ERR "%s: unable to get UND IRQ %d\n",
diff --git a/drivers/net/lance.c b/drivers/net/lance.c
index dcda303..7b2c429 100644
--- a/drivers/net/lance.c
+++ b/drivers/net/lance.c
@@ -755,7 +755,7 @@ lance_open(struct net_device *dev)
 	int i;
 
 	if (dev->irq == 0 ||
-		request_irq(dev->irq, &lance_interrupt, 0, lp->name, dev)) {
+		request_irq(dev->irq, lance_interrupt, 0, lp->name, dev)) {
 		return -EAGAIN;
 	}
 
diff --git a/drivers/net/lib82596.c b/drivers/net/lib82596.c
index 5b24c67..7a07430 100644
--- a/drivers/net/lib82596.c
+++ b/drivers/net/lib82596.c
@@ -588,7 +588,7 @@ static int init_i596_mem(struct net_device *dev)
 			     "%s: i82596 initialization successful\n",
 			     dev->name));
 
-	if (request_irq(dev->irq, &i596_interrupt, 0, "i82596", dev)) {
+	if (request_irq(dev->irq, i596_interrupt, 0, "i82596", dev)) {
 		printk(KERN_ERR "%s: IRQ %d not free\n", dev->name, dev->irq);
 		goto failed;
 	}
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index cc3ed9c..e20fefc 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -845,7 +845,7 @@ static int i596_open(struct net_device *dev)
 {
 	int i;
 
-	i = request_irq(dev->irq, &i596_interrupt, IRQF_SHARED, dev->name, dev);
+	i = request_irq(dev->irq, i596_interrupt, IRQF_SHARED, dev->name, dev);
 	if (i) {
 		printk(KERN_ERR "%s: IRQ %d not free\n", dev->name, dev->irq);
 		return i;
diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index 149e0ed..c244ec3 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -337,7 +337,7 @@ net_open(struct net_device *dev)
 	writereg(dev, PP_BusCTL, readreg(dev, PP_BusCTL) & ~ENABLE_IRQ);
 
 	/* Grab the interrupt */
-	if (request_irq(dev->irq, &net_interrupt, 0, "cs89x0", dev))
+	if (request_irq(dev->irq, net_interrupt, 0, "cs89x0", dev))
 		return -EAGAIN;
 
 	/* Set up the IRQ - Apparently magic */
diff --git a/drivers/net/macsonic.c b/drivers/net/macsonic.c
index b3d7d8d..875d361 100644
--- a/drivers/net/macsonic.c
+++ b/drivers/net/macsonic.c
@@ -140,7 +140,7 @@ static irqreturn_t macsonic_interrupt(int irq, void *dev_id)
 
 static int macsonic_open(struct net_device* dev)
 {
-	if (request_irq(dev->irq, &sonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
+	if (request_irq(dev->irq, sonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
@@ -149,7 +149,7 @@ static int macsonic_open(struct net_device* dev)
 	 * rupt as well, which must prevent re-entrance of the sonic handler.
 	 */
 	if (dev->irq == IRQ_AUTO_3)
-		if (request_irq(IRQ_NUBUS_9, &macsonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
+		if (request_irq(IRQ_NUBUS_9, macsonic_interrupt, IRQ_FLG_FAST, "sonic", dev)) {
 			printk(KERN_ERR "%s: unable to get IRQ %d.\n", dev->name, IRQ_NUBUS_9);
 			free_irq(dev->irq, dev);
 			return -EAGAIN;
diff --git a/drivers/net/mipsnet.c b/drivers/net/mipsnet.c
index 8ea98bd..8e9704f 100644
--- a/drivers/net/mipsnet.c
+++ b/drivers/net/mipsnet.c
@@ -211,7 +211,7 @@ static int mipsnet_open(struct net_device *dev)
 {
 	int err;
 
-	err = request_irq(dev->irq, &mipsnet_interrupt,
+	err = request_irq(dev->irq, mipsnet_interrupt,
 			  IRQF_SHARED, dev->name, (void *) dev);
 	if (err) {
 		release_region(dev->base_addr, sizeof(struct mipsnet_regs));
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 29ebebc..b3513ad 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -1084,7 +1084,7 @@ static int __devinit myri_sbus_probe(struct of_device *op, const struct of_devic
 
 	/* Register interrupt handler now. */
 	DET(("Requesting MYRIcom IRQ line.\n"));
-	if (request_irq(dev->irq, &myri_interrupt,
+	if (request_irq(dev->irq, myri_interrupt,
 			IRQF_SHARED, "MyriCOM Ethernet", (void *) dev)) {
 		printk("MyriCOM: Cannot register interrupt handler.\n");
 		goto err;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index b2722c4..9a8d3ab 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -1535,7 +1535,7 @@ static int netdev_open(struct net_device *dev)
 	/* Reset the chip, just in case. */
 	natsemi_reset(dev);
 
-	i = request_irq(dev->irq, &intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i) return i;
 
 	if (netif_msg_ifup(np))
diff --git a/drivers/net/netx-eth.c b/drivers/net/netx-eth.c
index a0d65f5..6477029 100644
--- a/drivers/net/netx-eth.c
+++ b/drivers/net/netx-eth.c
@@ -212,7 +212,7 @@ static int netx_eth_open(struct net_device *ndev)
 	struct netx_eth_priv *priv = netdev_priv(ndev);
 
 	if (request_irq
-	    (ndev->irq, &netx_eth_interrupt, IRQF_SHARED, ndev->name, ndev))
+	    (ndev->irq, netx_eth_interrupt, IRQF_SHARED, ndev->name, ndev))
 		return -EAGAIN;
 
 	writel(ndev->dev_addr[0] |
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 462d20f..6a87d81 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -377,7 +377,7 @@ static int ni5010_open(struct net_device *dev)
 
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_open()\n", dev->name));
 
-	if (request_irq(dev->irq, &ni5010_interrupt, 0, boardname, dev)) {
+	if (request_irq(dev->irq, ni5010_interrupt, 0, boardname, dev)) {
 		printk(KERN_WARNING "%s: Cannot get irq %#2x\n", dev->name, dev->irq);
 		return -EAGAIN;
 	}
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index aad3b37..305f4ba 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -284,7 +284,7 @@ static int ni52_open(struct net_device *dev)
 	startrecv586(dev);
 	ni_enaint();
 
-	ret = request_irq(dev->irq, &ni52_interrupt, 0, dev->name, dev);
+	ret = request_irq(dev->irq, ni52_interrupt, 0, dev->name, dev);
 	if (ret) {
 		ni_reset586();
 		return ret;
diff --git a/drivers/net/ni65.c b/drivers/net/ni65.c
index 752c2e4..ae19aaf 100644
--- a/drivers/net/ni65.c
+++ b/drivers/net/ni65.c
@@ -294,7 +294,7 @@ static void ni65_set_performance(struct priv *p)
 static int ni65_open(struct net_device *dev)
 {
 	struct priv *p = dev->ml_priv;
-	int irqval = request_irq(dev->irq, &ni65_interrupt,0,
+	int irqval = request_irq(dev->irq, ni65_interrupt,0,
                         cards[p->cardno].cardname,dev);
 	if (irqval) {
 		printk(KERN_ERR "%s: unable to get IRQ %d (irqval=%d).\n",
diff --git a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
index c254a7f..1673eb0 100644
--- a/drivers/net/pasemi_mac.c
+++ b/drivers/net/pasemi_mac.c
@@ -1216,7 +1216,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->tx_irq_name, sizeof(mac->tx_irq_name), "%s tx",
 		 dev->name);
 
-	ret = request_irq(mac->tx->chan.irq, &pasemi_mac_tx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->tx->chan.irq, pasemi_mac_tx_intr, IRQF_DISABLED,
 			  mac->tx_irq_name, mac->tx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
@@ -1227,7 +1227,7 @@ static int pasemi_mac_open(struct net_device *dev)
 	snprintf(mac->rx_irq_name, sizeof(mac->rx_irq_name), "%s rx",
 		 dev->name);
 
-	ret = request_irq(mac->rx->chan.irq, &pasemi_mac_rx_intr, IRQF_DISABLED,
+	ret = request_irq(mac->rx->chan.irq, pasemi_mac_rx_intr, IRQF_DISABLED,
 			  mac->rx_irq_name, mac->rx);
 	if (ret) {
 		dev_err(&mac->pdev->dev, "request_irq of irq %d failed: %d\n",
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 6d28b18..5a26956 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -2094,7 +2094,7 @@ static int pcnet32_open(struct net_device *dev)
 	int rc;
 	unsigned long flags;
 
-	if (request_irq(dev->irq, &pcnet32_interrupt,
+	if (request_irq(dev->irq, pcnet32_interrupt,
 			lp->shared_irq ? IRQF_SHARED : 0, dev->name,
 			(void *)dev)) {
 		return -EAGAIN;
diff --git a/drivers/net/s6gmac.c b/drivers/net/s6gmac.c
index 4525cbe..d81706e 100644
--- a/drivers/net/s6gmac.c
+++ b/drivers/net/s6gmac.c
@@ -984,7 +984,7 @@ static int __devinit s6gmac_probe(struct platform_device *pdev)
 	pd->rx_dma = DMA_MASK_DMAC(i);
 	pd->rx_chan = DMA_INDEX_CHNL(i);
 	pd->io = platform_get_resource(pdev, IORESOURCE_IO, 0)->start;
-	res = request_irq(dev->irq, &s6gmac_interrupt, 0, dev->name, dev);
+	res = request_irq(dev->irq, s6gmac_interrupt, 0, dev->name, dev);
 	if (res) {
 		printk(KERN_ERR DRV_PRMT "irq request failed: %d\n", dev->irq);
 		goto errirq;
diff --git a/drivers/net/sb1000.c b/drivers/net/sb1000.c
index ee366c5..1e854ad 100644
--- a/drivers/net/sb1000.c
+++ b/drivers/net/sb1000.c
@@ -972,7 +972,7 @@ sb1000_open(struct net_device *dev)
 	lp->rx_frame_id[1] = 0;
 	lp->rx_frame_id[2] = 0;
 	lp->rx_frame_id[3] = 0;
-	if (request_irq(dev->irq, &sb1000_interrupt, 0, "sb1000", dev)) {
+	if (request_irq(dev->irq, sb1000_interrupt, 0, "sb1000", dev)) {
 		return -EAGAIN;
 	}
 
diff --git a/drivers/net/sb1250-mac.c b/drivers/net/sb1250-mac.c
index 7269a87..564d4d7 100644
--- a/drivers/net/sb1250-mac.c
+++ b/drivers/net/sb1250-mac.c
@@ -2410,7 +2410,7 @@ static int sbmac_open(struct net_device *dev)
 	 */
 
 	__raw_readq(sc->sbm_isr);
-	err = request_irq(dev->irq, &sbmac_intr, IRQF_SHARED, dev->name, dev);
+	err = request_irq(dev->irq, sbmac_intr, IRQF_SHARED, dev->name, dev);
 	if (err) {
 		printk(KERN_ERR "%s: unable to get IRQ %d\n", dev->name,
 		       dev->irq);
diff --git a/drivers/net/seeq8005.c b/drivers/net/seeq8005.c
index 39246d4..fe806bd 100644
--- a/drivers/net/seeq8005.c
+++ b/drivers/net/seeq8005.c
@@ -335,7 +335,7 @@ static int __init seeq8005_probe1(struct net_device *dev, int ioaddr)
 
 #if 0
 	{
-		 int irqval = request_irq(dev->irq, &seeq8005_interrupt, 0, "seeq8005", dev);
+		 int irqval = request_irq(dev->irq, seeq8005_interrupt, 0, "seeq8005", dev);
 		 if (irqval) {
 			 printk ("%s: unable to get IRQ %d (irqval=%d).\n", dev->name,
 					 dev->irq, irqval);
@@ -367,7 +367,7 @@ static int seeq8005_open(struct net_device *dev)
 	struct net_local *lp = netdev_priv(dev);
 
 	{
-		 int irqval = request_irq(dev->irq, &seeq8005_interrupt, 0, "seeq8005", dev);
+		 int irqval = request_irq(dev->irq, seeq8005_interrupt, 0, "seeq8005", dev);
 		 if (irqval) {
 			 printk ("%s: unable to get IRQ %d (irqval=%d).\n", dev->name,
 					 dev->irq, irqval);
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 5783f50..c88bc10 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -1016,7 +1016,7 @@ static int sh_eth_open(struct net_device *ndev)
 
 	pm_runtime_get_sync(&mdp->pdev->dev);
 
-	ret = request_irq(ndev->irq, &sh_eth_interrupt,
+	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || defined(CONFIG_CPU_SUBTYPE_SH7764)
 				IRQF_SHARED,
 #else
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 97949d0..bd2b0df 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -1015,7 +1015,7 @@ sis900_open(struct net_device *net_dev)
 	/* Equalizer workaround Rule */
 	sis630_set_eq(net_dev, sis_priv->chipset_rev);
 
-	ret = request_irq(net_dev->irq, &sis900_interrupt, IRQF_SHARED,
+	ret = request_irq(net_dev->irq, sis900_interrupt, IRQF_SHARED,
 						net_dev->name, net_dev);
 	if (ret)
 		return ret;
diff --git a/drivers/net/smc911x.c b/drivers/net/smc911x.c
index 2a6b6de..44ebbaa 100644
--- a/drivers/net/smc911x.c
+++ b/drivers/net/smc911x.c
@@ -1984,7 +1984,7 @@ static int __devinit smc911x_probe(struct net_device *dev)
 #endif
 
 	/* Grab the IRQ */
-	retval = request_irq(dev->irq, &smc911x_interrupt,
+	retval = request_irq(dev->irq, smc911x_interrupt,
 			     irq_flags, dev->name, dev);
 	if (retval)
 		goto err_out;
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 934a120..8371b82 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1050,7 +1050,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
 
 	/* Grab the IRQ */
-      	retval = request_irq(dev->irq, &smc_interrupt, 0, DRV_NAME, dev);
+      	retval = request_irq(dev->irq, smc_interrupt, 0, DRV_NAME, dev);
       	if (retval) {
 		printk("%s: unable to get IRQ %d (irqval=%d).\n", DRV_NAME,
 			dev->irq, retval);
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index 05c91ee..0b56ab4 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2031,7 +2031,7 @@ static int __devinit smc_probe(struct net_device *dev, void __iomem *ioaddr,
 	}
 
 	/* Grab the IRQ */
-	retval = request_irq(dev->irq, &smc_interrupt, irq_flags, dev->name, dev);
+	retval = request_irq(dev->irq, smc_interrupt, irq_flags, dev->name, dev);
       	if (retval)
       		goto err_out;
 
diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
index a36e2b5..aa10158 100644
--- a/drivers/net/starfire.c
+++ b/drivers/net/starfire.c
@@ -928,7 +928,7 @@ static int netdev_open(struct net_device *dev)
 
 	/* Do we ever need to reset the chip??? */
 
-	retval = request_irq(dev->irq, &intr_handler, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		return retval;
 
diff --git a/drivers/net/stmmac/stmmac_main.c b/drivers/net/stmmac/stmmac_main.c
index c2f14dc..e961e75 100644
--- a/drivers/net/stmmac/stmmac_main.c
+++ b/drivers/net/stmmac/stmmac_main.c
@@ -1022,7 +1022,7 @@ static int stmmac_open(struct net_device *dev)
 	}
 
 	/* Request the IRQ lines */
-	ret = request_irq(dev->irq, &stmmac_interrupt,
+	ret = request_irq(dev->irq, stmmac_interrupt,
 			  IRQF_SHARED, dev->name, dev);
 	if (unlikely(ret < 0)) {
 		pr_err("%s: ERROR: allocating the IRQ %d (error: %d)\n",
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index 2f1eaaf..b447a87 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -191,7 +191,7 @@ static int sun3_82586_open(struct net_device *dev)
 	startrecv586(dev);
 	sun3_enaint();
 
-	ret = request_irq(dev->irq, &sun3_82586_interrupt,0,dev->name,dev);
+	ret = request_irq(dev->irq, sun3_82586_interrupt,0,dev->name,dev);
 	if (ret)
 	{
 		sun3_reset586();
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index 536cf7e..25e81eb 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -919,7 +919,7 @@ static int bigmac_open(struct net_device *dev)
 	struct bigmac *bp = netdev_priv(dev);
 	int ret;
 
-	ret = request_irq(dev->irq, &bigmac_interrupt, IRQF_SHARED, dev->name, bp);
+	ret = request_irq(dev->irq, bigmac_interrupt, IRQF_SHARED, dev->name, bp);
 	if (ret) {
 		printk(KERN_ERR "BIGMAC: Can't order irq %d to go.\n", dev->irq);
 		return ret;
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index e13685a..5c396c2 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -819,7 +819,7 @@ static int netdev_open(struct net_device *dev)
 
 	/* Do we need to reset the chip??? */
 
-	i = request_irq(dev->irq, &intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i)
 		return i;
 
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 37d721b..1f842a7 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2184,7 +2184,7 @@ static int happy_meal_open(struct net_device *dev)
 	 * into a single source which we register handling at probe time.
 	 */
 	if ((hp->happy_flags & (HFLAG_QUATTRO|HFLAG_PCI)) != HFLAG_QUATTRO) {
-		if (request_irq(dev->irq, &happy_meal_interrupt,
+		if (request_irq(dev->irq, happy_meal_interrupt,
 				IRQF_SHARED, dev->name, (void *)dev)) {
 			HMD(("EAGAIN\n"));
 			printk(KERN_ERR "happy_meal(SBUS): Can't order irq %d to go.\n",
diff --git a/drivers/net/sunlance.c b/drivers/net/sunlance.c
index 9d6fd47..64e7d08 100644
--- a/drivers/net/sunlance.c
+++ b/drivers/net/sunlance.c
@@ -923,7 +923,7 @@ static int lance_open(struct net_device *dev)
 
 	STOP_LANCE(lp);
 
-	if (request_irq(dev->irq, &lance_interrupt, IRQF_SHARED,
+	if (request_irq(dev->irq, lance_interrupt, IRQF_SHARED,
 			lancestr, (void *) dev)) {
 		printk(KERN_ERR "Lance: Can't get irq %d\n", dev->irq);
 		return -EAGAIN;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index dcefb60..45c383f 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -807,7 +807,7 @@ static struct sunqec * __devinit get_qec(struct of_device *child)
 
 			qec_init_once(qecp, op);
 
-			if (request_irq(op->irqs[0], &qec_interrupt,
+			if (request_irq(op->irqs[0], qec_interrupt,
 					IRQF_SHARED, "qec", (void *) qecp)) {
 				printk(KERN_ERR "qec: Can't register irq.\n");
 				goto fail;
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index 6572e8a..75a669d 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -1248,7 +1248,7 @@ tc35815_open(struct net_device *dev)
 	 * This is used if the interrupt line can turned off (shared).
 	 * See 3c503.c for an example of selecting the IRQ at config-time.
 	 */
-	if (request_irq(dev->irq, &tc35815_interrupt, IRQF_SHARED,
+	if (request_irq(dev->irq, tc35815_interrupt, IRQF_SHARED,
 			dev->name, dev))
 		return -EAGAIN;
 
diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 492bff6..2fbac31 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -420,7 +420,7 @@ static int bdx_hw_start(struct bdx_priv *priv)
 		  GMAC_RX_FILTER_AM | GMAC_RX_FILTER_AB);
 
 #define BDX_IRQ_TYPE	((priv->nic->irq_type == IRQ_MSI)?0:IRQF_SHARED)
-	if ((rc = request_irq(priv->pdev->irq, &bdx_isr_napi, BDX_IRQ_TYPE,
+	if ((rc = request_irq(priv->pdev->irq, bdx_isr_napi, BDX_IRQ_TYPE,
 			 ndev->name, ndev)))
 		goto err_irq;
 	bdx_enable_interrupts(priv);
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 6a3c751..442e46a 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -679,7 +679,7 @@ static int __devinit ibmtr_probe1(struct net_device *dev, int PIOaddr)
 
 	/* The PCMCIA has already got the interrupt line and the io port, 
 	   so no chance of anybody else getting it - MLP */
-	if (request_irq(dev->irq = irq, &tok_interrupt, 0, "ibmtr", dev) != 0) {
+	if (request_irq(dev->irq = irq, tok_interrupt, 0, "ibmtr", dev) != 0) {
 		DPRINTK("Could not grab irq %d.  Halting Token Ring driver.\n",
 					irq);
 		iounmap(t_mmio);
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 26dca2b..7b1fe94 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -596,7 +596,7 @@ static int streamer_open(struct net_device *dev)
 	        rc=streamer_reset(dev);
 	}
 
-	if (request_irq(dev->irq, &streamer_interrupt, IRQF_SHARED, "lanstreamer", dev)) {
+	if (request_irq(dev->irq, streamer_interrupt, IRQF_SHARED, "lanstreamer", dev)) {
 		return -EAGAIN;
 	}
 #if STREAMER_DEBUG
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index a45ded0..ad63621 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -543,7 +543,7 @@ static int dmfe_open(struct DEVICE *dev)
 
 	DMFE_DBUG(0, "dmfe_open", 0);
 
-	ret = request_irq(dev->irq, &dmfe_interrupt,
+	ret = request_irq(dev->irq, dmfe_interrupt,
 			  IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
index 6b2330e..0df983b 100644
--- a/drivers/net/tulip/tulip_core.c
+++ b/drivers/net/tulip/tulip_core.c
@@ -506,7 +506,7 @@ tulip_open(struct net_device *dev)
 
 	tulip_init_ring (dev);
 
-	retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval)
 		goto free_ring;
 
@@ -1782,7 +1782,7 @@ static int tulip_resume(struct pci_dev *pdev)
 		return retval;
 	}
 
-	if ((retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
+	if ((retval = request_irq(dev->irq, tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
 		printk (KERN_ERR "tulip: request_irq failed in resume\n");
 		return retval;
 	}
diff --git a/drivers/net/tulip/uli526x.c b/drivers/net/tulip/uli526x.c
index c457a0c..fa019ca 100644
--- a/drivers/net/tulip/uli526x.c
+++ b/drivers/net/tulip/uli526x.c
@@ -461,7 +461,7 @@ static int uli526x_open(struct net_device *dev)
 	/* Initialize ULI526X board */
 	uli526x_init(dev);
 
-	ret = request_irq(dev->irq, &uli526x_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(dev->irq, uli526x_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/tulip/winbond-840.c b/drivers/net/tulip/winbond-840.c
index b38d3b7..1a52729 100644
--- a/drivers/net/tulip/winbond-840.c
+++ b/drivers/net/tulip/winbond-840.c
@@ -639,7 +639,7 @@ static int netdev_open(struct net_device *dev)
 	iowrite32(0x00000001, ioaddr + PCIBusCfg);		/* Reset */
 
 	netif_device_detach(dev);
-	i = request_irq(dev->irq, &intr_handler, IRQF_SHARED, dev->name, dev);
+	i = request_irq(dev->irq, intr_handler, IRQF_SHARED, dev->name, dev);
 	if (i)
 		goto out_err;
 
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 0f2ca59..9924c4c 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -458,7 +458,7 @@ static int xircom_open(struct net_device *dev)
 	int retval;
 	enter("xircom_open");
 	printk(KERN_INFO "xircom cardbus adaptor found, registering as %s, using irq %i \n",dev->name,dev->irq);
-	retval = request_irq(dev->irq, &xircom_interrupt, IRQF_SHARED, dev->name, dev);
+	retval = request_irq(dev->irq, xircom_interrupt, IRQF_SHARED, dev->name, dev);
 	if (retval) {
 		leave("xircom_open - No IRQ");
 		return retval;
diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 15002c3..74164d2 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -218,7 +218,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
 			"Hostess SV11", sv) < 0) {
 		printk(KERN_WARNING "hostess: IRQ %d already in use.\n", irq);
 		goto err_irq;
diff --git a/drivers/net/wan/lmc/lmc_main.c b/drivers/net/wan/lmc/lmc_main.c
index 7ea71b3..2ebe935 100644
--- a/drivers/net/wan/lmc/lmc_main.c
+++ b/drivers/net/wan/lmc/lmc_main.c
@@ -1028,7 +1028,7 @@ static int lmc_open(struct net_device *dev)
     lmc_softreset (sc);
 
     /* Since we have to use PCI bus, this should work on x86,alpha,ppc */
-    if (request_irq (dev->irq, &lmc_interrupt, IRQF_SHARED, dev->name, dev)){
+    if (request_irq (dev->irq, lmc_interrupt, IRQF_SHARED, dev->name, dev)){
         printk(KERN_WARNING "%s: could not get irq: %d\n", dev->name, dev->irq);
         lmc_trace(dev, "lmc_open irq failed out");
         return -EAGAIN;
diff --git a/drivers/net/wan/n2.c b/drivers/net/wan/n2.c
index 83da596..ebe44bc 100644
--- a/drivers/net/wan/n2.c
+++ b/drivers/net/wan/n2.c
@@ -375,7 +375,7 @@ static int __init n2_run(unsigned long io, unsigned long irq,
 	}
 	card->io = io;
 
-	if (request_irq(irq, &sca_intr, 0, devname, card)) {
+	if (request_irq(irq, sca_intr, 0, devname, card)) {
 		printk(KERN_ERR "n2: could not allocate IRQ\n");
 		n2_destroy_card(card);
 		return(-EBUSY);
diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 2b15a7e..31c41af 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1457,7 +1457,7 @@ got_type:
 	}
 
 	err = -EAGAIN;
-	if (request_irq(dev->irq, &sdla_isr, 0, dev->name, dev)) 
+	if (request_irq(dev->irq, sdla_isr, 0, dev->name, dev)) 
 		goto fail;
 
 	if (flp->type == SDLA_S507) {
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 0c525e2..3b3ee05 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -266,7 +266,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, &z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
 			"SeaLevel", dev) < 0) {
 		printk(KERN_WARNING "sealevel: IRQ %d already in use.\n", irq);
 		goto err_request_irq;
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 9e64dd4..0cb5ecc 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -2817,7 +2817,7 @@ static int mwl8k_start(struct ieee80211_hw *hw)
 	struct mwl8k_priv *priv = hw->priv;
 	int rc;
 
-	rc = request_irq(priv->pdev->irq, &mwl8k_interrupt,
+	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
 		printk(KERN_ERR "%s: failed to register IRQ handler\n",
@@ -3482,7 +3482,7 @@ static int __devinit mwl8k_probe(struct pci_dev *pdev,
 	iowrite32(0, priv->regs + MWL8K_HIU_A2H_INTERRUPT_CLEAR_SEL);
 	iowrite32(0xffffffff, priv->regs + MWL8K_HIU_A2H_INTERRUPT_STATUS_MASK);
 
-	rc = request_irq(priv->pdev->irq, &mwl8k_interrupt,
+	rc = request_irq(priv->pdev->irq, mwl8k_interrupt,
 			 IRQF_SHARED, MWL8K_NAME, hw);
 	if (rc) {
 		printk(KERN_ERR "%s: failed to register IRQ handler\n",
diff --git a/drivers/net/wireless/prism54/islpci_hotplug.c b/drivers/net/wireless/prism54/islpci_hotplug.c
index 83d3662..e4f2bb7 100644
--- a/drivers/net/wireless/prism54/islpci_hotplug.c
+++ b/drivers/net/wireless/prism54/islpci_hotplug.c
@@ -181,7 +181,7 @@ prism54_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	isl38xx_disable_interrupts(priv->device_base);
 
 	/* request for the interrupt before uploading the firmware */
-	rvalue = request_irq(pdev->irq, &islpci_interrupt,
+	rvalue = request_irq(pdev->irq, islpci_interrupt,
 			     IRQF_SHARED, ndev->name, priv);
 
 	if (rvalue) {
diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index 83a044d..8c777ba 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -660,7 +660,7 @@ static int xemaclite_open(struct net_device *dev)
 	xemaclite_set_mac_address(lp, dev->dev_addr);
 
 	/* Grab the IRQ */
-	retval = request_irq(dev->irq, &xemaclite_interrupt, 0, dev->name, dev);
+	retval = request_irq(dev->irq, xemaclite_interrupt, 0, dev->name, dev);
 	if (retval) {
 		dev_err(&lp->ndev->dev, "Could not allocate interrupt %d\n",
 			dev->irq);
diff --git a/drivers/net/xtsonic.c b/drivers/net/xtsonic.c
index 0c44135..389ba9d 100644
--- a/drivers/net/xtsonic.c
+++ b/drivers/net/xtsonic.c
@@ -92,7 +92,7 @@ static unsigned short known_revisions[] =
 
 static int xtsonic_open(struct net_device *dev)
 {
-	if (request_irq(dev->irq,&sonic_interrupt,IRQF_DISABLED,"sonic",dev)) {
+	if (request_irq(dev->irq,sonic_interrupt,IRQF_DISABLED,"sonic",dev)) {
 		printk(KERN_ERR "%s: unable to get IRQ %d.\n",
 		       dev->name, dev->irq);
 		return -EAGAIN;
diff --git a/drivers/net/yellowfin.c b/drivers/net/yellowfin.c
index 40ad0de..d831dfc 100644
--- a/drivers/net/yellowfin.c
+++ b/drivers/net/yellowfin.c
@@ -579,7 +579,7 @@ static int yellowfin_open(struct net_device *dev)
 	/* Reset the chip. */
 	iowrite32(0x80000000, ioaddr + DMACtrl);
 
-	ret = request_irq(dev->irq, &yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(dev->irq, yellowfin_interrupt, IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index 443c4ee..a97d894 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -169,7 +169,7 @@ static int znet_request_resources (struct net_device *dev)
 {
 	struct znet_private *znet = netdev_priv(dev);
 
-	if (request_irq (dev->irq, &znet_interrupt, 0, "ZNet", dev))
+	if (request_irq (dev->irq, znet_interrupt, 0, "ZNet", dev))
 		goto failed;
 	if (request_dma (znet->rx_dma, "ZNet rx"))
 		goto free_irq;


