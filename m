From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Subject: [PATCH] netdev/ethernet: dev_alloc_skb to netdev_alloc_skb
Date: Sun, 22 Jan 2012 02:27:43 +0530
Message-ID: <1327179463-13980-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Cc: "David S. Miller" <davem@davemloft.net>,
	Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org,
	"Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet

Signed-off-by: Pradeep A. Dalvi <netdev@pradeepdalvi.com>
---
 drivers/net/ethernet/3com/3c501.c                  |    2 +-
 drivers/net/ethernet/3com/3c509.c                  |    2 +-
 drivers/net/ethernet/3com/3c515.c                  |    8 +++---
 drivers/net/ethernet/3com/3c574_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c589_cs.c               |    2 +-
 drivers/net/ethernet/3com/3c59x.c                  |    5 ++-
 drivers/net/ethernet/3com/typhoon.c                |    4 +-
 drivers/net/ethernet/8390/axnet_cs.c               |    2 +-
 drivers/net/ethernet/8390/lib8390.c                |    2 +-
 drivers/net/ethernet/adaptec/starfire.c            |    6 ++--
 drivers/net/ethernet/adi/bfin_mac.c                |    8 +++---
 drivers/net/ethernet/amd/7990.c                    |    2 +-
 drivers/net/ethernet/amd/a2065.c                   |    2 +-
 drivers/net/ethernet/amd/am79c961a.c               |    2 +-
 drivers/net/ethernet/amd/amd8111e.c                |    6 +++-
 drivers/net/ethernet/amd/ariadne.c                 |    2 +-
 drivers/net/ethernet/amd/atarilance.c              |    2 +-
 drivers/net/ethernet/amd/au1000_eth.c              |    2 +-
 drivers/net/ethernet/amd/declance.c                |    2 +-
 drivers/net/ethernet/amd/depca.c                   |    2 +-
 drivers/net/ethernet/amd/lance.c                   |    2 +-
 drivers/net/ethernet/amd/ni65.c                    |    2 +-
 drivers/net/ethernet/amd/nmclan_cs.c               |    2 +-
 drivers/net/ethernet/amd/pcnet32.c                 |   14 +++++-----
 drivers/net/ethernet/amd/sun3lance.c               |    2 +-
 drivers/net/ethernet/amd/sunlance.c                |    4 +-
 drivers/net/ethernet/apple/bmac.c                  |   13 ++++++----
 drivers/net/ethernet/apple/mace.c                  |    4 +-
 drivers/net/ethernet/apple/macmace.c               |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c    |    2 +-
 drivers/net/ethernet/cadence/at91_ether.c          |    2 +-
 drivers/net/ethernet/cadence/macb.c                |    2 +-
 drivers/net/ethernet/cirrus/cs89x0.c               |    4 +-
 drivers/net/ethernet/cirrus/ep93xx_eth.c           |    2 +-
 drivers/net/ethernet/davicom/dm9000.c              |    2 +-
 drivers/net/ethernet/dec/ewrk3.c                   |    4 ++-
 drivers/net/ethernet/dec/tulip/de2104x.c           |    4 +-
 drivers/net/ethernet/dec/tulip/de4x5.c             |    4 +-
 drivers/net/ethernet/dec/tulip/dmfe.c              |   25 ++++++++++++--------
 drivers/net/ethernet/dec/tulip/interrupt.c         |    7 +++--
 drivers/net/ethernet/dec/tulip/tulip_core.c        |    4 +-
 drivers/net/ethernet/dec/tulip/uli526x.c           |   22 ++++++++++-------
 drivers/net/ethernet/dec/tulip/winbond-840.c       |    6 ++--
 drivers/net/ethernet/dec/tulip/xircom_cb.c         |    2 +-
 drivers/net/ethernet/dlink/de600.c                 |    2 +-
 drivers/net/ethernet/dlink/de620.c                 |    2 +-
 drivers/net/ethernet/dlink/sundance.c              |    7 +++--
 drivers/net/ethernet/dnet.c                        |    2 +-
 drivers/net/ethernet/fealnx.c                      |    6 ++--
 drivers/net/ethernet/freescale/fec.c               |    4 +-
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    4 +-
 .../net/ethernet/freescale/fs_enet/fs_enet-main.c  |   12 ++++----
 drivers/net/ethernet/freescale/ucc_geth.c          |    5 ++-
 drivers/net/ethernet/fujitsu/at1700.c              |    2 +-
 drivers/net/ethernet/fujitsu/eth16i.c              |    2 +-
 drivers/net/ethernet/fujitsu/fmvj18x_cs.c          |    2 +-
 drivers/net/ethernet/hp/hp100.c                    |    4 +-
 drivers/net/ethernet/i825xx/3c505.c                |    2 +-
 drivers/net/ethernet/i825xx/3c507.c                |    2 +-
 drivers/net/ethernet/i825xx/3c523.c                |    2 +-
 drivers/net/ethernet/i825xx/3c527.c                |    4 +-
 drivers/net/ethernet/i825xx/82596.c                |    6 ++--
 drivers/net/ethernet/i825xx/eepro.c                |    2 +-
 drivers/net/ethernet/i825xx/eexpress.c             |    2 +-
 drivers/net/ethernet/i825xx/ether1.c               |    2 +-
 drivers/net/ethernet/i825xx/lp486e.c               |    2 +-
 drivers/net/ethernet/i825xx/ni52.c                 |    2 +-
 drivers/net/ethernet/i825xx/sun3_82586.c           |    2 +-
 drivers/net/ethernet/i825xx/znet.c                 |    2 +-
 drivers/net/ethernet/lantiq_etop.c                 |    2 +-
 drivers/net/ethernet/marvell/mv643xx_eth.c         |    2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    2 +-
 drivers/net/ethernet/micrel/ks8695net.c            |    3 +-
 drivers/net/ethernet/micrel/ks8851_mll.c           |    2 +-
 drivers/net/ethernet/micrel/ksz884x.c              |    6 ++--
 drivers/net/ethernet/microchip/enc28j60.c          |    2 +-
 drivers/net/ethernet/mipsnet.c                     |    2 +-
 drivers/net/ethernet/natsemi/ibmlana.c             |    2 +-
 drivers/net/ethernet/natsemi/natsemi.c             |    4 +-
 drivers/net/ethernet/natsemi/sonic.c               |    4 +-
 drivers/net/ethernet/neterion/s2io.c               |    6 ++--
 drivers/net/ethernet/netx-eth.c                    |    2 +-
 drivers/net/ethernet/nuvoton/w90p910_ether.c       |    2 +-
 drivers/net/ethernet/nvidia/forcedeth.c            |   10 ++++---
 drivers/net/ethernet/packetengines/hamachi.c       |    8 ++++--
 drivers/net/ethernet/packetengines/yellowfin.c     |    7 +++--
 drivers/net/ethernet/pasemi/pasemi_mac.c           |    2 +-
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    2 +-
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c   |    2 +-
 drivers/net/ethernet/racal/ni5010.c                |    2 +-
 drivers/net/ethernet/realtek/atp.c                 |    2 +-
 drivers/net/ethernet/renesas/sh_eth.c              |    4 +-
 drivers/net/ethernet/s6gmac.c                      |    9 ++++---
 drivers/net/ethernet/seeq/ether3.c                 |    2 +-
 drivers/net/ethernet/seeq/seeq8005.c               |    2 +-
 drivers/net/ethernet/sis/sis900.c                  |   10 ++++---
 drivers/net/ethernet/smsc/epic100.c                |    7 +++--
 drivers/net/ethernet/smsc/smc911x.c                |    2 +-
 drivers/net/ethernet/smsc/smc9194.c                |    2 +-
 drivers/net/ethernet/smsc/smc91c92_cs.c            |    2 +-
 drivers/net/ethernet/smsc/smc91x.c                 |    2 +-
 drivers/net/ethernet/sun/cassini.c                 |    2 +-
 drivers/net/ethernet/sun/sunbmac.c                 |    3 +-
 drivers/net/ethernet/sun/sunhme.c                  |    3 +-
 drivers/net/ethernet/sun/sunqe.c                   |    2 +-
 drivers/net/ethernet/tehuti/tehuti.c               |    6 ++--
 drivers/net/ethernet/ti/davinci_emac.c             |    2 +-
 drivers/net/ethernet/tile/tilepro.c                |    4 +-
 drivers/net/ethernet/toshiba/tc35815.c             |    2 +-
 drivers/net/ethernet/via/via-velocity.c            |    2 +-
 drivers/net/ethernet/xilinx/xilinx_emaclite.c      |    2 +-
 drivers/net/ethernet/xircom/xirc2ps_cs.c           |    3 +-
 114 files changed, 236 insertions(+), 203 deletions(-)

diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
index 68da81d..bf73e1a 100644
--- a/drivers/net/ethernet/3com/3c501.c
+++ b/drivers/net/ethernet/3com/3c501.c
@@ -702,7 +702,7 @@ static void el_receive(struct net_device *dev)
 	 */
 
 	outb(AX_SYS, AX_CMD);
-	skb = dev_alloc_skb(pkt_len+2);
+	skb = netdev_alloc_skb(dev, pkt_len + 2);
 
 	/*
 	 *	Start of frame
diff --git a/drivers/net/ethernet/3com/3c509.c b/drivers/net/ethernet/3com/3c509.c
index 92053e6..41719da 100644
--- a/drivers/net/ethernet/3com/3c509.c
+++ b/drivers/net/ethernet/3com/3c509.c
@@ -1066,7 +1066,7 @@ el3_rx(struct net_device *dev)
 			short pkt_len = rx_status & 0x7ff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 			if (el3_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c515.c b/drivers/net/ethernet/3com/3c515.c
index f67a5d3..68fd765 100644
--- a/drivers/net/ethernet/3com/3c515.c
+++ b/drivers/net/ethernet/3com/3c515.c
@@ -826,7 +826,7 @@ static int corkscrew_open(struct net_device *dev)
 				vp->rx_ring[i].next = 0;
 			vp->rx_ring[i].status = 0;	/* Clear complete bit. */
 			vp->rx_ring[i].length = PKT_BUF_SZ | 0x80000000;
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			vp->rx_skbuff[i] = skb;
 			if (skb == NULL)
 				break;	/* Bad news!  */
@@ -1295,7 +1295,7 @@ static int corkscrew_rx(struct net_device *dev)
 			short pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 5 + 2);
+			skb = netdev_alloc_skb(dev, pkt_len + 5 + 2);
 			if (corkscrew_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 				     pkt_len, rx_status);
