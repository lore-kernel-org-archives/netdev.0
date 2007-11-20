From: Joe Perches <joe@perches.com>
Subject: [PATCH 36/59] drivers/net: Add missing "space"
Date: Mon, 19 Nov 2007 17:48:28 -0800
Message-ID: <1195523331-15303-37-git-send-email-joe@perches.com>
References: 1234567
 <1195523331-15303-1-git-send-email-joe@perches.com>
 <1195523331-15303-2-git-send-email-joe@perches.com>
 <1195523331-15303-3-git-send-email-joe@perches.com>
 <1195523331-15303-4-git-send-email-joe@perches.com>
 <1195523331-15303-5-git-send-email-joe@perches.com>
 <1195523331-15303-6-git-send-email-joe@perches.com>
 <1195523331-15303-7-git-send-email-joe@perches.com>
 <1195523331-15303-8-git-send-email-joe@perches.com>
 <1195523331-15303-9-git-send-email-joe@perches.com>
 <1195523331-15303-10-git-send-email-joe@perches.com>
 <1195523331-15303-11-git-send-email-joe@perches.com>
 <1195523331-15303-12-git-send-email-joe@perches.com>
 <1195523331-15303-13-git-send-email-joe@perches.com>
 <1195523331-15303-14-git-send-email-joe@perches.com>
 <1195523331-15303-15-git-send-email-joe@perches.com>
 <1195523331-15303-16-git-send-email-joe@perches.com>
 <1195523331-15303-17-git-send-email-joe@perches.com>
 <1195523331-15303-18-git-send-email-joe@perches.com>
 <1195523331-15303-19-git-send-email-joe@perches.com>
 <1195523331-15303-20-git-send-email-joe@perches.com>
 <1195523331-15303-21-git-send-email-joe@perches.com>
 <1195523331-15303-22-git-send-email-joe@perches.com>
 <1195523331-15303-23-git-send-email-joe@perches.com>
 <1195523331-15303-24-git-send-email-joe@perches.com>
 <1195523331-15303-25-git-send-email-joe@perches.com>
 <1195523331-15303-26-git-send-email-joe@perches.com>
 <1195523331-15303-27-git-send-email-joe@perches.com>
 <1195523331-15303-28-git-send-email-joe@perches.com>
 <1195523331-15303-29-git-send-email-joe@perches.com>
 <1195523331-15303-30-git-send-email-joe@perches.com>
 <1195523331-15303-31-git-send-email-joe@perches.com>
 <1195523331-15303-32-git-send-email-joe@perches.com>
 <1195523331-15303-33-git-send-email-joe@perches.com>
 <1195523331-15303-34-git-send-email-joe@perches.com>
 <1195523331-15303-35-git-send-email-joe@perches.com>
 <1195523331-15303-36-git-send-email-joe@perches.com>
Cc: Daniele Venzano <venza@brownhat.org>,
	James Chapman <jchapman@katalix.com>,
	Jeff Garzik <jgarzik@pobox.com>,
	Ramkrishna Vepa <ram.vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Roger Luethi <rl@hellgate.ch>,
	Ron Mercer <linux-driver@qlogic.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2184 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757929AbXKTBuO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:50:14 -0500
In-Reply-To: <1195523331-15303-36-git-send-email-joe@perches.com>
Message-Id: <fef2c4f213c930a3c1c1e58c8961249886621caa.1195454435.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/3c507.c     |    4 ++--
 drivers/net/amd8111e.c  |    4 ++--
 drivers/net/at1700.c    |    2 +-
 drivers/net/pppol2tp.c  |    2 +-
 drivers/net/qla3xxx.c   |    2 +-
 drivers/net/rrunner.c   |    2 +-
 drivers/net/s2io.c      |    6 +++---
 drivers/net/sis900.c    |    6 +++---
 drivers/net/smc9194.c   |    2 +-
 drivers/net/via-rhine.c |    2 +-
 10 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/drivers/net/3c507.c b/drivers/net/3c507.c
