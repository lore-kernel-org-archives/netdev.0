From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts (others)
Date: Sun, 29 Feb 2004 15:02:50 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229150250.26de9ef3.rddunlap@osdl.org>
References: <20040229142516.3d218ed0.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik <jgarzik@pobox.com>
In-Reply-To: <20040229142516.3d218ed0.rddunlap@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: Carlo Perassi <carlo@linux.it>


 drivers/net/amd8111e.c     |    8 ++++----
 drivers/net/ariadne.c      |   10 +++++-----
 drivers/net/at1700.c       |   12 ++++++------
 drivers/net/atari_bionet.c |   12 ++++++------
 drivers/net/atp.c          |   20 ++++++++++----------
 drivers/net/bmac.c         |    2 +-
 drivers/net/cs89x0.c       |   34 +++++++++++++++++-----------------
 drivers/net/eth16i.c       |   14 +++++++-------
 drivers/net/fec.c          |    2 +-
 drivers/net/gt96100eth.c   |   40 ++++++++++++++++++++--------------------
 drivers/net/mac89x0.c      |   10 +++++-----
 drivers/net/ni5010.c       |    8 ++++----
 drivers/net/rrunner.c      |    8 ++++----
 drivers/net/sb1000.c       |   14 +++++++-------
 drivers/net/sb1250-mac.c   |   14 +++++++-------
 drivers/net/seeq8005.c     |   12 ++++++------
 drivers/net/sgiseeq.c      |    2 +-
 drivers/net/sk_g16.c       |    2 +-
 drivers/net/smc9194.c      |   12 ++++++------
 19 files changed, 118 insertions(+), 118 deletions(-)