@@ -1368,7 +1368,7 @@ static int boomerang_rx(struct net_device *dev)
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 4)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 4)) != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				/* 'skb_put()' points to the start of sk_buff data area. */
 				memcpy(skb_put(skb, pkt_len),
@@ -1403,7 +1403,7 @@ static int boomerang_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = vp->dirty_rx % RX_RING_SIZE;
 		if (vp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 			if (skb == NULL)
 				break;	/* Bad news!  */
 			skb->dev = dev;	/* Mark as being used by this device. */
diff --git a/drivers/net/ethernet/3com/3c574_cs.c b/drivers/net/ethernet/3com/3c574_cs.c
index 9c01bc9..e61b2f8 100644
--- a/drivers/net/ethernet/3com/3c574_cs.c
+++ b/drivers/net/ethernet/3com/3c574_cs.c
@@ -1012,7 +1012,7 @@ static int el3_rx(struct net_device *dev, int worklimit)
 			short pkt_len = rx_status & 0x7ff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 
 			pr_debug("  Receiving packet size %d status %4.4x.\n",
 				  pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c589_cs.c b/drivers/net/ethernet/3com/3c589_cs.c
index da410f0..b23253b 100644
--- a/drivers/net/ethernet/3com/3c589_cs.c
+++ b/drivers/net/ethernet/3com/3c589_cs.c
@@ -819,7 +819,7 @@ static int el3_rx(struct net_device *dev)
 	    short pkt_len = rx_status & 0x7ff;
 	    struct sk_buff *skb;
 
-	    skb = dev_alloc_skb(pkt_len+5);
+	    skb = netdev_alloc_skb(dev, pkt_len + 5);
 
 	    netdev_dbg(dev, "    Receiving packet size %d status %4.4x.\n",
 		       pkt_len, rx_status);
diff --git a/drivers/net/ethernet/3com/3c59x.c b/drivers/net/ethernet/3com/3c59x.c
index 8153a3e..c461561 100644
--- a/drivers/net/ethernet/3com/3c59x.c
+++ b/drivers/net/ethernet/3com/3c59x.c
@@ -2500,7 +2500,7 @@ static int vortex_rx(struct net_device *dev)
 			int pkt_len = rx_status & 0x1fff;
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 5);
+			skb = netdev_alloc_skb(dev, pkt_len + 5);
 			if (vortex_debug > 4)
 				pr_debug("Receiving packet size %d status %4.4x.\n",
 					   pkt_len, rx_status);
@@ -2579,7 +2579,8 @@ boomerang_rx(struct net_device *dev)
 
 			/* Check if the packet is long enough to just accept without
 			   copying to a properly sized skbuff. */
-			if (pkt_len < rx_copybreak && (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			if (pkt_len < rx_copybreak &&
+					(skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
 				pci_dma_sync_single_for_cpu(VORTEX_PCI(vp), dma, PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
 				/* 'skb_put()' points to the start of sk_buff data area. */
diff --git a/drivers/net/ethernet/3com/typhoon.c b/drivers/net/ethernet/3com/typhoon.c
index 6d6bc75..485b2e0 100644
--- a/drivers/net/ethernet/3com/typhoon.c
+++ b/drivers/net/ethernet/3com/typhoon.c
@@ -1607,7 +1607,7 @@ typhoon_alloc_rx_skb(struct typhoon *tp, u32 idx)
 				le32_to_cpu(indexes->rxBuffCleared))
 		return -ENOMEM;
 
-	skb = dev_alloc_skb(PKT_BUF_SZ);
+	skb = netdev_alloc_skb(tp->dev, PKT_BUF_SZ);
 	if(!skb)
 		return -ENOMEM;
 
@@ -1673,7 +1673,7 @@ typhoon_rx(struct typhoon *tp, struct basic_ring *rxRing, volatile __le32 * read
 		pkt_len = le16_to_cpu(rx->frameLen);
 
 		if(pkt_len < rx_copybreak &&
-		   (new_skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+		   (new_skb = netdev_alloc_skb(tp->dev, pkt_len + 2)) != NULL) {
 			skb_reserve(new_skb, 2);
 			pci_dma_sync_single_for_cpu(tp->pdev, dma_addr,
 						    PKT_BUF_SZ,
diff --git a/drivers/net/ethernet/8390/axnet_cs.c b/drivers/net/ethernet/8390/axnet_cs.c
index bba51cd..0965d58 100644
--- a/drivers/net/ethernet/8390/axnet_cs.c
+++ b/drivers/net/ethernet/8390/axnet_cs.c
@@ -1408,7 +1408,7 @@ static void ei_receive(struct net_device *dev)
 		{
 			struct sk_buff *skb;
 			
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) 
 			{
 				if (ei_debug > 1)
diff --git a/drivers/net/ethernet/8390/lib8390.c b/drivers/net/ethernet/8390/lib8390.c
index 05ae214..e77f624 100644
--- a/drivers/net/ethernet/8390/lib8390.c
+++ b/drivers/net/ethernet/8390/lib8390.c
@@ -717,7 +717,7 @@ static void ei_receive(struct net_device *dev)
 		} else if ((pkt_stat & 0x0F) == ENRSR_RXOK) {
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				if (ei_debug > 1)
 					netdev_dbg(dev, "Couldn't allocate a sk_buff of size %d\n",
diff --git a/drivers/net/ethernet/adaptec/starfire.c b/drivers/net/ethernet/adaptec/starfire.c
index cb4f38a..774fa14 100644
--- a/drivers/net/ethernet/adaptec/starfire.c
+++ b/drivers/net/ethernet/adaptec/starfire.c
@@ -1180,7 +1180,7 @@ static void init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		np->rx_info[i].skb = skb;
 		if (skb == NULL)
 			break;
@@ -1473,7 +1473,7 @@ static int __netdev_rx(struct net_device *dev, int *quota)
 		/* Check if the packet is long enough to accept without copying
 		   to a minimally-sized skbuff. */
 		if (pkt_len < rx_copybreak &&
-		    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+		    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 			skb_reserve(skb, 2);	/* 16 byte align the IP header */
 			pci_dma_sync_single_for_cpu(np->pci_dev,
 						    np->rx_info[entry].mapping,
@@ -1597,7 +1597,7 @@ static void refill_rx_ring(struct net_device *dev)
 	for (; np->cur_rx - np->dirty_rx > 0; np->dirty_rx++) {
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_info[entry].skb == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			np->rx_info[entry].skb = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
index d812a10..709add8 100644
--- a/drivers/net/ethernet/adi/bfin_mac.c
+++ b/drivers/net/ethernet/adi/bfin_mac.c
@@ -113,7 +113,7 @@ static void desc_list_free(void)
 	}
 }
 
-static int desc_list_init(void)
+static int desc_list_init(struct net_device *dev)
 {
 	int i;
 	struct sk_buff *new_skb;
@@ -187,7 +187,7 @@ static int desc_list_init(void)
 		struct dma_descriptor *b = &(r->desc_b);
 
 		/* allocate a new skb for next time receive */
-		new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+		new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 		if (!new_skb) {
 			pr_notice("init: low on mem - packet dropped\n");
 			goto init_error;
@@ -1090,7 +1090,7 @@ static void bfin_mac_rx(struct net_device *dev)
 	/* allocate a new skb for next time receive */
 	skb = current_rx_ptr->skb;
 
-	new_skb = dev_alloc_skb(PKT_BUF_SZ + NET_IP_ALIGN);
+	new_skb = netdev_alloc_skb(dev, PKT_BUF_SZ + NET_IP_ALIGN);
 	if (!new_skb) {
 		netdev_notice(dev, "rx: low on mem - packet dropped\n");
 		dev->stats.rx_dropped++;
@@ -1397,7 +1397,7 @@ static int bfin_mac_open(struct net_device *dev)
 	}
 
 	/* initial rx and tx list */
-	ret = desc_list_init();
+	ret = desc_list_init(dev);
 	if (ret)
 		return ret;
 
diff --git a/drivers/net/ethernet/amd/7990.c b/drivers/net/ethernet/amd/7990.c
index 60b35fb..1b046f5 100644
--- a/drivers/net/ethernet/amd/7990.c
+++ b/drivers/net/ethernet/amd/7990.c
@@ -316,7 +316,7 @@ static int lance_rx (struct net_device *dev)
                         if (bits & LE_R1_EOP) dev->stats.rx_errors++;
                 } else {
 			int len = (rd->mblength & 0xfff) - 4;
-			struct sk_buff *skb = dev_alloc_skb (len+2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
                         if (!skb) {
                                 printk ("%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/amd/a2065.c b/drivers/net/ethernet/amd/a2065.c
index 825e5d4..689dfca 100644
--- a/drivers/net/ethernet/amd/a2065.c
+++ b/drivers/net/ethernet/amd/a2065.c
@@ -290,7 +290,7 @@ static int lance_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 		} else {
 			int len = (rd->mblength & 0xfff) - 4;
-			struct sk_buff *skb = dev_alloc_skb(len + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 
 			if (!skb) {
 				netdev_warn(dev, "Memory squeeze, deferring packet\n");
diff --git a/drivers/net/ethernet/amd/am79c961a.c b/drivers/net/ethernet/amd/am79c961a.c
index 7d5ded8..bb77ce9 100644
--- a/drivers/net/ethernet/amd/am79c961a.c
+++ b/drivers/net/ethernet/amd/am79c961a.c
@@ -516,7 +516,7 @@ am79c961_rx(struct net_device *dev, struct dev_priv *priv)
 		}
 
 		len = am_readword(dev, hdraddr + 6);
-		skb = dev_alloc_skb(len + 2);
+		skb = netdev_alloc_skb(dev, len + 2);
 
 		if (skb) {
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 33e0a8c..1974bc2 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -336,7 +336,8 @@ static int amd8111e_init_ring(struct net_device *dev)
 	/* Allocating receive  skbs */
 	for (i = 0; i < NUM_RX_BUFFERS; i++) {
 
-		if (!(lp->rx_skbuff[i] = dev_alloc_skb(lp->rx_buff_len))) {
+		lp->rx_skbuff[i] = netdev_alloc_skb(dev, lp->rx_buff_len);
+		if (!lp->rx_skbuff[i]) {
 				/* Release previos allocated skbs */
 				for(--i; i >= 0 ;i--)
 					dev_kfree_skb(lp->rx_skbuff[i]);
@@ -768,7 +769,8 @@ static int amd8111e_rx_poll(struct napi_struct *napi, int budget)
 			}
 			if(--rx_pkt_limit < 0)
 				goto rx_not_empty;
-			if(!(new_skb = dev_alloc_skb(lp->rx_buff_len))){
+			new_skb = netdev_alloc_skb(dev, lp->rx_buff_len);
+			if (new_skb == NULL) {
 				/* if allocation fail,
 				   ignore that pkt and go to next one */
 				lp->rx_ring[rx_index].rx_flags &= RESET_RX_FLAGS;
diff --git a/drivers/net/ethernet/amd/ariadne.c b/drivers/net/ethernet/amd/ariadne.c
index eb18e1f..f4c228e 100644
--- a/drivers/net/ethernet/amd/ariadne.c
+++ b/drivers/net/ethernet/amd/ariadne.c
@@ -191,7 +191,7 @@ static int ariadne_rx(struct net_device *dev)
 			short pkt_len = swapw(priv->rx_ring[entry]->RMD3);
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				netdev_warn(dev, "Memory squeeze, deferring packet\n");
 				for (i = 0; i < RX_RING_SIZE; i++)
diff --git a/drivers/net/ethernet/amd/atarilance.c b/drivers/net/ethernet/amd/atarilance.c
index 15bfa28..70ed79c 100644
--- a/drivers/net/ethernet/amd/atarilance.c
+++ b/drivers/net/ethernet/amd/atarilance.c
@@ -997,7 +997,7 @@ static int lance_rx( struct net_device *dev )
 				dev->stats.rx_errors++;
 			}
 			else {
-				skb = dev_alloc_skb( pkt_len+2 );
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
 					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
 								  dev->name ));
diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8b95dd3..722e716 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -725,7 +725,7 @@ static int au1000_rx(struct net_device *dev)
 			/* good frame */
 			frmlen = (status & RX_FRAME_LEN_MASK);
 			frmlen -= 4; /* Remove FCS */
-			skb = dev_alloc_skb(frmlen + 2);
+			skb = netdev_alloc_skb(dev, frmlen + 2);
 			if (skb == NULL) {
 				netdev_err(dev, "Memory squeeze, dropping packet.\n");
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/amd/declance.c b/drivers/net/ethernet/amd/declance.c
index 73f8d4f..39fe95e 100644
--- a/drivers/net/ethernet/amd/declance.c
+++ b/drivers/net/ethernet/amd/declance.c
@@ -605,7 +605,7 @@ static int lance_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 		} else {
 			len = (*rds_ptr(rd, mblength, lp->type) & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == 0) {
 				printk("%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/amd/depca.c b/drivers/net/ethernet/amd/depca.c
index 681970c..86dd957 100644
--- a/drivers/net/ethernet/amd/depca.c
+++ b/drivers/net/ethernet/amd/depca.c
@@ -1042,7 +1042,7 @@ static int depca_rx(struct net_device *dev)
 				short len, pkt_len = readw(&lp->rx_ring[entry].msg_length) - 4;
 				struct sk_buff *skb;
 
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb != NULL) {
 					unsigned char *buf;
 					skb_reserve(skb, 2);	/* 16 byte align the IP header */
diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/amd/lance.c
index a6e2e84..8958e7a 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -1183,7 +1183,7 @@ lance_rx(struct net_device *dev)
 			}
 			else
 			{
-				skb = dev_alloc_skb(pkt_len+2);
+				skb = netdev_alloc_skb(pkt_len + 2);
 				if (skb == NULL)
 				{
 					printk("%s: Memory squeeze, deferring packet.\n", dev->name);
diff --git a/drivers/net/ethernet/amd/ni65.c b/drivers/net/ethernet/amd/ni65.c
index 6e6aa72..fb78e25 100644
--- a/drivers/net/ethernet/amd/ni65.c
+++ b/drivers/net/ethernet/amd/ni65.c
@@ -1091,7 +1091,7 @@ static void ni65_recv_intr(struct net_device *dev,int csr0)
 			if (skb)
 				skb_reserve(skb,16);
 #else
-			struct sk_buff *skb = dev_alloc_skb(len+2);
+			struct sk_buff *skb = netdev_alloc_skb(dev, len + 2);
 #endif
 			if(skb)
 			{
diff --git a/drivers/net/ethernet/amd/nmclan_cs.c b/drivers/net/ethernet/amd/nmclan_cs.c
index 6be0dd6..d1633e9 100644
--- a/drivers/net/ethernet/amd/nmclan_cs.c
+++ b/drivers/net/ethernet/amd/nmclan_cs.c
@@ -1104,7 +1104,7 @@ static int mace_rx(struct net_device *dev, unsigned char RxCnt)
       pr_debug("    receiving packet size 0x%X rx_status"
 	    " 0x%X.\n", pkt_len, rx_status);
 
-      skb = dev_alloc_skb(pkt_len+2);
+	skb = netdev_alloc_skb(dev, pkt_len + 2);
 
       if (skb != NULL) {
 	skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/amd/pcnet32.c b/drivers/net/ethernet/amd/pcnet32.c
index 20e6dab..becc97a 100644
--- a/drivers/net/ethernet/amd/pcnet32.c
+++ b/drivers/net/ethernet/amd/pcnet32.c
@@ -588,11 +588,11 @@ static void pcnet32_realloc_rx_ring(struct net_device *dev,
 	/* now allocate any new buffers needed */
 	for (; new < size; new++) {
 		struct sk_buff *rx_skbuff;
-		new_skb_list[new] = dev_alloc_skb(PKT_BUF_SKB);
+		new_skb_list[new] = netdev_alloc_skb(dev, PKT_BUF_SKB);
 		rx_skbuff = new_skb_list[new];
 		if (!rx_skbuff) {
 			/* keep the original lists and buffers */
-			netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+			netif_err(lp, drv, dev, "%s netdev_alloc_skb failed\n",
 				  __func__);
 			goto free_all_new;
 		}
@@ -909,7 +909,7 @@ static int pcnet32_loopback_test(struct net_device *dev, uint64_t * data1)
 	/* Initialize Transmit buffers. */
 	size = data_len + 15;
 	for (x = 0; x < numbuffs; x++) {
-		skb = dev_alloc_skb(size);
+		skb = netdev_alloc_skb(dev, size);
 		if (!skb) {
 			netif_printk(lp, hw, KERN_DEBUG, dev,
 				     "Cannot allocate skb at line: %d!\n",
@@ -1152,7 +1152,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 	if (pkt_len > rx_copybreak) {
 		struct sk_buff *newskb;
 
-		newskb = dev_alloc_skb(PKT_BUF_SKB);
+		newskb = netdev_alloc_skb(dev, PKT_BUF_SKB);
 		if (newskb) {
 			skb_reserve(newskb, NET_IP_ALIGN);
 			skb = lp->rx_skbuff[entry];
@@ -1172,7 +1172,7 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		} else
 			skb = NULL;
 	} else
-		skb = dev_alloc_skb(pkt_len + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(dev, pkt_len + NET_IP_ALIGN);
 
 	if (skb == NULL) {
 		netif_err(lp, drv, dev, "Memory squeeze, dropping packet\n");
@@ -2273,11 +2273,11 @@ static int pcnet32_init_ring(struct net_device *dev)
 	for (i = 0; i < lp->rx_ring_size; i++) {
 		struct sk_buff *rx_skbuff = lp->rx_skbuff[i];
 		if (rx_skbuff == NULL) {
-			lp->rx_skbuff[i] = dev_alloc_skb(PKT_BUF_SKB);
+			lp->rx_skbuff[i] = netdev_alloc_skb(dev, PKT_BUF_SKB);
 			rx_skbuff = lp->rx_skbuff[i];
 			if (!rx_skbuff) {
 				/* there is not much we can do at this point */
-				netif_err(lp, drv, dev, "%s dev_alloc_skb failed\n",
+				netif_err(lp, drv, dev, "%s netdev_alloc_skb failed\n",
 					  __func__);
 				return -1;
 			}
diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index 080b71f..74b3891 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -810,7 +810,7 @@ static int lance_rx( struct net_device *dev )
 				dev->stats.rx_errors++;
 			}
 			else {
-				skb = dev_alloc_skb( pkt_len+2 );
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL) {
 					DPRINTK( 1, ( "%s: Memory squeeze, deferring packet.\n",
 						      dev->name ));
diff --git a/drivers/net/ethernet/amd/sunlance.c b/drivers/net/ethernet/amd/sunlance.c
index 7ea16d3..e3fe350 100644
--- a/drivers/net/ethernet/amd/sunlance.c
+++ b/drivers/net/ethernet/amd/sunlance.c
@@ -534,7 +534,7 @@ static void lance_rx_dvma(struct net_device *dev)
 			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (rd->mblength & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
@@ -706,7 +706,7 @@ static void lance_rx_pio(struct net_device *dev)
 			if (bits & LE_R1_EOP) dev->stats.rx_errors++;
 		} else {
 			len = (sbus_readw(&rd->mblength) & 0xfff) - 4;
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 
 			if (skb == NULL) {
 				printk(KERN_INFO "%s: Memory squeeze, deferring packet.\n",
diff --git a/drivers/net/ethernet/apple/bmac.c b/drivers/net/ethernet/apple/bmac.c
index d070b22..e6db743 100644
--- a/drivers/net/ethernet/apple/bmac.c
+++ b/drivers/net/ethernet/apple/bmac.c
@@ -607,8 +607,9 @@ bmac_init_tx_ring(struct bmac_data *bp)
 }
 
 static int
-bmac_init_rx_ring(struct bmac_data *bp)
+bmac_init_rx_ring(struct net_device *dev)
 {
+	struct bmac_data *bp = netdev_priv(dev);
 	volatile struct dbdma_regs __iomem *rd = bp->rx_dma;
 	int i;
 	struct sk_buff *skb;
@@ -618,7 +619,8 @@ bmac_init_rx_ring(struct bmac_data *bp)
 	       (N_RX_RING + 1) * sizeof(struct dbdma_cmd));
 	for (i = 0; i < N_RX_RING; i++) {
 		if ((skb = bp->rx_bufs[i]) == NULL) {
-			bp->rx_bufs[i] = skb = dev_alloc_skb(RX_BUFLEN+2);
+			bp->rx_bufs[i] = skb =
+				netdev_alloc_skb(dev, RX_BUFLEN + 2);
 			if (skb != NULL)
 				skb_reserve(skb, 2);
 		}
@@ -722,7 +724,8 @@ static irqreturn_t bmac_rxdma_intr(int irq, void *dev_id)
 			++dev->stats.rx_dropped;
 		}
 		if ((skb = bp->rx_bufs[i]) == NULL) {
-			bp->rx_bufs[i] = skb = dev_alloc_skb(RX_BUFLEN+2);
+			bp->rx_bufs[i] = skb =
+				netdev_alloc_skb(dev, RX_BUFLEN + 2);
 			if (skb != NULL)
 				skb_reserve(bp->rx_bufs[i], 2);
 		}
@@ -1208,7 +1211,7 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	spin_lock_irqsave(&bp->lock, flags);
 	bmac_enable_and_reset_chip(dev);
 	bmac_init_tx_ring(bp);
-	bmac_init_rx_ring(bp);
+	bmac_init_rx_ring(dev);
 	bmac_init_chip(dev);
 	bmac_start_chip(dev);
 	bmwrite(dev, INTDISABLE, EnableNormal);
@@ -1218,7 +1221,7 @@ static void bmac_reset_and_enable(struct net_device *dev)
 	 * It seems that the bmac can't receive until it's transmitted
 	 * a packet.  So we give it a dummy packet to transmit.
 	 */
-	skb = dev_alloc_skb(ETHERMINPACKET);
+	skb = netdev_alloc_skb(dev, ETHERMINPACKET);
 	if (skb != NULL) {
 		data = skb_put(skb, ETHERMINPACKET);
 		memset(data, 0, ETHERMINPACKET);
diff --git a/drivers/net/ethernet/apple/mace.c b/drivers/net/ethernet/apple/mace.c
index bec87bd..31a2d56 100644
--- a/drivers/net/ethernet/apple/mace.c
+++ b/drivers/net/ethernet/apple/mace.c
@@ -447,7 +447,7 @@ static int mace_open(struct net_device *dev)
     memset((char *)mp->rx_cmds, 0, N_RX_RING * sizeof(struct dbdma_cmd));
     cp = mp->rx_cmds;
     for (i = 0; i < N_RX_RING - 1; ++i) {
-	skb = dev_alloc_skb(RX_BUFLEN + 2);
+	skb = netdev_alloc_skb(dev, RX_BUFLEN + 2);
 	if (!skb) {
 	    data = dummy_buf;
 	} else {
@@ -959,7 +959,7 @@ static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 	cp = mp->rx_cmds + i;
 	skb = mp->rx_bufs[i];
 	if (!skb) {
-	    skb = dev_alloc_skb(RX_BUFLEN + 2);
+		skb = netdev_alloc_skb(RX_BUFLEN + 2);
 	    if (skb) {
 		skb_reserve(skb, 2);
 		mp->rx_bufs[i] = skb;
diff --git a/drivers/net/ethernet/apple/macmace.c b/drivers/net/ethernet/apple/macmace.c
index 7cf81bb..ab7ff86 100644
--- a/drivers/net/ethernet/apple/macmace.c
+++ b/drivers/net/ethernet/apple/macmace.c
@@ -661,7 +661,7 @@ static void mace_dma_rx_frame(struct net_device *dev, struct mace_frame *mf)
 	} else {
 		unsigned int frame_length = mf->rcvcnt + ((frame_status & 0x0F) << 8 );
 
-		skb = dev_alloc_skb(frame_length + 2);
+		skb = netdev_alloc_skb(dev, frame_length + 2);
 		if (!skb) {
 			dev->stats.rx_dropped++;
 			return;
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index b859124..c170c6e 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -1765,7 +1765,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 	while (next_info->flags & ATL1C_BUFFER_FREE) {
 		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
 
-		skb = dev_alloc_skb(adapter->rx_buffer_len);
+		skb = netdev_alloc_skb(adapter->netdev, adapter->rx_buffer_len);
 		if (unlikely(!skb)) {
 			if (netif_msg_rx_err(adapter))
 				dev_warn(&pdev->dev, "alloc rx buffer failed\n");
diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
index 1a5b6ef..9061170 100644
--- a/drivers/net/ethernet/cadence/at91_ether.c
+++ b/drivers/net/ethernet/cadence/at91_ether.c
@@ -886,7 +886,7 @@ static void at91ether_rx(struct net_device *dev)
 	while (dlist->descriptors[lp->rxBuffIndex].addr & EMAC_DESC_DONE) {
 		p_recv = dlist->recv_buf[lp->rxBuffIndex];
 		pktlen = dlist->descriptors[lp->rxBuffIndex].size & 0x7ff;	/* Length of frame including FCS */
-		skb = dev_alloc_skb(pktlen + 2);
+		skb = netdev_alloc_skb(dev, pktlen + 2);
 		if (skb != NULL) {
 			skb_reserve(skb, 2);
 			memcpy(skb_put(skb, pktlen), p_recv, pktlen);
diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..a9d8d5d 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -397,7 +397,7 @@ static int macb_rx_frame(struct macb *bp, unsigned int first_frag,
 	netdev_dbg(bp->dev, "macb_rx_frame frags %u - %u (len %u)\n",
 		   first_frag, last_frag, len);
 
-	skb = dev_alloc_skb(len + RX_OFFSET);
+	skb = netdev_alloc_skb(bp->dev, len + RX_OFFSET);
 	if (!skb) {
 		bp->stats.rx_dropped++;
 		for (frag = first_frag; ; frag = NEXT_RX(frag)) {
diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index f328da2..d5ff936 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -911,7 +911,7 @@ dma_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(length + 2);
+	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 		if (net_debug)	/* I don't think we want to do this to a stressed system */
 			printk("%s: Memory squeeze, dropping packet.\n", dev->name);
@@ -1616,7 +1616,7 @@ net_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(length + 2);
+	skb = netdev_alloc_skb(dev, length + 2);
 	if (skb == NULL) {
 #if 0		/* Again, this seems a cruel thing to do */
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
diff --git a/drivers/net/ethernet/cirrus/ep93xx_eth.c b/drivers/net/ethernet/cirrus/ep93xx_eth.c
index 4317af8..c21e5ab 100644
--- a/drivers/net/ethernet/cirrus/ep93xx_eth.c
+++ b/drivers/net/ethernet/cirrus/ep93xx_eth.c
@@ -282,7 +282,7 @@ static int ep93xx_rx(struct net_device *dev, int processed, int budget)
 		if (rstat0 & RSTAT0_CRCI)
 			length -= 4;
 
-		skb = dev_alloc_skb(length + 2);
+		skb = netdev_alloc_skb(dev, length + 2);
 		if (likely(skb != NULL)) {
 			struct ep93xx_rdesc *rxd = &ep->descs->rdesc[entry];
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index f801754..9087817 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1028,7 +1028,7 @@ dm9000_rx(struct net_device *dev)
 
 		/* Move data from DM9000 */
 		if (GoodPacket &&
-		    ((skb = dev_alloc_skb(RxLen + 4)) != NULL)) {
+		    ((skb = netdev_alloc_skb(dev, RxLen + 4)) != NULL)) {
 			skb_reserve(skb, 2);
 			rdptr = (u8 *) skb_put(skb, RxLen - 4);
 
diff --git a/drivers/net/ethernet/dec/ewrk3.c b/drivers/net/ethernet/dec/ewrk3.c
index f9df5e4..1879f84 100644
--- a/drivers/net/ethernet/dec/ewrk3.c
+++ b/drivers/net/ethernet/dec/ewrk3.c
@@ -986,8 +986,10 @@ static int ewrk3_rx(struct net_device *dev)
 						dev->stats.rx_fifo_errors++;
 				} else {
 					struct sk_buff *skb;
+					skb = netdev_alloc_skb(dev,
+							pkt_len + 2);
 
-					if ((skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+					if (skb != NULL) {
 						unsigned char *p;
 						skb_reserve(skb, 2);	/* Align to 16 bytes */
 						p = skb_put(skb, pkt_len);
diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 1eb46a0..54359e1 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -439,7 +439,7 @@ static void de_rx (struct de_private *de)
 			  rx_tail, status, len, copying_skb);
 
 		buflen = copying_skb ? (len + RX_OFFSET) : de->rx_buf_sz;
-		copy_skb = dev_alloc_skb (buflen);
+		copy_skb = netdev_alloc_skb(de->dev, buflen);
 		if (unlikely(!copy_skb)) {
 			de->net_stats.rx_dropped++;
 			drop = 1;
@@ -1283,7 +1283,7 @@ static int de_refill_rx (struct de_private *de)
 	for (i = 0; i < DE_RX_RING_SIZE; i++) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(de->rx_buf_sz);
+		skb = netdev_alloc_skb(de->dev, de->rx_buf_sz);
 		if (!skb)
 			goto err_out;
 
diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 4d71f5a..3f89eae 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -3598,7 +3598,7 @@ de4x5_alloc_rx_buff(struct net_device *dev, int index, int len)
     struct sk_buff *ret;
     u_long i=0, tmp;
 
-    p = dev_alloc_skb(IEEE802_3_SZ + DE4X5_ALIGN + 2);
+	p = netdev_alloc_skb(dev, IEEE802_3_SZ + DE4X5_ALIGN + 2);
     if (!p) return NULL;
 
     tmp = virt_to_bus(p->data);
@@ -3618,7 +3618,7 @@ de4x5_alloc_rx_buff(struct net_device *dev, int index, int len)
 #else
     if (lp->state != OPEN) return (struct sk_buff *)1; /* Fake out the open */
 
-    p = dev_alloc_skb(len + 2);
+	p = netdev_alloc_skb(dev, len + 2);
     if (!p) return NULL;
 
     skb_reserve(p, 2);	                               /* Align */
diff --git a/drivers/net/ethernet/dec/tulip/dmfe.c b/drivers/net/ethernet/dec/tulip/dmfe.c
index 51f7542..71ae569 100644
--- a/drivers/net/ethernet/dec/tulip/dmfe.c
+++ b/drivers/net/ethernet/dec/tulip/dmfe.c
@@ -325,8 +325,8 @@ static irqreturn_t dmfe_interrupt(int , void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_dmfe (struct net_device *dev);
 #endif
-static void dmfe_descriptor_init(struct dmfe_board_info *, unsigned long);
-static void allocate_rx_buffer(struct dmfe_board_info *);
+static void dmfe_descriptor_init(struct net_device *, unsigned long);
+static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, unsigned long);
 static void send_filter_frame(struct DEVICE *);
 static void dm9132_id_table(struct DEVICE *);
@@ -649,7 +649,7 @@ static void dmfe_init_dm910x(struct DEVICE *dev)
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
-	dmfe_descriptor_init(db, ioaddr);
+	dmfe_descriptor_init(dev, ioaddr);
 
 	/* Init CR6 to program DM910x operation */
 	update_cr6(db->cr6_data, ioaddr);
@@ -828,7 +828,7 @@ static irqreturn_t dmfe_interrupt(int irq, void *dev_id)
 
 	/* reallocate rx descriptor buffer */
 	if (db->rx_avail_cnt<RX_DESC_CNT)
-		allocate_rx_buffer(db);
+		allocate_rx_buffer(dev);
 
 	/* Free the transmitted descriptor */
 	if ( db->cr5_data & 0x01)
@@ -1008,8 +1008,10 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 					/* Good packet, send to upper layer */
 					/* Shorst packet used new SKB */
 					if ((rxlen < RX_COPY_SIZE) &&
-						((newskb = dev_alloc_skb(rxlen + 2))
-						!= NULL)) {
+						((newskb =
+						  netdev_alloc_skb(dev,
+							  rxlen + 2))
+						 != NULL)) {
 
 						skb = newskb;
 						/* size less than COPY_SIZE, allocate a rxlen SKB */
@@ -1364,8 +1366,9 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioaddr)
+static void dmfe_descriptor_init(struct net_device *dev, unsigned long ioaddr)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
@@ -1421,7 +1424,7 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
 	tmp_rx->next_rx_desc = db->first_rx_desc;
 
 	/* pre-allocate Rx buffer */
-	allocate_rx_buffer(db);
+	allocate_rx_buffer(dev);
 }
 
 
@@ -1551,15 +1554,17 @@ static void send_filter_frame(struct DEVICE *dev)
  *	As possible as allocate maxiumn Rx buffer
  */
 
-static void allocate_rx_buffer(struct dmfe_board_info *db)
+static void allocate_rx_buffer(struct net_device *dev)
 {
+	struct dmfe_board_info *db = netdev_priv(dev);
 	struct rx_desc *rxptr;
 	struct sk_buff *skb;
 
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		skb = netdev_alloc_skb(dev, RX_ALLOC_SIZE);
+		if (skb == NULL)
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
diff --git a/drivers/net/ethernet/dec/tulip/interrupt.c b/drivers/net/ethernet/dec/tulip/interrupt.c
index 4fb8c8c..49d6ada 100644
--- a/drivers/net/ethernet/dec/tulip/interrupt.c
+++ b/drivers/net/ethernet/dec/tulip/interrupt.c
@@ -69,7 +69,8 @@ int tulip_refill_rx(struct net_device *dev)
 			struct sk_buff *skb;
 			dma_addr_t mapping;
 
-			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = tp->rx_buffers[entry].skb =
+				netdev_alloc_skb(dev, PKT_BUF_SZ);
 			if (skb == NULL)
 				break;
 
@@ -202,7 +203,7 @@ int tulip_poll(struct napi_struct *napi, int budget)
                                /* Check if the packet is long enough to accept without copying
                                   to a minimally-sized skbuff. */
                                if (pkt_len < tulip_rx_copybreak &&
-                                   (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+                                   (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
                                        skb_reserve(skb, 2);    /* 16 byte align the IP header */
                                        pci_dma_sync_single_for_cpu(tp->pdev,
 								   tp->rx_buffers[entry].mapping,
@@ -428,7 +429,7 @@ static int tulip_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < tulip_rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(tp->pdev,
 							    tp->rx_buffers[entry].mapping,
diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index 4eb0d76..d92ba9e 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -636,9 +636,9 @@ static void tulip_init_ring(struct net_device *dev)
 		dma_addr_t mapping;
 
 		/* Note the receive buffer must be longword aligned.
-		   dev_alloc_skb() provides 16 byte alignment.  But do *not*
+		   netdev_alloc_skb() provides 16 byte alignment.  But do *not*
 		   use skb_reserve() to align the IP header! */
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 		tp->rx_buffers[i].skb = skb;
 		if (skb == NULL)
 			break;
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index 48b0b65..1125044 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -232,8 +232,8 @@ static irqreturn_t uli526x_interrupt(int, void *);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void uli526x_poll(struct net_device *dev);
 #endif
-static void uli526x_descriptor_init(struct uli526x_board_info *, unsigned long);
-static void allocate_rx_buffer(struct uli526x_board_info *);
+static void uli526x_descriptor_init(struct net_device *, unsigned long);
+static void allocate_rx_buffer(struct net_device *);
 static void update_cr6(u32, unsigned long);
 static void send_filter_frame(struct net_device *, int);
 static u16 phy_read(unsigned long, u8, u8, u32);
@@ -549,7 +549,7 @@ static void uli526x_init(struct net_device *dev)
 		db->op_mode = db->media_mode; 	/* Force Mode */
 
 	/* Initialize Transmit/Receive decriptor and CR3/4 */
-	uli526x_descriptor_init(db, ioaddr);
+	uli526x_descriptor_init(dev, ioaddr);
 
 	/* Init CR6 to program M526X operation */
 	update_cr6(db->cr6_data, ioaddr);
@@ -711,7 +711,7 @@ static irqreturn_t uli526x_interrupt(int irq, void *dev_id)
 
 	/* reallocate rx descriptor buffer */
 	if (db->rx_avail_cnt<RX_DESC_CNT)
-		allocate_rx_buffer(db);
+		allocate_rx_buffer(dev);
 
 	/* Free the transmitted descriptor */
 	if ( db->cr5_data & 0x01)
@@ -844,7 +844,7 @@ static void uli526x_rx_packet(struct net_device *dev, struct uli526x_board_info
 				/* Good packet, send to upper layer */
 				/* Shorst packet used new SKB */
 				if ((rxlen < RX_COPY_SIZE) &&
-				    (((new_skb = dev_alloc_skb(rxlen + 2)) != NULL))) {
+				    (((new_skb = netdev_alloc_skb(dev, rxlen + 2)) != NULL))) {
 					skb = new_skb;
 					/* size less than COPY_SIZE, allocate a rxlen SKB */
 					skb_reserve(skb, 2); /* 16byte align */
@@ -1289,8 +1289,10 @@ static void uli526x_reuse_skb(struct uli526x_board_info *db, struct sk_buff * sk
  *	Using Chain structure, and allocate Tx/Rx buffer
  */
 
-static void uli526x_descriptor_init(struct uli526x_board_info *db, unsigned long ioaddr)
+static void uli526x_descriptor_init(struct net_device *dev,
+		unsigned long ioaddr)
 {
+	struct uli526x_board_info *db = netdev_priv(dev);
 	struct tx_desc *tmp_tx;
 	struct rx_desc *tmp_rx;
 	unsigned char *tmp_buf;
@@ -1343,7 +1345,7 @@ static void uli526x_descriptor_init(struct uli526x_board_info *db, unsigned long
 	tmp_rx->next_rx_desc = db->first_rx_desc;
 
 	/* pre-allocate Rx buffer */
-	allocate_rx_buffer(db);
+	allocate_rx_buffer(dev);
 }
 
 
@@ -1433,15 +1435,17 @@ static void send_filter_frame(struct net_device *dev, int mc_cnt)
  *	As possible as allocate maxiumn Rx buffer
  */
 
-static void allocate_rx_buffer(struct uli526x_board_info *db)
+static void allocate_rx_buffer(struct net_device *dev)
 {
+	struct uli526x_board_info *db = netdev_priv(dev);
 	struct rx_desc *rxptr;
 	struct sk_buff *skb;
 
 	rxptr = db->rx_insert_ptr;
 
 	while(db->rx_avail_cnt < RX_DESC_CNT) {
-		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
+		skb = netdev_alloc_skb(dev, RX_ALLOC_SIZE);
+		if (skb == NULL)
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
 		rxptr->rdes2 = cpu_to_le32(pci_map_single(db->pdev,
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 52da7b2..2ac6fff 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -815,7 +815,7 @@ static void init_rxtx_rings(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1231,7 +1231,7 @@ static int netdev_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,np->rx_addr[entry],
 							    np->rx_skbuff[entry]->len,
@@ -1270,7 +1270,7 @@ static int netdev_rx(struct net_device *dev)
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;			/* Better luck next round. */
diff --git a/drivers/net/ethernet/dec/tulip/xircom_cb.c b/drivers/net/ethernet/dec/tulip/xircom_cb.c
index 988b8eb..2483a3e 100644
--- a/drivers/net/ethernet/dec/tulip/xircom_cb.c
+++ b/drivers/net/ethernet/dec/tulip/xircom_cb.c
@@ -1085,7 +1085,7 @@ investigate_read_descriptor(struct net_device *dev, struct xircom_private *card,
 			pkt_len = 1518;
 		}
 
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
 			dev->stats.rx_dropped++;
 			goto out;
diff --git a/drivers/net/ethernet/dlink/de600.c b/drivers/net/ethernet/dlink/de600.c
index c24fab1..682750c 100644
--- a/drivers/net/ethernet/dlink/de600.c
+++ b/drivers/net/ethernet/dlink/de600.c
@@ -335,7 +335,7 @@ static void de600_rx_intr(struct net_device *dev)
 		return;
 	}
 
-	skb = dev_alloc_skb(size+2);
+	skb = netdev_alloc_skb(dev, size + 2);
 	if (skb == NULL) {
 		printk("%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
 		return;
diff --git a/drivers/net/ethernet/dlink/de620.c b/drivers/net/ethernet/dlink/de620.c
index 3b934ab..afc5aaa 100644
--- a/drivers/net/ethernet/dlink/de620.c
+++ b/drivers/net/ethernet/dlink/de620.c
@@ -650,7 +650,7 @@ static int de620_rx_intr(struct net_device *dev)
 		printk(KERN_WARNING "%s: Illegal packet size: %d!\n", dev->name, size);
 	}
 	else { /* Good packet? */
-		skb = dev_alloc_skb(size+2);
+		skb = netdev_alloc_skb(dev, size + 2);
 		if (skb == NULL) { /* Yeah, but no place to put it... */
 			printk(KERN_WARNING "%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
 			dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/dlink/sundance.c b/drivers/net/ethernet/dlink/sundance.c
index 28a3a9b..7f6f99b 100644
--- a/drivers/net/ethernet/dlink/sundance.c
+++ b/drivers/net/ethernet/dlink/sundance.c
@@ -1020,7 +1020,8 @@ static void init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + 2);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + 2);
 		np->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1358,7 +1359,7 @@ static void rx_poll(unsigned long data)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				dma_sync_single_for_cpu(&np->pci_dev->dev,
 						le32_to_cpu(desc->frag[0].addr),
@@ -1411,7 +1412,7 @@ static void refill_rx (struct net_device *dev)
 		struct sk_buff *skb;
 		entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(np->rx_buf_sz + 2);
+			skb = netdev_alloc_skb(dev, np->rx_buf_sz + 2);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;		/* Better luck next round. */
diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..6b2f224 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -421,7 +421,7 @@ static int dnet_poll(struct napi_struct *napi, int budget)
 			printk(KERN_ERR "%s packet receive error %x\n",
 			       __func__, cmd_word);
 
-		skb = dev_alloc_skb(pkt_len + 5);
+		skb = netdev_alloc_skb(dev, pkt_len + 5);
 		if (skb != NULL) {
 			/* Align IP on 16 byte boundaries */
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/fealnx.c b/drivers/net/ethernet/fealnx.c
index c82d444..cded627 100644
--- a/drivers/net/ethernet/fealnx.c
+++ b/drivers/net/ethernet/fealnx.c
@@ -1070,7 +1070,7 @@ static void allocate_rx_buffers(struct net_device *dev)
 	while (np->really_rx_count != RX_RING_SIZE) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(np->rx_buf_sz);
+		skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 		if (skb == NULL)
 			break;	/* Better luck next round. */
 
@@ -1265,7 +1265,7 @@ static void init_ring(struct net_device *dev)
 
 	/* allocate skb for rx buffers */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz);
+		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz);
 
 		if (skb == NULL) {
 			np->lack_rxbuf = &np->rx_ring[i];
@@ -1704,7 +1704,7 @@ static int netdev_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(np->pci_dev,
 							    np->cur_rx->buffer,
diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index 7b25e9c..4ad061f 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -711,7 +711,7 @@ fec_enet_rx(struct net_device *ndev)
 		 * include that when passing upstream as it messes up
 		 * bridging applications.
 		 */
-		skb = dev_alloc_skb(pkt_len - 4 + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(dev, pkt_len - 4 + NET_IP_ALIGN);
 
 		if (unlikely(!skb)) {
 			printk("%s: Memory squeeze, dropping packet.\n",
@@ -1210,7 +1210,7 @@ static int fec_enet_alloc_buffers(struct net_device *ndev)
 
 	bdp = fep->rx_bd_base;
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		skb = dev_alloc_skb(FEC_ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(dev, FEC_ENET_RX_FRSIZE);
 		if (!skb) {
 			fec_enet_free_buffers(ndev);
 			return -ENOMEM;
diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/net/ethernet/freescale/fec_mpc52xx.c
index 30745b5..7b34d8c 100644
--- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
+++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
@@ -160,7 +160,7 @@ static int mpc52xx_fec_alloc_rx_buffers(struct net_device *dev, struct bcom_task
 	struct sk_buff *skb;
 
 	while (!bcom_queue_full(rxtsk)) {
-		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		skb = netdev_alloc_skb(dev, FEC_RX_BUFFER_SIZE);
 		if (!skb)
 			return -EAGAIN;
 
@@ -416,7 +416,7 @@ static irqreturn_t mpc52xx_fec_rx_interrupt(int irq, void *dev_id)
 
 		/* skbs are allocated on open, so now we allocate a new one,
 		 * and remove the old (with the packet) */
-		skb = dev_alloc_skb(FEC_RX_BUFFER_SIZE);
+		skb = netdev_alloc_skb(dev, FEC_RX_BUFFER_SIZE);
 		if (!skb) {
 			/* Can't get a new one : reuse the same & drop pkt */
 			dev_notice(&dev->dev, "Low memory - dropped packet.\n");
diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
index 910a8e1..999638a 100644
--- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
+++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
@@ -154,7 +154,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 
 			if (pkt_len <= fpi->rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
-				skbn = dev_alloc_skb(pkt_len + 2);
+				skbn = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
 					skb_copy_from_linear_data(skb,
@@ -165,7 +165,7 @@ static int fs_enet_rx_napi(struct napi_struct *napi, int budget)
 					skbn = skbt;
 				}
 			} else {
-				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
+				skbn = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 
 				if (skbn)
 					skb_align(skbn, ENET_RX_ALIGN);
@@ -286,7 +286,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 
 			if (pkt_len <= fpi->rx_copybreak) {
 				/* +2 to make IP header L1 cache aligned */
-				skbn = dev_alloc_skb(pkt_len + 2);
+				skbn = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skbn != NULL) {
 					skb_reserve(skbn, 2);	/* align IP header */
 					skb_copy_from_linear_data(skb,
@@ -297,7 +297,7 @@ static int fs_enet_rx_non_napi(struct net_device *dev)
 					skbn = skbt;
 				}
 			} else {
-				skbn = dev_alloc_skb(ENET_RX_FRSIZE);
+				skbn = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 
 				if (skbn)
 					skb_align(skbn, ENET_RX_ALIGN);
@@ -504,7 +504,7 @@ void fs_init_bds(struct net_device *dev)
 	 * Initialize the receive buffer descriptors.
 	 */
 	for (i = 0, bdp = fep->rx_bd_base; i < fep->rx_ring; i++, bdp++) {
-		skb = dev_alloc_skb(ENET_RX_FRSIZE);
+		skb = netdev_alloc_skb(dev, ENET_RX_FRSIZE);
 		if (skb == NULL) {
 			dev_warn(fep->dev,
 				 "Memory squeeze, unable to allocate skb\n");
@@ -592,7 +592,7 @@ static struct sk_buff *tx_skb_align_workaround(struct net_device *dev,
 	struct fs_enet_private *fep = netdev_priv(dev);
 
 	/* Alloc new skb */
-	new_skb = dev_alloc_skb(skb->len + 4);
+	new_skb = netdev_alloc_skb(dev, skb->len + 4);
 	if (!new_skb) {
 		if (net_ratelimit()) {
 			dev_warn(fep->dev,
diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index ba2dc08..7138295 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -214,8 +214,9 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
 
 	skb = __skb_dequeue(&ugeth->rx_recycle);
 	if (!skb)
-		skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
-				    UCC_GETH_RX_DATA_BUF_ALIGNMENT);
+		skb = netdev_alloc_skb(ugeth->ndev,
+				ugeth->ug_info->uf_info.max_rx_buf_length +
+				UCC_GETH_RX_DATA_BUF_ALIGNMENT);
 	if (skb == NULL)
 		return NULL;
 
diff --git a/drivers/net/ethernet/fujitsu/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
index 7c6c908..586b46f 100644
--- a/drivers/net/ethernet/fujitsu/at1700.c
+++ b/drivers/net/ethernet/fujitsu/at1700.c
@@ -757,7 +757,7 @@ net_rx(struct net_device *dev)
 				dev->stats.rx_errors++;
 				break;
 			}
-			skb = dev_alloc_skb(pkt_len+3);
+			skb = netdev_alloc_skb(dev, pkt_len + 3);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet (len %d).\n",
 					   dev->name, pkt_len);
diff --git a/drivers/net/ethernet/fujitsu/eth16i.c b/drivers/net/ethernet/fujitsu/eth16i.c
index b0e2313..c3f0178 100644
--- a/drivers/net/ethernet/fujitsu/eth16i.c
+++ b/drivers/net/ethernet/fujitsu/eth16i.c
@@ -1164,7 +1164,7 @@ static void eth16i_rx(struct net_device *dev)
 		else {   /* Ok so now we should have a good packet */
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len + 3);
+			skb = netdev_alloc_skb(dev, pkt_len + 3);
 			if( skb == NULL ) {
 				printk(KERN_WARNING "%s: Could'n allocate memory for packet (len %d)\n",
 				       dev->name, pkt_len);
diff --git a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
index ee84b47..0230319 100644
--- a/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
+++ b/drivers/net/ethernet/fujitsu/fmvj18x_cs.c
@@ -1002,7 +1002,7 @@ static void fjn_rx(struct net_device *dev)
 		dev->stats.rx_errors++;
 		break;
 	    }
-	    skb = dev_alloc_skb(pkt_len+2);
+	    skb = netdev_alloc_skb(dev, pkt_len + 2);
 	    if (skb == NULL) {
 		netdev_notice(dev, "Memory squeeze, dropping packet (len %d)\n",
 			      pkt_len);
diff --git a/drivers/net/ethernet/hp/hp100.c b/drivers/net/ethernet/hp/hp100.c
index 6a5ee07..b98521c 100644
--- a/drivers/net/ethernet/hp/hp100.c
+++ b/drivers/net/ethernet/hp/hp100.c
@@ -1274,7 +1274,7 @@ static int hp100_build_rx_pdl(hp100_ring_t * ringptr,
 	/* Note: This depends on the alloc_skb functions allocating more
 	 * space than requested, i.e. aligning to 16bytes */
 
-	ringptr->skb = dev_alloc_skb(roundup(MAX_ETHER_SIZE + 2, 4));
+	ringptr->skb = netdev_alloc_skb(dev, roundup(MAX_ETHER_SIZE + 2, 4));
 
 	if (NULL != ringptr->skb) {
 		/*
@@ -1817,7 +1817,7 @@ static void hp100_rx(struct net_device *dev)
 #endif
 
 		/* Now we allocate the skb and transfer the data into it. */
-		skb = dev_alloc_skb(pkt_len+2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {	/* Not enough memory->drop packet */
 #ifdef HP100_DEBUG
 			printk("hp100: %s: rx: couldn't allocate a sk_buff of size %d\n",
diff --git a/drivers/net/ethernet/i825xx/3c505.c b/drivers/net/ethernet/i825xx/3c505.c
index ba82a26..6a5c21b 100644
--- a/drivers/net/ethernet/i825xx/3c505.c
+++ b/drivers/net/ethernet/i825xx/3c505.c
@@ -583,7 +583,7 @@ static void receive_packet(struct net_device *dev, int len)
 	unsigned long flags;
 
 	rlen = (len + 1) & ~1;
-	skb = dev_alloc_skb(rlen + 2);
+	skb = netdev_alloc_skb(dev, rlen + 2);
 
 	if (!skb) {
 		pr_warning("%s: memory squeeze, dropping packet\n", dev->name);
diff --git a/drivers/net/ethernet/i825xx/3c507.c b/drivers/net/ethernet/i825xx/3c507.c
index 1e94555..ed6925f 100644
--- a/drivers/net/ethernet/i825xx/3c507.c
+++ b/drivers/net/ethernet/i825xx/3c507.c
@@ -851,7 +851,7 @@ static void el16_rx(struct net_device *dev)
 			struct sk_buff *skb;
 
 			pkt_len &= 0x3fff;
-			skb = dev_alloc_skb(pkt_len+2);
+			skb = netdev_alloc_skb(dev, pkt_len + 2);
 			if (skb == NULL) {
 				pr_err("%s: Memory squeeze, dropping packet.\n",
 				       dev->name);
diff --git a/drivers/net/ethernet/i825xx/3c523.c b/drivers/net/ethernet/i825xx/3c523.c
index d70d3df..8451ecd 100644
--- a/drivers/net/ethernet/i825xx/3c523.c
+++ b/drivers/net/ethernet/i825xx/3c523.c
@@ -983,7 +983,7 @@ static void elmc_rcv_int(struct net_device *dev)
 			if ((totlen = rbd->status) & RBD_LAST) {	/* the first and the last buffer? */
 				totlen &= RBD_MASK;	/* length of this frame */
 				rbd->status = 0;
-				skb = (struct sk_buff *) dev_alloc_skb(totlen + 2);
+				skb = netdev_alloc_skb(dev, totlen + 2);
 				if (skb != NULL) {
 					skb_reserve(skb, 2);	/* 16 byte alignment */
 					skb_put(skb,totlen);
diff --git a/drivers/net/ethernet/i825xx/3c527.c b/drivers/net/ethernet/i825xx/3c527.c
index 474b5e7..ef43f3e 100644
--- a/drivers/net/ethernet/i825xx/3c527.c
+++ b/drivers/net/ethernet/i825xx/3c527.c
@@ -1169,7 +1169,7 @@ static void mc32_rx_ring(struct net_device *dev)
 			/* Try to save time by avoiding a copy on big frames */
 
 			if ((length > RX_COPYBREAK) &&
-			    ((newskb=dev_alloc_skb(1532)) != NULL))
+			    ((newskb = netdev_alloc_skb(dev, 1532)) != NULL))
 			{
 				skb=lp->rx_ring[rx_ring_tail].skb;
 				skb_put(skb, length);
@@ -1180,7 +1180,7 @@ static void mc32_rx_ring(struct net_device *dev)
 			}
 			else
 			{
-				skb=dev_alloc_skb(length+2);
+				skb = netdev_alloc_skb(dev, length + 2);
 
 				if(skb==NULL) {
 					dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/i825xx/82596.c b/drivers/net/ethernet/i825xx/82596.c
index f2408a4..f86ad75 100644
--- a/drivers/net/ethernet/i825xx/82596.c
+++ b/drivers/net/ethernet/i825xx/82596.c
@@ -549,7 +549,7 @@ static inline int init_rx_bufs(struct net_device *dev)
 	/* First build the Receive Buffer Descriptor List */
 
 	for (i = 0, rbd = lp->rbds; i < rx_ring_size; i++, rbd++) {
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 
 		if (skb == NULL) {
 			remove_rx_bufs(dev);
@@ -810,7 +810,7 @@ static inline int i596_rx(struct net_device *dev)
 				struct sk_buff *newskb;
 
 				/* Get fresh skbuff to replace filled one. */
-				newskb = dev_alloc_skb(PKT_BUF_SZ);
+				newskb = netdev_alloc_skb(dev, PKT_BUF_SZ);
 				if (newskb == NULL) {
 					skb = NULL;	/* drop pkt */
 					goto memory_squeeze;
@@ -827,7 +827,7 @@ static inline int i596_rx(struct net_device *dev)
 #endif
 			}
 			else
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 memory_squeeze:
 			if (skb == NULL) {
 				/* XXX tulip.c can defer packets here!! */
diff --git a/drivers/net/ethernet/i825xx/eepro.c b/drivers/net/ethernet/i825xx/eepro.c
index 114cda77..7a4ad4a 100644
--- a/drivers/net/ethernet/i825xx/eepro.c
+++ b/drivers/net/ethernet/i825xx/eepro.c
@@ -1563,7 +1563,7 @@ eepro_rx(struct net_device *dev)
 
 			dev->stats.rx_bytes+=rcv_size;
 			rcv_size &= 0x3fff;
-			skb = dev_alloc_skb(rcv_size+5);
+			skb = netdev_alloc_skb(dev, rcv_size + 5);
 			if (skb == NULL) {
 				printk(KERN_NOTICE "%s: Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/i825xx/eexpress.c b/drivers/net/ethernet/i825xx/eexpress.c
index 3a9580f..3fc649e 100644
--- a/drivers/net/ethernet/i825xx/eexpress.c
+++ b/drivers/net/ethernet/i825xx/eexpress.c
@@ -955,7 +955,7 @@ static void eexp_hw_rx_pio(struct net_device *dev)
 			{
 				struct sk_buff *skb;
 				pkt_len &= 0x3fff;
-				skb = dev_alloc_skb(pkt_len+16);
+				skb = netdev_alloc_skb(dev, pkt_len + 16);
 				if (skb == NULL)
 				{
 					printk(KERN_WARNING "%s: Memory squeeze, dropping packet\n",dev->name);
diff --git a/drivers/net/ethernet/i825xx/ether1.c b/drivers/net/ethernet/i825xx/ether1.c
index 42e90a9..406a12b 100644
--- a/drivers/net/ethernet/i825xx/ether1.c
+++ b/drivers/net/ethernet/i825xx/ether1.c
@@ -867,7 +867,7 @@ ether1_recv_done (struct net_device *dev)
 			struct sk_buff *skb;
 
 			length = (length + 1) & ~1;
-			skb = dev_alloc_skb (length + 2);
+			skb = netdev_alloc_skb(dev, length + 2);
 
 			if (skb) {
 				skb_reserve (skb, 2);
diff --git a/drivers/net/ethernet/i825xx/lp486e.c b/drivers/net/ethernet/i825xx/lp486e.c
index 414044b..2ad5f10 100644
--- a/drivers/net/ethernet/i825xx/lp486e.c
+++ b/drivers/net/ethernet/i825xx/lp486e.c
@@ -658,7 +658,7 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 	if (rfd->stat & RFD_STAT_OK) {
 		/* a good frame */
 		int pkt_len = (rfd->count & 0x3fff);
-		struct sk_buff *skb = dev_alloc_skb(pkt_len);
+		struct sk_buff *skb = netdev_alloc_skb(dev, pkt_len);
 
 		(*frames)++;
 
diff --git a/drivers/net/ethernet/i825xx/ni52.c b/drivers/net/ethernet/i825xx/ni52.c
index c089371..272976e 100644
--- a/drivers/net/ethernet/i825xx/ni52.c
+++ b/drivers/net/ethernet/i825xx/ni52.c
@@ -964,7 +964,7 @@ static void ni52_rcv_int(struct net_device *dev)
 				/* the first and the last buffer? */
 				totlen &= RBD_MASK; /* length of this frame */
 				writew(0x00, &rbd->status);
-				skb = (struct sk_buff *)dev_alloc_skb(totlen+2);
+				skb = netdev_alloc_skb(dev, totlen + 2);
 				if (skb != NULL) {
 					skb_reserve(skb, 2);
 					skb_put(skb, totlen);
diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 6ef5e11..5a523dc 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -779,7 +779,7 @@ static void sun3_82586_rcv_int(struct net_device *dev)
 				{
 					totlen &= RBD_MASK; /* length of this frame */
 					rbd->status = 0;
-					skb = (struct sk_buff *) dev_alloc_skb(totlen+2);
+					skb = netdev_alloc_skb(dev, totlen + 2);
 					if(skb != NULL)
 					{
 						skb_reserve(skb,2);
diff --git a/drivers/net/ethernet/i825xx/znet.c b/drivers/net/ethernet/i825xx/znet.c
index 962b4c4..a436497 100644
--- a/drivers/net/ethernet/i825xx/znet.c
+++ b/drivers/net/ethernet/i825xx/znet.c
@@ -762,7 +762,7 @@ static void znet_rx(struct net_device *dev)
 			/* Malloc up new buffer. */
 			struct sk_buff *skb;
 
-			skb = dev_alloc_skb(pkt_len);
+			skb = netdev_alloc_skb(dev, pkt_len);
 			if (skb == NULL) {
 				if (znet_debug)
 				  printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
diff --git a/drivers/net/ethernet/lantiq_etop.c b/drivers/net/ethernet/lantiq_etop.c
index 85e2c6c..ce54778 100644
--- a/drivers/net/ethernet/lantiq_etop.c
+++ b/drivers/net/ethernet/lantiq_etop.c
@@ -114,7 +114,7 @@ struct ltq_etop_priv {
 static int
 ltq_etop_alloc_skb(struct ltq_etop_chan *ch)
 {
-	ch->skb[ch->dma.desc] = dev_alloc_skb(MAX_DMA_DATA_LEN);
+	ch->skb[ch->dma.desc] = netdev_alloc_skb(ch->netdev, MAX_DMA_DATA_LEN);
 	if (!ch->skb[ch->dma.desc])
 		return -ENOMEM;
 	ch->dma.desc_base[ch->dma.desc].addr = dma_map_single(NULL,
diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net/ethernet/marvell/mv643xx_eth.c
index 9c049d2..e3eea0e 100644
--- a/drivers/net/ethernet/marvell/mv643xx_eth.c
+++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
@@ -662,7 +662,7 @@ static int rxq_refill(struct rx_queue *rxq, int budget)
 
 		skb = __skb_dequeue(&mp->rx_recycle);
 		if (skb == NULL)
-			skb = dev_alloc_skb(mp->skb_size);
+			skb = netdev_alloc_skb(mp->dev, mp->skb_size);
 
 		if (skb == NULL) {
 			mp->oom = 1;
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..a76bf553 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -350,7 +350,7 @@ static void rxq_refill(struct net_device *dev)
 	while (pep->rx_desc_count < pep->rx_ring_size) {
 		int size;
 
-		skb = dev_alloc_skb(pep->skb_size);
+		skb = netdev_alloc_skb(dev, pep->skb_size);
 		if (!skb)
 			break;
 		if (SKB_DMA_REALIGN)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 971d4b6..1cf6345 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -464,7 +464,7 @@ static struct sk_buff *mlx4_en_rx_skb(struct mlx4_en_priv *priv,
 	int used_frags;
 	dma_addr_t dma;
 
-	skb = dev_alloc_skb(SMALL_PACKET_SIZE + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(priv->dev, SMALL_PACKET_SIZE + NET_IP_ALIGN);
 	if (!skb) {
 		en_dbg(RX_ERR, priv, "Failed allocating skb\n");
 		return NULL;
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index ab81c0d..cd748ca 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -278,7 +278,8 @@ ks8695_refill_rxbuffers(struct ks8695_priv *ksp)
 
 	for (buff_n = 0; buff_n < MAX_RX_DESC; ++buff_n) {
 		if (!ksp->rx_buffers[buff_n].skb) {
-			struct sk_buff *skb = dev_alloc_skb(MAX_RXBUF_SIZE);
+			struct sk_buff *skb =
+				netdev_alloc_skb(ksp->ndev, MAX_RXBUF_SIZE);
 			dma_addr_t mapping;
 
 			ksp->rx_buffers[buff_n].skb = skb;
diff --git a/drivers/net/ethernet/micrel/ks8851_mll.c b/drivers/net/ethernet/micrel/ks8851_mll.c
index e58e78e..076996f 100644
--- a/drivers/net/ethernet/micrel/ks8851_mll.c
+++ b/drivers/net/ethernet/micrel/ks8851_mll.c
@@ -796,7 +796,7 @@ static void ks_rcv(struct ks_net *ks, struct net_device *netdev)
 
 	frame_hdr = ks->frame_head_info;
 	while (ks->frame_cnt--) {
-		skb = dev_alloc_skb(frame_hdr->len + 16);
+		skb = netdev_alloc_skb(netdev, frame_hdr->len + 16);
 		if (likely(skb && (frame_hdr->sts & RXFSHR_RXFV) &&
 			(frame_hdr->len < RX_BUF_SIZE) && frame_hdr->len)) {
 			skb_reserve(skb, 2);
diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index e52cd31..04276c9 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -4863,7 +4863,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 				memset(&skb->data[skb->len], 0, 50 - skb->len);
 				skb->len = 50;
 			} else {
-				skb = dev_alloc_skb(50);
+				skb = netdev_alloc_skb(dev, 50);
 				if (!skb)
 					return NETDEV_TX_BUSY;
 				memcpy(skb->data, org_skb->data, org_skb->len);
@@ -4885,7 +4885,7 @@ static netdev_tx_t netdev_tx(struct sk_buff *skb, struct net_device *dev)
 				(ETH_P_IPV6 == htons(skb->protocol)))) {
 			struct sk_buff *org_skb = skb;
 
-			skb = dev_alloc_skb(org_skb->len);
+			skb = netdev_alloc_skb(dev, org_skb->len);
 			if (!skb) {
 				rc = NETDEV_TX_BUSY;
 				goto unlock;
@@ -5019,7 +5019,7 @@ static inline int rx_proc(struct net_device *dev, struct ksz_hw* hw,
 
 	do {
 		/* skb->data != skb->head */
-		skb = dev_alloc_skb(packet_len + 2);
+		skb = netdev_alloc_skb(dev, packet_len + 2);
 		if (!skb) {
 			dev->stats.rx_dropped++;
 			return -ENOMEM;
diff --git a/drivers/net/ethernet/microchip/enc28j60.c b/drivers/net/ethernet/microchip/enc28j60.c
index 50055e0..6e4fb24 100644
--- a/drivers/net/ethernet/microchip/enc28j60.c
+++ b/drivers/net/ethernet/microchip/enc28j60.c
@@ -954,7 +954,7 @@ static void enc28j60_hw_rx(struct net_device *ndev)
 		if (len > MAX_FRAMELEN)
 			ndev->stats.rx_over_errors++;
 	} else {
-		skb = dev_alloc_skb(len + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(ndev, len + NET_IP_ALIGN);
 		if (!skb) {
 			if (netif_msg_rx_err(priv))
 				dev_err(&ndev->dev,
diff --git a/drivers/net/ethernet/mipsnet.c b/drivers/net/ethernet/mipsnet.c
index d05b0c9..dbc666a 100644
--- a/drivers/net/ethernet/mipsnet.c
+++ b/drivers/net/ethernet/mipsnet.c
@@ -152,7 +152,7 @@ static inline ssize_t mipsnet_get_fromdev(struct net_device *dev, size_t len)
 	if (!len)
 		return len;
 
-	skb = dev_alloc_skb(len + NET_IP_ALIGN);
+	skb = netdev_alloc_skb(dev, len + NET_IP_ALIGN);
 	if (!skb) {
 		dev->stats.rx_dropped++;
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/natsemi/ibmlana.c b/drivers/net/ethernet/natsemi/ibmlana.c
index 999407f..3f94ddb 100644
--- a/drivers/net/ethernet/natsemi/ibmlana.c
+++ b/drivers/net/ethernet/natsemi/ibmlana.c
@@ -589,7 +589,7 @@ static void irqrx_handler(struct net_device *dev)
 
 			/* fetch buffer */
 
-			skb = dev_alloc_skb(rda.length + 2);
+			skb = netdev_alloc_skb(dev, rda.length + 2);
 			if (skb == NULL)
 				dev->stats.rx_dropped++;
 			else {
diff --git a/drivers/net/ethernet/natsemi/natsemi.c b/drivers/net/ethernet/natsemi/natsemi.c
index ac7b16b..dacb992 100644
--- a/drivers/net/ethernet/natsemi/natsemi.c
+++ b/drivers/net/ethernet/natsemi/natsemi.c
@@ -1934,7 +1934,7 @@ static void refill_rx(struct net_device *dev)
 		int entry = np->dirty_rx % RX_RING_SIZE;
 		if (np->rx_skbuff[entry] == NULL) {
 			unsigned int buflen = np->rx_buf_sz+NATSEMI_PADDING;
-			skb = dev_alloc_skb(buflen);
+			skb = netdev_alloc_skb(dev, buflen);
 			np->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break; /* Better luck next round. */
@@ -2344,7 +2344,7 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 			/* Check if the packet is long enough to accept
 			 * without copying to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + RX_OFFSET)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + RX_OFFSET)) != NULL) {
 				/* 16 byte align the IP header */
 				skb_reserve(skb, RX_OFFSET);
 				pci_dma_sync_single_for_cpu(np->pci_dev,
diff --git a/drivers/net/ethernet/natsemi/sonic.c b/drivers/net/ethernet/natsemi/sonic.c
index 26e25d7..0452e296 100644
--- a/drivers/net/ethernet/natsemi/sonic.c
+++ b/drivers/net/ethernet/natsemi/sonic.c
@@ -51,7 +51,7 @@ static int sonic_open(struct net_device *dev)
 		printk("sonic_open: initializing sonic driver.\n");
 
 	for (i = 0; i < SONIC_NUM_RRS; i++) {
-		struct sk_buff *skb = dev_alloc_skb(SONIC_RBSIZE + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, SONIC_RBSIZE + 2);
 		if (skb == NULL) {
 			while(i > 0) { /* free any that were allocated successfully */
 				i--;
@@ -422,7 +422,7 @@ static void sonic_rx(struct net_device *dev)
 		status = sonic_rda_get(dev, entry, SONIC_RD_STATUS);
 		if (status & SONIC_RCR_PRX) {
 			/* Malloc up new buffer. */
-			new_skb = dev_alloc_skb(SONIC_RBSIZE + 2);
+			new_skb = netdev_alloc_skb(SONIC_RBSIZE + 2);
 			if (new_skb == NULL) {
 				printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n", dev->name);
 				lp->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 97f63e1..4ef38ed 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -2524,7 +2524,7 @@ static int fill_rx_buffers(struct s2io_nic *nic, struct ring_info *ring,
 			size = ring->mtu + ALIGN_SIZE + BUF0_LEN + 4;
 
 		/* allocate skb */
-		skb = dev_alloc_skb(size);
+		skb = netdev_alloc_skb(nic->dev, size);
 		if (!skb) {
 			DBG_PRINT(INFO_DBG, "%s: Could not allocate skb\n",
 				  ring->dev->name);
@@ -6820,7 +6820,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			 */
 			rxdp1->Buffer0_ptr = *temp0;
 		} else {
-			*skb = dev_alloc_skb(size);
+			*skb = netdev_alloc_skb(dev, size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG,
 					  "%s: Out of memory to allocate %s\n",
@@ -6849,7 +6849,7 @@ static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t *rxdp,
 			rxdp3->Buffer0_ptr = *temp0;
 			rxdp3->Buffer1_ptr = *temp1;
 		} else {
-			*skb = dev_alloc_skb(size);
+			*skb = netdev_alloc_skb(dev, size);
 			if (!(*skb)) {
 				DBG_PRINT(INFO_DBG,
 					  "%s: Out of memory to allocate %s\n",
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 8d288af..0762d01 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -150,7 +150,7 @@ static void netx_eth_receive(struct net_device *ndev)
 	seg = (val & FIFO_PTR_SEGMENT_MASK) >> FIFO_PTR_SEGMENT_SHIFT;
 	len = (val & FIFO_PTR_FRAMELEN_MASK) >> FIFO_PTR_FRAMELEN_SHIFT;
 
-	skb = dev_alloc_skb(len);
+	skb = netdev_alloc_skb(ndev, len);
 	if (unlikely(skb == NULL)) {
 		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 			ndev->name);
diff --git a/drivers/net/ethernet/nuvoton/w90p910_ether.c b/drivers/net/ethernet/nuvoton/w90p910_ether.c
index b75a049..6893a65 100644
--- a/drivers/net/ethernet/nuvoton/w90p910_ether.c
+++ b/drivers/net/ethernet/nuvoton/w90p910_ether.c
@@ -735,7 +735,7 @@ static void netdev_rx(struct net_device *dev)
 
 		if (status & RXDS_RXGD) {
 			data = ether->rdesc->recv_buf[ether->cur_rx];
-			skb = dev_alloc_skb(length+2);
+			skb = netdev_alloc_skb(dev, length + 2);
 			if (!skb) {
 				dev_err(&pdev->dev, "get skb buffer error\n");
 				ether->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 4c4e7f4..accb55d 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1815,7 +1815,8 @@ static int nv_alloc_rx(struct net_device *dev)
 		less_rx = np->last_rx.orig;
 
 	while (np->put_rx.orig != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -1850,7 +1851,8 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 		less_rx = np->last_rx.ex;
 
 	while (np->put_rx.ex != less_rx) {
-		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		struct sk_buff *skb =
+			netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
@@ -4993,9 +4995,9 @@ static int nv_loopback_test(struct net_device *dev)
 
 	/* setup packet for tx */
 	pkt_len = ETH_DATA_LEN;
-	tx_skb = dev_alloc_skb(pkt_len);
+	tx_skb = netdev_alloc_skb(dev, pkt_len);
 	if (!tx_skb) {
-		netdev_err(dev, "dev_alloc_skb() failed during loopback test\n");
+		netdev_err(dev, "netdev_alloc_skb() failed during loopback test\n");
 		ret = 0;
 		goto out;
 	}
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 3458df3..ccb5443 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1188,7 +1188,7 @@ static void hamachi_init_ring(struct net_device *dev)
 	}
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, hmp->rx_buf_sz + 2);
 		hmp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1488,7 +1488,8 @@ static int hamachi_rx(struct net_device *dev)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2))
+			    != NULL) {
 #ifdef RX_CHECKSUM
 				printk(KERN_ERR "%s: rx_copybreak non-zero "
 				  "not good with RX_CHECKSUM\n", dev->name);
@@ -1591,7 +1592,8 @@ static int hamachi_rx(struct net_device *dev)
 		entry = hmp->dirty_rx % RX_RING_SIZE;
 		desc = &(hmp->rx_ring[entry]);
 		if (hmp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(hmp->rx_buf_sz + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev,
+					hmp->rx_buf_sz + 2);
 
 			hmp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
diff --git a/drivers/net/ethernet/packetengines/yellowfin.c b/drivers/net/ethernet/packetengines/yellowfin.c
index db44e9a..5b1cc37 100644
--- a/drivers/net/ethernet/packetengines/yellowfin.c
+++ b/drivers/net/ethernet/packetengines/yellowfin.c
@@ -744,7 +744,7 @@ static int yellowfin_init_ring(struct net_device *dev)
 	}
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, yp->rx_buf_sz + 2);
 		yp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1134,7 +1134,7 @@ static int yellowfin_rx(struct net_device *dev)
 					PCI_DMA_FROMDEVICE);
 				yp->rx_skbuff[entry] = NULL;
 			} else {
-				skb = dev_alloc_skb(pkt_len + 2);
+				skb = netdev_alloc_skb(dev, pkt_len + 2);
 				if (skb == NULL)
 					break;
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
@@ -1157,7 +1157,8 @@ static int yellowfin_rx(struct net_device *dev)
 	for (; yp->cur_rx - yp->dirty_rx > 0; yp->dirty_rx++) {
 		entry = yp->dirty_rx % RX_RING_SIZE;
 		if (yp->rx_skbuff[entry] == NULL) {
-			struct sk_buff *skb = dev_alloc_skb(yp->rx_buf_sz + 2);
+			struct sk_buff *skb = netdev_alloc_skb(dev,
+					yp->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;				/* Better luck next round. */
 			yp->rx_skbuff[entry] = skb;
diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/ethernet/pasemi/pasemi_mac.c
index 49b549f..148de79 100644
--- a/drivers/net/ethernet/pasemi/pasemi_mac.c
+++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
@@ -643,7 +643,7 @@ static void pasemi_mac_replenish_rx_ring(const struct net_device *dev,
 		/* Entry in use? */
 		WARN_ON(*buff);
 
-		skb = dev_alloc_skb(mac->bufsz);
+		skb = netdev_alloc_skb(dev, mac->bufsz);
 		skb_reserve(skb, LOCAL_SKB_ALIGN);
 
 		if (unlikely(!skb))
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index a8259cc..df36b48 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1494,7 +1494,7 @@ netxen_alloc_rx_skb(struct netxen_adapter *adapter,
 	dma_addr_t dma;
 	struct pci_dev *pdev = adapter->pdev;
 
-	buffer->skb = dev_alloc_skb(rds_ring->skb_size);
+	buffer->skb = netdev_alloc_skb(adapter->netdev, rds_ring->skb_size);
 	if (!buffer->skb)
 		return 1;
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index cc228cf..8395d63 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -722,7 +722,7 @@ static int qlcnic_do_lb_test(struct qlcnic_adapter *adapter, u8 mode)
 	int i, loop, cnt = 0;
 
 	for (i = 0; i < QLCNIC_NUM_ILB_PKT; i++) {
-		skb = dev_alloc_skb(QLCNIC_ILB_PKT_SIZE);
+		skb = netdev_alloc_skb(adapter->netdev, QLCNIC_ILB_PKT_SIZE);
 		qlcnic_create_loopback_buff(skb->data, adapter->mac_addr);
 		skb_put(skb, QLCNIC_ILB_PKT_SIZE);
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index 3866958..b019f59 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -1434,7 +1434,7 @@ qlcnic_alloc_rx_skb(struct qlcnic_adapter *adapter,
 	dma_addr_t dma;
 	struct pci_dev *pdev = adapter->pdev;
 
-	skb = dev_alloc_skb(rds_ring->skb_size);
+	skb = netdev_alloc_skb(adapter->netdev, rds_ring->skb_size);
 	if (!skb) {
 		adapter->stats.skb_alloc_failure++;
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/racal/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
index 072810d..8079822 100644
--- a/drivers/net/ethernet/racal/ni5010.c
+++ b/drivers/net/ethernet/racal/ni5010.c
@@ -552,7 +552,7 @@ static void ni5010_rx(struct net_device *dev)
 	}
 
 	/* Malloc up new buffer. */
-	skb = dev_alloc_skb(i_pkt_size + 3);
+	skb = netdev_alloc_skb(dev, i_pkt_size + 3);
 	if (skb == NULL) {
 		printk(KERN_WARNING "%s: Memory squeeze, dropping packet.\n", dev->name);
 		dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/realtek/atp.c b/drivers/net/ethernet/realtek/atp.c
index e3f57fd..46c1932 100644
--- a/drivers/net/ethernet/realtek/atp.c
+++ b/drivers/net/ethernet/realtek/atp.c
@@ -783,7 +783,7 @@ static void net_rx(struct net_device *dev)
 		int pkt_len = (rx_head.rx_count & 0x7ff) - 4;
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_len + 2);
+		skb = netdev_alloc_skb(dev, pkt_len + 2);
 		if (skb == NULL) {
 			printk(KERN_ERR "%s: Memory squeeze, dropping packet.\n",
 				   dev->name);
diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 813d41c..6d38e65 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -653,7 +653,7 @@ static void sh_eth_ring_format(struct net_device *ndev)
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		/* skb */
 		mdp->rx_skbuff[i] = NULL;
-		skb = dev_alloc_skb(mdp->rx_buf_sz);
+		skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
 		mdp->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -953,7 +953,7 @@ static int sh_eth_rx(struct net_device *ndev)
 		rxdesc->buffer_length = ALIGN(mdp->rx_buf_sz, 16);
 
 		if (mdp->rx_skbuff[entry] == NULL) {
-			skb = dev_alloc_skb(mdp->rx_buf_sz);
+			skb = netdev_alloc_skb(ndev, mdp->rx_buf_sz);
 			mdp->rx_skbuff[entry] = skb;
 			if (skb == NULL)
 				break;	/* Better luck next round. */
diff --git a/drivers/net/ethernet/s6gmac.c b/drivers/net/ethernet/s6gmac.c
index 22e9c01..5037a12 100644
--- a/drivers/net/ethernet/s6gmac.c
+++ b/drivers/net/ethernet/s6gmac.c
@@ -370,12 +370,13 @@ struct s6gmac {
 	} link;
 };
 
-static void s6gmac_rx_fillfifo(struct s6gmac *pd)
+static void s6gmac_rx_fillfifo(struct net_device *dev)
 {
+	struct s6gmac *pd = netdev_priv(dev);
 	struct sk_buff *skb;
 	while ((((u8)(pd->rx_skb_i - pd->rx_skb_o)) < S6_NUM_RX_SKB) &&
 	       (!s6dmac_fifo_full(pd->rx_dma, pd->rx_chan)) &&
-	       (skb = dev_alloc_skb(S6_MAX_FRLEN + 2))) {
+	       (skb = netdev_alloc_skb(dev, S6_MAX_FRLEN + 2))) {
 		pd->rx_skb[(pd->rx_skb_i++) % S6_NUM_RX_SKB] = skb;
 		s6dmac_put_fifo_cache(pd->rx_dma, pd->rx_chan,
 			pd->io, (u32)skb->data, S6_MAX_FRLEN);
@@ -514,7 +515,7 @@ static irqreturn_t s6gmac_interrupt(int irq, void *dev_id)
 	spin_lock(&pd->lock);
 	if (s6dmac_termcnt_irq(pd->rx_dma, pd->rx_chan))
 		s6gmac_rx_interrupt(dev);
-	s6gmac_rx_fillfifo(pd);
+	s6gmac_rx_fillfifo(dev);
 	if (s6dmac_termcnt_irq(pd->tx_dma, pd->tx_chan))
 		s6gmac_tx_interrupt(dev);
 	s6gmac_stats_interrupt(pd, 0);
@@ -894,7 +895,7 @@ static int s6gmac_open(struct net_device *dev)
 	s6gmac_init_device(dev);
 	s6gmac_init_stats(dev);
 	s6gmac_init_dmac(dev);
-	s6gmac_rx_fillfifo(pd);
+	s6gmac_rx_fillfifo(dev);
 	s6dmac_enable_chan(pd->rx_dma, pd->rx_chan,
 		2, 1, 0, 1, 0, 0, 0, 7, -1, 2, 0, 1);
 	s6dmac_enable_chan(pd->tx_dma, pd->tx_chan,
diff --git a/drivers/net/ethernet/seeq/ether3.c b/drivers/net/ethernet/seeq/ether3.c
index 893c880..7b819bd 100644
--- a/drivers/net/ethernet/seeq/ether3.c
+++ b/drivers/net/ethernet/seeq/ether3.c
@@ -643,7 +643,7 @@ if (next_ptr < RX_START || next_ptr >= RX_END) {
 			if (next_ptr <= this_ptr)
 				length += RX_END - RX_START;
 
-			skb = dev_alloc_skb(length + 2);
+			skb = netdev_alloc_skb(dev, length + 2);
 			if (skb) {
 				unsigned char *buf;
 
diff --git a/drivers/net/ethernet/seeq/seeq8005.c b/drivers/net/ethernet/seeq/seeq8005.c
index 6056145..7989907 100644
--- a/drivers/net/ethernet/seeq/seeq8005.c
+++ b/drivers/net/ethernet/seeq/seeq8005.c
@@ -548,7 +548,7 @@ static void seeq8005_rx(struct net_device *dev)
 			struct sk_buff *skb;
 			unsigned char *buf;
 
-			skb = dev_alloc_skb(pkt_len);
+			skb = netdev_alloc_skb(dev, pkt_len);
 			if (skb == NULL) {
 				printk("%s: Memory squeeze, dropping packet.\n", dev->name);
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index c8efc70..5c2f9bd 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -1165,9 +1165,9 @@ sis900_init_rx_ring(struct net_device *net_dev)
 
 	/* allocate sock buffers */
 	for (i = 0; i < NUM_RX_DESC; i++) {
-		struct sk_buff *skb;
+		struct sk_buff *skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
 
-		if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+		if (skb == NULL) {
 			/* not enough memory for skbuff, this makes a "hole"
 			   on the buffer ring, it is not clear how the
 			   hardware will react to this kind of degenerated
@@ -1770,7 +1770,8 @@ static int sis900_rx(struct net_device *net_dev)
 
 			/* refill the Rx buffer, what if there is not enough
 			 * memory for new socket buffer ?? */
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+			skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
+			if (skb == NULL) {
 				/*
 				 * Not enough memory to refill the buffer
 				 * so we need to recycle the old one so
@@ -1828,7 +1829,8 @@ refill_rx_ring:
 		entry = sis_priv->dirty_rx % NUM_RX_DESC;
 
 		if (sis_priv->rx_skbuff[entry] == NULL) {
-			if ((skb = dev_alloc_skb(RX_BUF_SIZE)) == NULL) {
+			skb = netdev_alloc_skb(net_dev, RX_BUF_SIZE);
+			if (skb == NULL) {
 				/* not enough memory for skbuff, this makes a
 				 * "hole" on the buffer ring, it is not clear
 				 * how the hardware will react to this kind
diff --git a/drivers/net/ethernet/smsc/epic100.c b/drivers/net/ethernet/smsc/epic100.c
index 2c077ce..9ea580a 100644
--- a/drivers/net/ethernet/smsc/epic100.c
+++ b/drivers/net/ethernet/smsc/epic100.c
@@ -935,7 +935,7 @@ static void epic_init_ring(struct net_device *dev)
 
 	/* Fill in the Rx buffers.  Handle allocation failure gracefully. */
 	for (i = 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb = dev_alloc_skb(ep->rx_buf_sz + 2);
+		struct sk_buff *skb = netdev_alloc_skb(dev, ep->rx_buf_sz + 2);
 		ep->rx_skbuff[i] = skb;
 		if (skb == NULL)
 			break;
@@ -1200,7 +1200,7 @@ static int epic_rx(struct net_device *dev, int budget)
 			/* Check if the packet is long enough to accept without copying
 			   to a minimally-sized skbuff. */
 			if (pkt_len < rx_copybreak &&
-			    (skb = dev_alloc_skb(pkt_len + 2)) != NULL) {
+			    (skb = netdev_alloc_skb(dev, pkt_len + 2)) != NULL) {
 				skb_reserve(skb, 2);	/* 16 byte align the IP header */
 				pci_dma_sync_single_for_cpu(ep->pci_dev,
 							    ep->rx_ring[entry].bufaddr,
@@ -1233,7 +1233,8 @@ static int epic_rx(struct net_device *dev, int budget)
 		entry = ep->dirty_rx % RX_RING_SIZE;
 		if (ep->rx_skbuff[entry] == NULL) {
 			struct sk_buff *skb;
-			skb = ep->rx_skbuff[entry] = dev_alloc_skb(ep->rx_buf_sz + 2);
+			skb = ep->rx_skbuff[entry] = netdev_alloc_skb(dev,
+					ep->rx_buf_sz + 2);
 			if (skb == NULL)
 				break;
 			skb_reserve(skb, 2);	/* Align IP on 16 byte boundaries */
diff --git a/drivers/net/ethernet/smsc/smc911x.c b/drivers/net/ethernet/smsc/smc911x.c
index 313ba3b..4b4ece1 100644
--- a/drivers/net/ethernet/smsc/smc911x.c
+++ b/drivers/net/ethernet/smsc/smc911x.c
@@ -401,7 +401,7 @@ static inline void	 smc911x_rcv(struct net_device *dev)
 	} else {
 		/* Receive a valid packet */
 		/* Alloc a buffer with extra room for DMA alignment */
-		skb=dev_alloc_skb(pkt_len+32);
+		skb = netdev_alloc_skb(dev, pkt_len + 32);
 		if (unlikely(skb == NULL)) {
 			PRINTK( "%s: Low memory, rcvd packet dropped.\n",
 				dev->name);
diff --git a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
index 4e45094..50823da 100644
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1222,7 +1222,7 @@ static void smc_rcv(struct net_device *dev)
 		if ( status & RS_MULTICAST )
 			dev->stats.multicast++;
 
-		skb = dev_alloc_skb( packet_length + 5);
+		skb = netdev_alloc_skb(dev, packet_length + 5);
 
 		if ( skb == NULL ) {
 			printk(KERN_NOTICE CARDNAME ": Low memory, packet dropped.\n");
diff --git a/drivers/net/ethernet/smsc/smc91c92_cs.c b/drivers/net/ethernet/smsc/smc91c92_cs.c
index ada927a..d6bc8e9 100644
--- a/drivers/net/ethernet/smsc/smc91c92_cs.c
+++ b/drivers/net/ethernet/smsc/smc91c92_cs.c
@@ -1500,7 +1500,7 @@ static void smc_rx(struct net_device *dev)
 	struct sk_buff *skb;
 	
 	/* Note: packet_length adds 5 or 6 extra bytes here! */
-	skb = dev_alloc_skb(packet_length+2);
+	skb = netdev_alloc_skb(dev, packet_length + 2);
 	
 	if (skb == NULL) {
 	    pr_debug("%s: Low memory, packet dropped.\n", dev->name);
diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 64ad3ed..3c86ddd 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -463,7 +463,7 @@ static inline void  smc_rcv(struct net_device *dev)
 		 * multiple of 4 bytes on 32 bit buses.
 		 * Hence packet_len - 6 + 2 + 2 + 2.
 		 */
-		skb = dev_alloc_skb(packet_len);
+		skb = netdev_alloc_skb(dev, packet_len);
 		if (unlikely(skb == NULL)) {
 			printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 				dev->name);
diff --git a/drivers/net/ethernet/sun/cassini.c b/drivers/net/ethernet/sun/cassini.c
index f10665f..6ad5265 100644
--- a/drivers/net/ethernet/sun/cassini.c
+++ b/drivers/net/ethernet/sun/cassini.c
@@ -1975,7 +1975,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 	else
 		alloclen = max(hlen, RX_COPY_MIN);
 
-	skb = dev_alloc_skb(alloclen + swivel + cp->crc_size);
+	skb = netdev_alloc_skb(cp->dev, alloclen + swivel + cp->crc_size);
 	if (skb == NULL)
 		return -1;
 
diff --git a/drivers/net/ethernet/sun/sunbmac.c b/drivers/net/ethernet/sun/sunbmac.c
index 220f724..79d71bc 100644
--- a/drivers/net/ethernet/sun/sunbmac.c
+++ b/drivers/net/ethernet/sun/sunbmac.c
@@ -853,7 +853,8 @@ static void bigmac_rx(struct bigmac *bp)
 			/* Trim the original skb for the netif. */
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =
+				netdev_alloc_skb(bp->dev, len + 2);
 
 			if (copy_skb == NULL) {
 				drops++;
diff --git a/drivers/net/ethernet/sun/sunhme.c b/drivers/net/ethernet/sun/sunhme.c
index 09c5186..d49b558 100644
--- a/drivers/net/ethernet/sun/sunhme.c
+++ b/drivers/net/ethernet/sun/sunhme.c
@@ -2043,7 +2043,8 @@ static void happy_meal_rx(struct happy_meal *hp, struct net_device *dev)
 			/* Trim the original skb for the netif. */
 			skb_trim(skb, len);
 		} else {
-			struct sk_buff *copy_skb = dev_alloc_skb(len + 2);
+			struct sk_buff *copy_skb =
+				netdev_alloc_skb(dev, len + 2);
 
 			if (copy_skb == NULL) {
 				drops++;
diff --git a/drivers/net/ethernet/sun/sunqe.c b/drivers/net/ethernet/sun/sunqe.c
index b28f743..b42d1c5 100644
--- a/drivers/net/ethernet/sun/sunqe.c
+++ b/drivers/net/ethernet/sun/sunqe.c
@@ -435,7 +435,7 @@ static void qe_rx(struct sunqe *qep)
 			dev->stats.rx_length_errors++;
 			dev->stats.rx_dropped++;
 		} else {
-			skb = dev_alloc_skb(len + 2);
+			skb = netdev_alloc_skb(dev, len + 2);
 			if (skb == NULL) {
 				drops++;
 				dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/tehuti/tehuti.c b/drivers/net/ethernet/tehuti/tehuti.c
index 4b19e9b..76c228c 100644
--- a/drivers/net/ethernet/tehuti/tehuti.c
+++ b/drivers/net/ethernet/tehuti/tehuti.c
@@ -1089,9 +1089,9 @@ static void bdx_rx_alloc_skbs(struct bdx_priv *priv, struct rxf_fifo *f)
 	ENTER;
 	dno = bdx_rxdb_available(db) - 1;
 	while (dno > 0) {
-		skb = dev_alloc_skb(f->m.pktsz + NET_IP_ALIGN);
+		skb = netdev_alloc_skb(priv->ndev, f->m.pktsz + NET_IP_ALIGN);
 		if (!skb) {
-			pr_err("NO MEM: dev_alloc_skb failed\n");
+			pr_err("NO MEM: netdev_alloc_skb failed\n");
 			break;
 		}
 		skb->dev = priv->ndev;
@@ -1258,7 +1258,7 @@ static int bdx_rx_receive(struct bdx_priv *priv, struct rxd_fifo *f, int budget)
 		skb = dm->skb;
 
 		if (len < BDX_COPYBREAK &&
-		    (skb2 = dev_alloc_skb(len + NET_IP_ALIGN))) {
+		    (skb2 = netdev_alloc_skb(priv->ndev, len + NET_IP_ALIGN))) {
 			skb_reserve(skb2, NET_IP_ALIGN);
 			/*skb_put(skb2, len); */
 			pci_dma_sync_single_for_cpu(priv->pdev,
diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 794ac30..0981852 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -992,7 +992,7 @@ static irqreturn_t emac_irq(int irq, void *dev_id)
 
 static struct sk_buff *emac_rx_alloc(struct emac_priv *priv)
 {
-	struct sk_buff *skb = dev_alloc_skb(priv->rx_buf_size);
+	struct sk_buff *skb = netdev_alloc_skb(priv->ndev, priv->rx_buf_size);
 	if (WARN_ON(!skb))
 		return NULL;
 	skb->dev = priv->ndev;
diff --git a/drivers/net/ethernet/tile/tilepro.c b/drivers/net/ethernet/tile/tilepro.c
index d9951af..a8e5daa 100644
--- a/drivers/net/ethernet/tile/tilepro.c
+++ b/drivers/net/ethernet/tile/tilepro.c
@@ -419,7 +419,7 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 #endif
 
 	/* Avoid "false sharing" with last cache line. */
-	/* ISSUE: This is already done by "dev_alloc_skb()". */
+	/* ISSUE: This is already done by "netdev_alloc_skb()". */
 	unsigned int len =
 		 (((small ? LIPP_SMALL_PACKET_SIZE : large_size) +
 		   CHIP_L2_LINE_SIZE() - 1) & -CHIP_L2_LINE_SIZE());
@@ -433,7 +433,7 @@ static bool tile_net_provide_needed_buffer(struct tile_net_cpu *info,
 	struct sk_buff **skb_ptr;
 
 	/* Request 96 extra bytes for alignment purposes. */
-	skb = dev_alloc_skb(len + padding);
+	skb = netdev_alloc_skb(info->napi->dev, len + padding);
 	if (skb == NULL)
 		return false;
 
diff --git a/drivers/net/ethernet/toshiba/tc35815.c b/drivers/net/ethernet/toshiba/tc35815.c
index 71b785c..73c1d26 100644
--- a/drivers/net/ethernet/toshiba/tc35815.c
+++ b/drivers/net/ethernet/toshiba/tc35815.c
@@ -453,7 +453,7 @@ static struct sk_buff *alloc_rxbuf_skb(struct net_device *dev,
 				       dma_addr_t *dma_handle)
 {
 	struct sk_buff *skb;
-	skb = dev_alloc_skb(RX_BUF_SIZE);
+	skb = netdev_alloc_skb(dev, RX_BUF_SIZE);
 	if (!skb)
 		return NULL;
 	*dma_handle = pci_map_single(hwdev, skb->data, RX_BUF_SIZE,
diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 4128d6b..b0a260d 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -1509,7 +1509,7 @@ static int velocity_alloc_rx_buf(struct velocity_info *vptr, int idx)
 	struct rx_desc *rd = &(vptr->rx.ring[idx]);
 	struct velocity_rd_info *rd_info = &(vptr->rx.info[idx]);
 
-	rd_info->skb = dev_alloc_skb(vptr->rx.buf_sz + 64);
+	rd_info->skb = netdev_alloc_skb(vptr->dev, vptr->rx.buf_sz + 64);
 	if (rd_info->skb == NULL)
 		return -ENOMEM;
 
diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
index 79013e5..441088f 100644
--- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
+++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
@@ -613,7 +613,7 @@ static void xemaclite_rx_handler(struct net_device *dev)
 	u32 len;
 
 	len = ETH_FRAME_LEN + ETH_FCS_LEN;
-	skb = dev_alloc_skb(len + ALIGNMENT);
+	skb = netdev_alloc_skb(dev, len + ALIGNMENT);
 	if (!skb) {
 		/* Couldn't get memory. */
 		dev->stats.rx_dropped++;
diff --git a/drivers/net/ethernet/xircom/xirc2ps_cs.c b/drivers/net/ethernet/xircom/xirc2ps_cs.c
index 33979c3..5ae54c3 100644
--- a/drivers/net/ethernet/xircom/xirc2ps_cs.c
+++ b/drivers/net/ethernet/xircom/xirc2ps_cs.c
@@ -1039,7 +1039,8 @@ xirc2ps_interrupt(int irq, void *dev_id)
 
 	    pr_debug("rsr=%#02x packet_length=%u\n", rsr, pktlen);
 
-	    skb = dev_alloc_skb(pktlen+3); /* 1 extra so we can use insw */
+		/* 1 extra so we can use insw */
+		skb = netdev_alloc_skb(dev, pktlen + 3);
 	    if (!skb) {
 		pr_notice("low memory, packet dropped (size=%u)\n", pktlen);
 		dev->stats.rx_dropped++;