index 964d31a..f90ede9 100644
--- a/drivers/net/3c507.c
+++ b/drivers/net/3c507.c
@@ -747,7 +747,7 @@ static void init_82586_mem(struct net_device *dev)
 		int boguscnt = 50;
 		while (readw(shmem+iSCB_STATUS) == 0)
 			if (--boguscnt == 0) {
-				printk("%s: i82586 initialization timed out with status %04x,"
+				printk("%s: i82586 initialization timed out with status %04x, "
 					   "cmd %04x.\n", dev->name,
 					   readw(shmem+iSCB_STATUS), readw(shmem+iSCB_CMD));
 				break;
@@ -832,7 +832,7 @@ static void el16_rx(struct net_device *dev)
 
 		if (rfd_cmd != 0 || data_buffer_addr != rx_head + 22
 			|| (pkt_len & 0xC000) != 0xC000) {
-			printk("%s: Rx frame at %#x corrupted, status %04x cmd %04x"
+			printk("%s: Rx frame at %#x corrupted, status %04x cmd %04x "
 				   "next %04x data-buf @%04x %04x.\n", dev->name, rx_head,
 				   frame_status, rfd_cmd, next_rx_frame, data_buffer_addr,
 				   pkt_len);
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index eebf5bb..3430cc3 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1939,13 +1939,13 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if(err){
-		printk(KERN_ERR "amd8111e: Cannot enable new PCI device,"
+		printk(KERN_ERR "amd8111e: Cannot enable new PCI device, "
 			"exiting.\n");
 		return err;
 	}
 
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)){
-		printk(KERN_ERR "amd8111e: Cannot find PCI base address"
+		printk(KERN_ERR "amd8111e: Cannot find PCI base address, "
 		       "exiting.\n");
 		err = -ENODEV;
 		goto err_disable_pdev;
diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index b032c1b..9704171 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -465,7 +465,7 @@ found:
 	/* Snarf the interrupt vector now. */
 	ret = request_irq(irq, &net_interrupt, 0, DRV_NAME, dev);
 	if (ret) {
-		printk ("  AT1700 at %#3x is unusable due to a conflict on"
+		printk ("  AT1700 at %#3x is unusable due to a conflict on "
 				"IRQ %d.\n", ioaddr, irq);
 		goto err_mca;
 	}
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index a7556cd..1b51bb6 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2489,7 +2489,7 @@ static void __exit pppol2tp_exit(void)
 module_init(pppol2tp_init);
 module_exit(pppol2tp_exit);
 
-MODULE_AUTHOR("Martijn van Oosterhout <kleptog@svana.org>,"
+MODULE_AUTHOR("Martijn van Oosterhout <kleptog@svana.org>, "
 	      "James Chapman <jchapman@katalix.com>");
 MODULE_DESCRIPTION("PPP over L2TP over UDP");
 MODULE_LICENSE("GPL");
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index a579111..4f5d3d4 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -711,7 +711,7 @@ static int ql_mii_write_reg_ex(struct ql3_adapter *qdev,
 	if (ql_wait_for_mii_ready(qdev)) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
-			       "%s: Timed out waiting for management port to"
+			       "%s: Timed out waiting for management port to "
 			       "get free before issuing command.\n",
 			       qdev->ndev->name);
 		return -1;
diff --git a/drivers/net/rrunner.c b/drivers/net/rrunner.c
index 73a7e65..379ded5 100644
--- a/drivers/net/rrunner.c
+++ b/drivers/net/rrunner.c
@@ -878,7 +878,7 @@ static u32 rr_handle_event(struct net_device *dev, u32 prodidx, u32 eidx)
 			       dev->name);
 			goto drop;
 		case E_FLG_SYN_ERR:
-			printk(KERN_WARNING "%s: Flag sync. lost during"
+			printk(KERN_WARNING "%s: Flag sync. lost during "
 			       "packet\n", dev->name);
 			goto drop;
 		case E_RX_INV_BUF:
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 6326667..8aff21c 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -3762,7 +3762,7 @@ static int __devinit s2io_test_msi(struct s2io_nic *sp)
 
 	if (!sp->msi_detected) {
 		/* MSI(X) test failed, go back to INTx mode */
-		DBG_PRINT(ERR_DBG, "%s: PCI %s: No interrupt was generated"
+		DBG_PRINT(ERR_DBG, "%s: PCI %s: No interrupt was generated "
 			"using MSI(X) during test\n", sp->dev->name,
 			pci_name(pdev));
 
@@ -6705,7 +6705,7 @@ static int s2io_add_isr(struct s2io_nic * sp)
 				/* If either data or addr is zero print it */
 				if(!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx"
+					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
 						"Data:0x%lx\n",sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
@@ -6723,7 +6723,7 @@ static int s2io_add_isr(struct s2io_nic * sp)
 				/* If either data or addr is zero print it */
 				if(!(sp->msix_info[i].addr &&
 					sp->msix_info[i].data)) {
-					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx"
+					DBG_PRINT(ERR_DBG, "%s @ Addr:0x%llx "
 						"Data:0x%lx\n",sp->desc[i],
 						(unsigned long long)
 						sp->msix_info[i].addr,
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 0857d2c..ec95e49 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -419,7 +419,7 @@ static int __devinit sis900_probe(struct pci_dev *pci_dev,
 
 	i = pci_set_dma_mask(pci_dev, DMA_32BIT_MASK);
 	if(i){
-		printk(KERN_ERR "sis900.c: architecture does not support"
+		printk(KERN_ERR "sis900.c: architecture does not support "
 			"32bit PCI busmaster DMA\n");
 		return i;
 	}
@@ -1667,7 +1667,7 @@ static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 		/* something strange happened !!! */
 		if (status & HIBERR) {
 			if(netif_msg_intr(sis_priv))
-				printk(KERN_INFO "%s: Abnormal interrupt,"
+				printk(KERN_INFO "%s: Abnormal interrupt, "
 					"status %#8.8x.\n", net_dev->name, status);
 			break;
 		}
@@ -1820,7 +1820,7 @@ refill_rx_ring:
 				 * how the hardware will react to this kind
 				 * of degenerated buffer */
 				if (netif_msg_rx_err(sis_priv))
-					printk(KERN_INFO "%s: Memory squeeze,"
+					printk(KERN_INFO "%s: Memory squeeze, "
 						"deferring packet.\n",
 						net_dev->name);
 				net_dev->stats.rx_dropped++;
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index cb2698d..de67744 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -906,7 +906,7 @@ static int __init smc_probe(struct net_device *dev, int ioaddr)
 	SMC_SELECT_BANK(1);
 	base_address_register = inw( ioaddr + BASE );
 	if ( ioaddr != ( base_address_register >> 3 & 0x3E0 ) )  {
-		printk(CARDNAME ": IOADDR %x doesn't match configuration (%x)."
+		printk(CARDNAME ": IOADDR %x doesn't match configuration (%x). "
 			"Probably not a SMC chip\n",
 			ioaddr, base_address_register >> 3 & 0x3E0 );
 		/* well, the base address register didn't match.  Must not have
diff --git a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
index 07263cd..87c180b 100644
--- a/drivers/net/via-rhine.c
+++ b/drivers/net/via-rhine.c
@@ -1338,7 +1338,7 @@ static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
 				if (debug > 2 &&
 				    ioread8(ioaddr+ChipCmd) & CmdTxOn)
 					printk(KERN_WARNING "%s: "
-					       "rhine_interrupt() Tx engine"
+					       "rhine_interrupt() Tx engine "
 					       "still on.\n", dev->name);
 			}
 			rhine_tx(dev);
-- 
1.5.3.5.652.gf192c