diff -puN drivers/net/amd8111e.c~drivers_net_casts drivers/net/amd8111e.c
--- linux-263-229/drivers/net/amd8111e.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/amd8111e.c	2004-02-29 14:03:33.000000000 -0800
@@ -197,7 +197,7 @@ This function will set PHY speed. During
 */
 static void amd8111e_set_ext_phy(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = dev->priv;
 	u32 bmcr,advert,tmp;
 	
 	/* Determine mii register values to set the speed */
@@ -239,7 +239,7 @@ all transmit and receive skbuffs.
 */
 static int amd8111e_free_skbs(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = dev->priv;
 	struct sk_buff* rx_skbuff;
 	int i;
 
@@ -290,7 +290,7 @@ This function will free all the previous
  */
 static int amd8111e_init_ring(struct net_device *dev)
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = dev->priv;
 	int i;
 
 	lp->rx_idx = lp->tx_idx = 0;
@@ -1185,7 +1185,7 @@ static int amd8111e_close(struct net_dev
 */
 static int amd8111e_open(struct net_device * dev )
 {
-	struct amd8111e_priv *lp = (struct amd8111e_priv *)dev->priv;
+	struct amd8111e_priv *lp = dev->priv;
 
 	if(dev->irq ==0 || request_irq(dev->irq, amd8111e_interrupt, SA_SHIRQ,
 					 dev->name, dev)) 
diff -puN drivers/net/ariadne.c~drivers_net_casts drivers/net/ariadne.c
--- linux-263-229/drivers/net/ariadne.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/ariadne.c	2004-02-29 14:03:33.000000000 -0800
@@ -333,7 +333,7 @@ static int ariadne_open(struct net_devic
 
 static void ariadne_init_ring(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = dev->priv;
     volatile struct lancedata *lancedata = (struct lancedata *)dev->mem_start;
     int i;
 
@@ -379,7 +379,7 @@ static void ariadne_init_ring(struct net
 
 static int ariadne_close(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = dev->priv;
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
 
     netif_stop_queue(dev);
@@ -589,7 +589,7 @@ static void ariadne_tx_timeout(struct ne
 
 static int ariadne_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = dev->priv;
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
     int entry;
     unsigned long flags;
@@ -697,7 +697,7 @@ static int ariadne_start_xmit(struct sk_
 
 static int ariadne_rx(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = dev->priv;
     int entry = priv->cur_rx % RX_RING_SIZE;
     int i;
 
@@ -787,7 +787,7 @@ static int ariadne_rx(struct net_device 
 
 static struct net_device_stats *ariadne_get_stats(struct net_device *dev)
 {
-    struct ariadne_private *priv = (struct ariadne_private *)dev->priv;
+    struct ariadne_private *priv = dev->priv;
     volatile struct Am79C960 *lance = (struct Am79C960*)dev->base_addr;
     short saved_addr;
     unsigned long flags;
diff -puN drivers/net/at1700.c~drivers_net_casts drivers/net/at1700.c
--- linux-263-229/drivers/net/at1700.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/at1700.c	2004-02-29 14:03:33.000000000 -0800
@@ -618,7 +618,7 @@ static int __init read_eeprom(long ioadd
 
 static int net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* Set the configuration register 0 to 32K 100ns. byte-wide memory, 16 bit
@@ -649,7 +649,7 @@ static int net_open(struct net_device *d
 
 static void net_tx_timeout (struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	printk ("%s: transmit timed out with status %04x, %s?\n", dev->name,
@@ -808,7 +808,7 @@ net_interrupt(int irq, void *dev_id, str
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int boguscount = 5;
 
@@ -891,7 +891,7 @@ net_rx(struct net_device *dev)
 /* The inverse routine to net_open(). */
 static int net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -919,7 +919,7 @@ static int net_close(struct net_device *
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
@@ -931,7 +931,7 @@ static void
 set_rx_mode(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	unsigned long flags;
 	int i;
diff -puN drivers/net/atari_bionet.c~drivers_net_casts drivers/net/atari_bionet.c
--- linux-263-229/drivers/net/atari_bionet.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/atari_bionet.c	2004-02-29 14:03:33.000000000 -0800
@@ -408,7 +408,7 @@ struct net_device * __init bionet_probe(
  */
 static int
 bionet_open(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (bionet_debug > 0)
 		printk("bionet_open\n");
@@ -433,7 +433,7 @@ bionet_open(struct net_device *dev) {
 
 static int
 bionet_send_packet(struct sk_buff *skb, struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	/* Block a timer-based transmit from overlapping.  This could better be
@@ -499,7 +499,7 @@ bionet_send_packet(struct sk_buff *skb, 
  */
 static void
 bionet_poll_rx(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int boguscount = 10;
 	int pkt_len, status;
 	unsigned long flags;
@@ -601,7 +601,7 @@ bionet_poll_rx(struct net_device *dev) {
 static void
 bionet_tick(unsigned long data) {
 	struct net_device	 *dev = (struct net_device *)data;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if( bionet_debug > 0 && (lp->open_time++ & 7) == 8 )
 		printk("bionet_tick: %ld\n", lp->open_time);
@@ -616,7 +616,7 @@ bionet_tick(unsigned long data) {
  */
 static int
 bionet_close(struct net_device *dev) {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (bionet_debug > 0)
 		printk("bionet_close, open_time=%ld\n", lp->open_time);
@@ -638,7 +638,7 @@ bionet_close(struct net_device *dev) {
  */
 static struct net_device_stats *net_get_stats(struct net_device *dev) 
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/atp.c~drivers_net_casts drivers/net/atp.c
--- linux-263-229/drivers/net/atp.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/atp.c	2004-02-29 14:03:33.000000000 -0800
@@ -432,7 +432,7 @@ static unsigned short __init eeprom_op(l
    */
 static int net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ret;
 
 	/* The interrupt line is turned off (tri-stated) when the device isn't in
@@ -458,7 +458,7 @@ static int net_open(struct net_device *d
    the hardware may have been temporarily detached. */
 static void hardware_init(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
     int i;
 
@@ -541,7 +541,7 @@ static void write_packet(long ioaddr, in
 
 static void tx_timeout(struct net_device *dev)
 {
-	struct net_local *np = (struct net_local *)dev->priv;
+	struct net_local *np = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_WARNING "%s: Transmit timed out, %s?\n", dev->name,
@@ -557,7 +557,7 @@ static void tx_timeout(struct net_device
 
 static int atp_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int length;
 	unsigned long flags;
@@ -726,7 +726,7 @@ static void atp_timed_checker(unsigned l
 {
 	struct net_device *dev = (struct net_device *)data;
 	long ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int tickssofar = jiffies - lp->last_rx_time;
 	int i;
 
@@ -762,7 +762,7 @@ static void atp_timed_checker(unsigned l
 /* We have a good packet(s), get it/them out of the buffers. */
 static void net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
 	struct rx_header rx_head;
 
@@ -838,7 +838,7 @@ static void read_block(long ioaddr, int 
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -863,7 +863,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
@@ -873,7 +873,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_rx_mode_8002(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	if ( dev->mc_count > 0 || (dev->flags & (IFF_ALLMULTI|IFF_PROMISC))) {
@@ -890,7 +890,7 @@ static void set_rx_mode_8002(struct net_
 
 static void set_rx_mode_8012(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	long ioaddr = dev->base_addr;
 	unsigned char new_mode, mc_filter[8]; /* Multicast hash filter */
 	int i;
diff -puN drivers/net/bmac.c~drivers_net_casts drivers/net/bmac.c
--- linux-263-229/drivers/net/bmac.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/bmac.c	2004-02-29 14:03:33.000000000 -0800
@@ -1086,7 +1086,7 @@ static int miscintcount;
 static irqreturn_t bmac_misc_intr(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct bmac_data *bp = (struct bmac_data *)dev->priv;
+	struct bmac_data *bp = dev->priv;
 	unsigned int status = bmread(dev, STATUS);
 	if (miscintcount++ < 10) {
 		XXDEBUG(("bmac_misc_intr\n"));
diff -puN drivers/net/cs89x0.c~drivers_net_casts drivers/net/cs89x0.c
--- linux-263-229/drivers/net/cs89x0.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/cs89x0.c	2004-02-29 14:03:33.000000000 -0800
@@ -735,7 +735,7 @@ out1:
 static void
 get_dma_channel(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (lp->dma) {
 		dev->dma = lp->dma;
@@ -757,7 +757,7 @@ get_dma_channel(struct net_device *dev)
 static void
 write_dma(struct net_device *dev, int chip_type, int dma)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	if ((lp->isa_config & ANY_ISA_DMA) == 0)
 		return;
 	if (chip_type == CS8900) {
@@ -770,7 +770,7 @@ write_dma(struct net_device *dev, int ch
 static void
 set_dma_cfg(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (lp->use_dma) {
 		if ((lp->isa_config & ANY_ISA_DMA) == 0) {
@@ -793,7 +793,7 @@ set_dma_cfg(struct net_device *dev)
 static int
 dma_bufcfg(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	if (lp->use_dma)
 		return (lp->isa_config & ANY_ISA_DMA)? RX_DMA_ENBL : 0;
 	else
@@ -804,7 +804,7 @@ static int
 dma_busctl(struct net_device *dev)
 {
 	int retval = 0;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	if (lp->use_dma) {
 		if (lp->isa_config & ANY_ISA_DMA)
 			retval |= RESET_RX_DMA; /* Reset the DMA pointer */
@@ -820,7 +820,7 @@ dma_busctl(struct net_device *dev)
 static void
 dma_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	struct sk_buff *skb;
 	int status, length;
 	unsigned char *bp = lp->rx_dma_ptr;
@@ -882,7 +882,7 @@ skip_this_frame:
 
 void  __init reset_chip(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int reset_start_time;
 
@@ -912,7 +912,7 @@ void  __init reset_chip(struct net_devic
 static void
 control_dc_dc(struct net_device *dev, int on_not_off)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned int selfcontrol;
 	int timenow = jiffies;
 	/* control the DC to DC convertor in the SelfControl register.  
@@ -940,7 +940,7 @@ control_dc_dc(struct net_device *dev, in
 static int
 detect_tp(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int timenow = jiffies;
 	int fdx;
 
@@ -1055,7 +1055,7 @@ send_test_pkt(struct net_device *dev)
 static int
 detect_aui(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (net_debug > 1) printk("%s: Attempting AUI\n", dev->name);
 	control_dc_dc(dev, 0);
@@ -1071,7 +1071,7 @@ detect_aui(struct net_device *dev)
 static int
 detect_bnc(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (net_debug > 1) printk("%s: Attempting BNC\n", dev->name);
 	control_dc_dc(dev, 1);
@@ -1117,7 +1117,7 @@ write_irq(struct net_device *dev, int ch
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int result = 0;
 	int i;
 	int ret;
@@ -1358,7 +1358,7 @@ static void net_timeout(struct net_devic
 
 static int net_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if (net_debug > 3) {
 		printk("%s: sent %d byte packet of type %x\n",
@@ -1517,7 +1517,7 @@ count_rx_errors(int status, struct net_l
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	struct sk_buff *skb;
 	int status, length;
 
@@ -1573,7 +1573,7 @@ static void release_dma_buff(struct net_
 static int
 net_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	netif_stop_queue(dev);
 	
@@ -1600,7 +1600,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
@@ -1614,7 +1614,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	spin_lock_irqsave(&lp->lock, flags);
diff -puN drivers/net/eth16i.c~drivers_net_casts drivers/net/eth16i.c
--- linux-263-229/drivers/net/eth16i.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/eth16i.c	2004-02-29 14:03:33.000000000 -0800
@@ -950,7 +950,7 @@ static void eth16i_eeprom_cmd(int ioaddr
 
 static int eth16i_open(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	
 	/* Powerup the chip */
@@ -986,7 +986,7 @@ static int eth16i_open(struct net_device
 
 static int eth16i_close(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	eth16i_reset(dev);
@@ -1012,7 +1012,7 @@ static int eth16i_close(struct net_devic
 
 static void eth16i_timeout(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	/* 
 	   If we get here, some higher level has decided that 
@@ -1053,7 +1053,7 @@ static void eth16i_timeout(struct net_de
 
 static int eth16i_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int status = 0;
 	ushort length = skb->len;
@@ -1130,7 +1130,7 @@ static int eth16i_tx(struct sk_buff *skb
 
 static void eth16i_rx(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int boguscount = MAX_RX_LOOP;
 
@@ -1340,7 +1340,7 @@ static void eth16i_skip_packet(struct ne
 
 static void eth16i_reset(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	if(eth16i_debug > 1) 
@@ -1372,7 +1372,7 @@ static void eth16i_multicast(struct net_
 
 static struct net_device_stats *eth16i_get_stats(struct net_device *dev)
 {
-	struct eth16i_local *lp = (struct eth16i_local *)dev->priv;
+	struct eth16i_local *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/fec.c~drivers_net_casts drivers/net/fec.c
--- linux-263-229/drivers/net/fec.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/fec.c	2004-02-29 14:03:33.000000000 -0800
@@ -1531,7 +1531,7 @@ fec_enet_close(struct net_device *dev)
 
 static struct net_device_stats *fec_enet_get_stats(struct net_device *dev)
 {
-	struct fec_enet_private *fep = (struct fec_enet_private *)dev->priv;
+	struct fec_enet_private *fep = dev->priv;
 
 	return &fep->stats;
 }
diff -puN drivers/net/gt96100eth.c~drivers_net_casts drivers/net/gt96100eth.c
--- linux-263-229/drivers/net/gt96100eth.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/gt96100eth.c	2004-02-29 14:03:33.000000000 -0800
@@ -277,7 +277,7 @@ read_MII(int phy_addr, u32 reg)
 static void
 dump_tx_desc(int dbg_lvl, struct net_device *dev, int i)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	gt96100_td_t *td = &gp->tx_ring[i];
 
 	dbg(dbg_lvl, "Tx descriptor at 0x%08lx:\n", virt_to_phys(td));
@@ -292,7 +292,7 @@ dump_tx_desc(int dbg_lvl, struct net_dev
 static void
 dump_rx_desc(int dbg_lvl, struct net_device *dev, int i)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	gt96100_rd_t *rd = &gp->rx_ring[i];
 
 	dbg(dbg_lvl, "Rx descriptor at 0x%08lx:\n", virt_to_phys(rd));
@@ -332,7 +332,7 @@ write_MII(int phy_addr, u32 reg, u16 dat
 static void
 dump_tx_ring(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int i;
 
 	dbg(0, "%s: txno/txni/cnt=%d/%d/%d\n", __FUNCTION__,
@@ -345,7 +345,7 @@ dump_tx_ring(struct net_device *dev)
 static void
 dump_rx_ring(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int i;
 
 	dbg(0, "%s: rxno=%d\n", __FUNCTION__, gp->rx_next_out);
@@ -359,7 +359,7 @@ static void
 dump_MII(int dbg_lvl, struct net_device *dev)
 {
 	int i, val;
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
     
 	if (dbg_lvl <= GT96100_DEBUG) {
 		for (i=0; i<7; i++) {
@@ -419,7 +419,7 @@ dump_skb(int dbg_lvl, struct net_device 
 static int
 gt96100_add_hash_entry(struct net_device *dev, unsigned char* addr)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	//u16 hashResult, stmp;
 	//unsigned char ctmp, hash_ea[6];
 	u32 tblEntry1, tblEntry0, *tblEntryAddr;
@@ -544,7 +544,7 @@ update_stats(struct gt96100_private *gp)
 static void
 abort(struct net_device *dev, u32 abort_bits)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int timedout = 100; // wait up to 100 msec for hard stop to complete
 
 	dbg(3, "%s\n", __FUNCTION__);
@@ -582,7 +582,7 @@ abort(struct net_device *dev, u32 abort_
 static void
 hard_stop(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 
 	dbg(3, "%s\n", __FUNCTION__);
 
@@ -598,7 +598,7 @@ hard_stop(struct net_device *dev)
 static void
 enable_ether_irq(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	u32 intMask;
 	/*
 	 * route ethernet interrupt to GT_SERINT0 for port 0,
@@ -631,7 +631,7 @@ enable_ether_irq(struct net_device *dev)
 static void
 disable_ether_irq(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	u32 intMask;
 	int intr_mask_reg = (gp->port_num == 0) ?
 		GT96100_SERINT0_MASK : GT96100_INT0_HIGH_MASK;
@@ -839,7 +839,7 @@ out:
 static void
 reset_tx(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int i;
 
 	abort(dev, sdcmrAT);
@@ -877,7 +877,7 @@ reset_tx(struct net_device *dev)
 static void
 reset_rx(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int i;
 
 	abort(dev, sdcmrAR);
@@ -934,7 +934,7 @@ gt96100_check_tx_consistent(struct gt961
 static int
 gt96100_init(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	u32 tmp;
 	u16 mii_reg;
     
@@ -1115,7 +1115,7 @@ gt96100_close(struct net_device *dev)
 static int
 gt96100_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	unsigned long flags;
 	int nextIn;
 
@@ -1187,7 +1187,7 @@ gt96100_tx(struct sk_buff *skb, struct n
 static int
 gt96100_rx(struct net_device *dev, u32 status)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	struct sk_buff *skb;
 	int pkt_len, nextOut, cdp;
 	gt96100_rd_t *rd;
@@ -1296,7 +1296,7 @@ gt96100_rx(struct net_device *dev, u32 s
 static void
 gt96100_tx_complete(struct net_device *dev, u32 status)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	int nextOut, cdp;
 	gt96100_td_t *td;
 	u32 cmdstat;
@@ -1385,7 +1385,7 @@ static irqreturn_t
 gt96100_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *)dev_id;
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	u32 status;
     	int handled = 0;
 
@@ -1486,7 +1486,7 @@ gt96100_interrupt(int irq, void *dev_id,
 static void
 gt96100_tx_timeout(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	unsigned long flags;
     
 	spin_lock_irqsave(&gp->lock, flags);
@@ -1511,7 +1511,7 @@ gt96100_tx_timeout(struct net_device *de
 static void
 gt96100_set_rx_mode(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	unsigned long flags;
 	//struct dev_mc_list *mcptr;
     
@@ -1555,7 +1555,7 @@ gt96100_set_rx_mode(struct net_device *d
 static struct net_device_stats *
 gt96100_get_stats(struct net_device *dev)
 {
-	struct gt96100_private *gp = (struct gt96100_private *)dev->priv;
+	struct gt96100_private *gp = dev->priv;
 	unsigned long flags;
 
 	dbg(3, "%s: dev=%p\n", __FUNCTION__, dev);
diff -puN drivers/net/mac89x0.c~drivers_net_casts drivers/net/mac89x0.c
--- linux-263-229/drivers/net/mac89x0.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/mac89x0.c	2004-02-29 14:03:33.000000000 -0800
@@ -328,7 +328,7 @@ void __init reset_chip(struct net_device
 static int
 net_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int i;
 
 	/* Disable the interrupt for now */
@@ -392,7 +392,7 @@ net_send_packet(struct sk_buff *skb, str
 	if (test_and_set_bit(0, (void*)&dev->tbusy) != 0)
 		printk("%s: Transmitter access conflict.\n", dev->name);
 	else {
-		struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 		unsigned long flags;
 
 		if (net_debug > 3)
@@ -505,7 +505,7 @@ static irqreturn_t net_interrupt(int irq
 static void
 net_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	struct sk_buff *skb;
 	int status, length;
 
@@ -571,7 +571,7 @@ net_close(struct net_device *dev)
 static struct net_device_stats *
 net_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	local_irq_save(flags);
@@ -585,7 +585,7 @@ net_get_stats(struct net_device *dev)
 
 static void set_multicast_list(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	if(dev->flags&IFF_PROMISC)
 	{
diff -puN drivers/net/ni5010.c~drivers_net_casts drivers/net/ni5010.c
--- linux-263-229/drivers/net/ni5010.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/ni5010.c	2004-02-29 14:03:33.000000000 -0800
@@ -527,7 +527,7 @@ static void dump_packet(void *buf, int l
 /* We have a good packet, get it out of the buffer. */
 static void ni5010_rx(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	unsigned char rcv_stat;
 	struct sk_buff *skb;
@@ -592,7 +592,7 @@ static void ni5010_rx(struct net_device 
 
 static int process_xmt_interrupt(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int xmit_stat;
 
@@ -651,7 +651,7 @@ static int ni5010_close(struct net_devic
    closed. */
 static struct net_device_stats *ni5010_get_stats(struct net_device *dev)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = dev->priv;
 
 	PRINTK2((KERN_DEBUG "%s: entering ni5010_get_stats\n", dev->name));
 	
@@ -693,7 +693,7 @@ static void ni5010_set_multicast_list(st
 
 static void hardware_send_packet(struct net_device *dev, char *buf, int length, int pad)
 {
-	struct ni5010_local *lp = (struct ni5010_local *)dev->priv;
+	struct ni5010_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 	unsigned int buf_offs;
diff -puN drivers/net/rrunner.c~drivers_net_casts drivers/net/rrunner.c
--- linux-263-229/drivers/net/rrunner.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/rrunner.c	2004-02-29 14:03:33.000000000 -0800
@@ -960,7 +960,7 @@ static u32 rr_handle_event(struct net_de
 
 static void rx_int(struct net_device *dev, u32 rxlimit, u32 index)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = dev->priv;
 	struct rr_regs *regs = rrpriv->regs;
 
 	do {
@@ -1133,7 +1133,7 @@ static irqreturn_t rr_interrupt(int irq,
 static void rr_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = dev->priv;
 	struct rr_regs *regs = rrpriv->regs;
 	unsigned long flags;
 
@@ -1160,7 +1160,7 @@ static void rr_timer(unsigned long data)
 
 static int rr_open(struct net_device *dev)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = dev->priv;
 	struct pci_dev *pdev = rrpriv->pci_dev;
 	struct rr_regs *regs;
 	int ecode = 0;
@@ -1418,7 +1418,7 @@ static int rr_close(struct net_device *d
 
 static int rr_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct rr_private *rrpriv = (struct rr_private *)dev->priv;
+	struct rr_private *rrpriv = dev->priv;
 	struct rr_regs *regs = rrpriv->regs;
 	struct ring_ctrl *txctrl;
 	unsigned long flags;
diff -puN drivers/net/sb1000.c~drivers_net_casts drivers/net/sb1000.c
--- linux-263-229/drivers/net/sb1000.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sb1000.c	2004-02-29 14:03:33.000000000 -0800
@@ -746,7 +746,7 @@ sb1000_rx(struct net_device *dev)
 	int ioaddr, ns;
 	unsigned int skbsize;
 	struct sk_buff *skb;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 	struct net_device_stats *stats = &lp->stats;
 
 	/* SB1000 frame constants */
@@ -905,7 +905,7 @@ sb1000_error_dpc(struct net_device *dev)
 	char *name;
 	unsigned char st[5];
 	int ioaddr[2];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 	const unsigned char Command0[6] = {0x80, 0x26, 0x00, 0x00, 0x00, 0x00};
 	const int ErrorDpcCounterInitialize = 200;
 
@@ -932,7 +932,7 @@ sb1000_open(struct net_device *dev)
 {
 	char *name;
 	int ioaddr[2], status;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 	const unsigned short FirmwareVersion[] = {0x01, 0x01};
 
 	ioaddr[0] = dev->base_addr;
@@ -998,7 +998,7 @@ static int sb1000_dev_ioctl(struct net_d
 	short PID[4];
 	int ioaddr[2], status, frequency;
 	unsigned int stats[5];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 
 	if (!(dev && dev->flags & IFF_UP))
 		return -ENODEV;
@@ -1092,7 +1092,7 @@ static irqreturn_t sb1000_interrupt(int 
 	unsigned char st;
 	int ioaddr[2];
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 
 	const unsigned char Command0[6] = {0x80, 0x2c, 0x00, 0x00, 0x00, 0x00};
 	const unsigned char Command1[6] = {0x80, 0x2e, 0x00, 0x00, 0x00, 0x00};
@@ -1148,7 +1148,7 @@ static irqreturn_t sb1000_interrupt(int 
 
 static struct net_device_stats *sb1000_stats(struct net_device *dev)
 {
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 	return &lp->stats;
 }
 
@@ -1156,7 +1156,7 @@ static int sb1000_close(struct net_devic
 {
 	int i;
 	int ioaddr[2];
-	struct sb1000_private *lp = (struct sb1000_private *)dev->priv;
+	struct sb1000_private *lp = dev->priv;
 
 	if (sb1000_debug > 2)
 		printk(KERN_DEBUG "%s: Shutting down sb1000.\n", dev->name);
diff -puN drivers/net/sb1250-mac.c~drivers_net_casts drivers/net/sb1250-mac.c
--- linux-263-229/drivers/net/sb1250-mac.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sb1250-mac.c	2004-02-29 14:03:33.000000000 -0800
@@ -2150,7 +2150,7 @@ static irqreturn_t sbmac_intr(int irq,vo
  ********************************************************************* */
 static int sbmac_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	
 	/* lock eth irq */
 	spin_lock_irq (&sc->sbm_lock);
@@ -2454,7 +2454,7 @@ static int sbmac_init(struct net_device 
 
 static int sbmac_open(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	
 	if (debug > 1) {
 		printk(KERN_DEBUG "%s: sbmac_open() irq %d.\n", dev->name, dev->irq);
@@ -2609,7 +2609,7 @@ static int sbmac_mii_poll(struct sbmac_s
 static void sbmac_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	int next_tick = HZ;
 	int mii_status;
 
@@ -2673,7 +2673,7 @@ static void sbmac_tx_timeout (struct net
 
 static struct net_device_stats *sbmac_get_stats(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	unsigned long flags;
 	
 	spin_lock_irqsave(&sc->sbm_lock, flags);
@@ -2691,7 +2691,7 @@ static void sbmac_set_rx_mode(struct net
 {
 	unsigned long flags;
 	int msg_flag = 0;
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 
 	spin_lock_irqsave(&sc->sbm_lock, flags);
 	if ((dev->flags ^ sc->sbm_devflags) & IFF_PROMISC) {
@@ -2726,7 +2726,7 @@ static void sbmac_set_rx_mode(struct net
 
 static int sbmac_mii_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	u16 *data = (u16 *)&rq->ifr_data;
 	unsigned long flags;
 	int retval;
@@ -2762,7 +2762,7 @@ static int sbmac_mii_ioctl(struct net_de
 
 static int sbmac_close(struct net_device *dev)
 {
-	struct sbmac_softc *sc = (struct sbmac_softc *)dev->priv;
+	struct sbmac_softc *sc = dev->priv;
 	unsigned long flags;
 	int irq;
 
diff -puN drivers/net/seeq8005.c~drivers_net_casts drivers/net/seeq8005.c
--- linux-263-229/drivers/net/seeq8005.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/seeq8005.c	2004-02-29 14:03:33.000000000 -0800
@@ -357,7 +357,7 @@ out:
    */
 static int seeq8005_open(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	{
 		 int irqval = request_irq(dev->irq, &seeq8005_interrupt, 0, "seeq8005", dev);
@@ -390,7 +390,7 @@ static void seeq8005_timeout(struct net_
 
 static int seeq8005_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	short length = skb->len;
 	unsigned char *buf;
 
@@ -462,7 +462,7 @@ static irqreturn_t seeq8005_interrupt(in
 /* We have a good packet(s), get it/them out of the buffers. */
 static void seeq8005_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int boguscount = 10;
 	int pkt_hdr;
 	int ioaddr = dev->base_addr;
@@ -561,7 +561,7 @@ static void seeq8005_rx(struct net_devic
 /* The inverse routine to net_open(). */
 static int seeq8005_close(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	lp->open_time = 0;
@@ -583,7 +583,7 @@ static int seeq8005_close(struct net_dev
    closed. */
 static struct net_device_stats *seeq8005_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	return &lp->stats;
 }
@@ -618,7 +618,7 @@ static void set_multicast_list(struct ne
 
 void seeq8005_init(struct net_device *dev, int startp)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int i;
 	
diff -puN drivers/net/sgiseeq.c~drivers_net_casts drivers/net/sgiseeq.c
--- linux-263-229/drivers/net/sgiseeq.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sgiseeq.c	2004-02-29 14:03:33.000000000 -0800
@@ -445,7 +445,7 @@ static irqreturn_t sgiseeq_interrupt(int
 
 static int sgiseeq_open(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *)dev->priv;
+	struct sgiseeq_private *sp = dev->priv;
 	struct sgiseeq_regs *sregs = sp->sregs;
 
 	int err = init_seeq(dev, sp, sregs);
diff -puN drivers/net/sk_g16.c~drivers_net_casts drivers/net/sk_g16.c
--- linux-263-229/drivers/net/sk_g16.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/sk_g16.c	2004-02-29 14:03:33.000000000 -0800
@@ -869,7 +869,7 @@ static int SK_open(struct net_device *de
 
     int irqtab[] = SK_IRQS; 
 
-    struct priv *p = (struct priv *)dev->priv;
+    struct priv *p = dev->priv;
 
     PRINTK(("## %s: At beginning of SK_open(). CSR0: %#06x\n", 
            SK_NAME, SK_read_reg(CSR0)));
diff -puN drivers/net/smc9194.c~drivers_net_casts drivers/net/smc9194.c
--- linux-263-229/drivers/net/smc9194.c~drivers_net_casts	2004-02-29 14:03:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/smc9194.c	2004-02-29 14:03:33.000000000 -0800
@@ -465,7 +465,7 @@ static void smc_setmulticast( int ioaddr
 */
 static int smc_wait_to_send_packet( struct sk_buff * skb, struct net_device * dev )
 {
-	struct smc_local *lp 	= (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 	unsigned short ioaddr 	= dev->base_addr;
 	word 			length;
 	unsigned short 		numPages;
@@ -576,7 +576,7 @@ static int smc_wait_to_send_packet( stru
 */
 static void smc_hardware_send_packet( struct net_device * dev )
 {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 	byte	 		packet_no;
 	struct sk_buff * 	skb = lp->saved_skb;
 	word			length;
@@ -1150,7 +1150,7 @@ static irqreturn_t smc_interrupt(int irq
 {
 	struct net_device *dev 	= dev_id;
 	int ioaddr 		= dev->base_addr;
-	struct smc_local *lp 	= (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 
 	byte	status;
 	word	card_stats;
@@ -1274,7 +1274,7 @@ static irqreturn_t smc_interrupt(int irq
 */
 static void smc_rcv(struct net_device *dev)
 {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 	int 	ioaddr = dev->base_addr;
 	int 	packet_number;
 	word	status;
@@ -1401,7 +1401,7 @@ done:
 static void smc_tx( struct net_device * dev )
 {
 	int	ioaddr = dev->base_addr;
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 	byte saved_packet;
 	byte packet_no;
 	word tx_status;
@@ -1474,7 +1474,7 @@ static int smc_close(struct net_device *
  . This may be called with the card open or closed.
  .-------------------------------------------------------------*/
 static struct net_device_stats* smc_query_statistics(struct net_device *dev) {
-	struct smc_local *lp = (struct smc_local *)dev->priv;
+	struct smc_local *lp = dev->priv;
 
 	return &lp->stats;
 }

_


--
~Randy
