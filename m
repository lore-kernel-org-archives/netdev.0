From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in 3com drivers
Date: Sun, 29 Feb 2004 14:54:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229145425.041757b1.rddunlap@osdl.org>
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


 drivers/net/3c501.c |   12 ++++++------
 drivers/net/3c507.c |   10 +++++-----
 drivers/net/3c509.c |   16 ++++++++--------
 drivers/net/3c59x.c |   42 +++++++++++++++++++++---------------------
 4 files changed, 40 insertions(+), 40 deletions(-)

diff -puN drivers/net/3c501.c~net_3cxyz_casts drivers/net/3c501.c
--- linux-263-229/drivers/net/3c501.c~net_3cxyz_casts	2004-02-29 14:02:48.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/3c501.c	2004-02-29 14:02:48.000000000 -0800
@@ -341,7 +341,7 @@ static int el_open(struct net_device *de
 {
 	int retval;
 	int ioaddr = dev->base_addr;
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long flags;
 
 	if (el_debug > 2)
@@ -371,7 +371,7 @@ static int el_open(struct net_device *de
  
 static void el_timeout(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
  
 	if (el_debug)
@@ -411,7 +411,7 @@ static void el_timeout(struct net_device
 
 static int el_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -698,7 +698,7 @@ out:
 
 static void el_receive(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	int pkt_len;
 	struct sk_buff *skb;
@@ -764,7 +764,7 @@ static void el_receive(struct net_device
 
 static void  el_reset(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	if (el_debug> 2)
@@ -828,7 +828,7 @@ static int el1_close(struct net_device *
  
 static struct net_device_stats *el1_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	return &lp->stats;
 }
 
diff -puN drivers/net/3c507.c~net_3cxyz_casts drivers/net/3c507.c
--- linux-263-229/drivers/net/3c507.c~net_3cxyz_casts	2004-02-29 14:02:48.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/3c507.c	2004-02-29 14:02:48.000000000 -0800
@@ -660,7 +660,7 @@ static int el16_close(struct net_device 
    closed. */
 static struct net_device_stats *el16_get_stats(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 
 	/* ToDo: decide if there are any useful statistics from the SCB. */
 
@@ -670,7 +670,7 @@ static struct net_device_stats *el16_get
 /* Initialize the Rx-block list. */
 static void init_rx_bufs(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long write_ptr;
 	unsigned short SCB_base = SCB_BASE;
 
@@ -713,7 +713,7 @@ static void init_rx_bufs(struct net_devi
 
 static void init_82586_mem(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	unsigned long shmem = dev->mem_start;
 
@@ -771,7 +771,7 @@ static void init_82586_mem(struct net_de
 
 static void hardware_send_packet(struct net_device *dev, void *buf, short length, short pad)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	short ioaddr = dev->base_addr;
 	ushort tx_block = lp->tx_head;
 	unsigned long write_ptr = dev->mem_start + tx_block;
@@ -820,7 +820,7 @@ static void hardware_send_packet(struct 
 
 static void el16_rx(struct net_device *dev)
 {
-	struct net_local *lp = (struct net_local *)dev->priv;
+	struct net_local *lp = dev->priv;
 	unsigned long shmem = dev->mem_start;
 	ushort rx_head = lp->rx_head;
 	ushort rx_tail = lp->rx_tail;
diff -puN drivers/net/3c509.c~net_3cxyz_casts drivers/net/3c509.c
--- linux-263-229/drivers/net/3c509.c~net_3cxyz_casts	2004-02-29 14:02:48.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/3c509.c	2004-02-29 14:02:48.000000000 -0800
@@ -829,7 +829,7 @@ el3_open(struct net_device *dev)
 static void
 el3_tx_timeout (struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -849,7 +849,7 @@ el3_tx_timeout (struct net_device *dev)
 static int
 el3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -975,7 +975,7 @@ el3_interrupt(int irq, void *dev_id, str
 				outw(AckIntr | RxEarly, ioaddr + EL3_CMD);
 			}
 			if (status & TxComplete) {			/* Really Tx error. */
-				struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 				short tx_status;
 				int i = 4;
 
@@ -1022,7 +1022,7 @@ el3_interrupt(int irq, void *dev_id, str
 static struct net_device_stats *
 el3_get_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	unsigned long flags;
 
 	/*
@@ -1043,7 +1043,7 @@ el3_get_stats(struct net_device *dev)
 	*/
 static void update_stats(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 5)
@@ -1073,7 +1073,7 @@ static void update_stats(struct net_devi
 static int
 el3_rx(struct net_device *dev)
 {
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 	short rx_status;
 
@@ -1145,7 +1145,7 @@ static void
 set_multicast_list(struct net_device *dev)
 {
 	unsigned long flags;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	int ioaddr = dev->base_addr;
 
 	if (el3_debug > 1) {
@@ -1172,7 +1172,7 @@ static int
 el3_close(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct el3_private *lp = (struct el3_private *)dev->priv;
+	struct el3_private *lp = dev->priv;
 	
 	if (el3_debug > 2)
 		printk("%s: Shutting down ethercard.\n", dev->name);
diff -puN drivers/net/3c59x.c~net_3cxyz_casts drivers/net/3c59x.c
--- linux-263-229/drivers/net/3c59x.c~net_3cxyz_casts	2004-02-29 14:02:48.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/3c59x.c	2004-02-29 14:02:48.000000000 -0800
@@ -1516,7 +1516,7 @@ static void
 vortex_up(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	unsigned int config;
 	int i;
 
@@ -1714,7 +1714,7 @@ vortex_up(struct net_device *dev)
 static int
 vortex_open(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	int i;
 	int retval;
 
@@ -1772,7 +1772,7 @@ static void
 vortex_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int next_tick = 60*HZ;
 	int ok = 0;
@@ -1898,7 +1898,7 @@ leave_media_alone:
 
 static void vortex_tx_timeout(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	printk(KERN_ERR "%s: transmit timed out, tx_status %2.2x status %4.4x.\n",
@@ -1968,7 +1968,7 @@ static void vortex_tx_timeout(struct net
 static void
 vortex_error(struct net_device *dev, int status)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int do_tx_reset = 0, reset_mask = 0;
 	unsigned char tx_status = 0;
@@ -2070,7 +2070,7 @@ vortex_error(struct net_device *dev, int
 static int
 vortex_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	/* Put out the doubleword header... */
@@ -2125,7 +2125,7 @@ vortex_start_xmit(struct sk_buff *skb, s
 static int
 boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	/* Calculate the next Tx descriptor entry. */
 	int entry = vp->cur_tx % TX_RING_SIZE;
@@ -2225,7 +2225,7 @@ static irqreturn_t
 vortex_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_id;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
@@ -2330,7 +2330,7 @@ static irqreturn_t
 boomerang_interrupt(int irq, void *dev_id, struct pt_regs *regs)
 {
 	struct net_device *dev = dev_id;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr;
 	int status;
 	int work_done = max_interrupt_work;
@@ -2455,7 +2455,7 @@ handler_exit:
 
 static int vortex_rx(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int i;
 	short rx_status;
@@ -2525,7 +2525,7 @@ static int vortex_rx(struct net_device *
 static int
 boomerang_rx(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	int entry = vp->cur_rx % RX_RING_SIZE;
 	long ioaddr = dev->base_addr;
 	int rx_status;
@@ -2627,7 +2627,7 @@ static void
 rx_oom_timer(unsigned long arg)
 {
 	struct net_device *dev = (struct net_device *)arg;
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 
 	spin_lock_irq(&vp->lock);
 	if ((vp->cur_rx - vp->dirty_rx) == RX_RING_SIZE)	/* This test is redundant, but makes me feel good */
@@ -2642,7 +2642,7 @@ rx_oom_timer(unsigned long arg)
 static void
 vortex_down(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	netif_stop_queue (dev);
@@ -2678,7 +2678,7 @@ vortex_down(struct net_device *dev)
 static int
 vortex_close(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int i;
 
@@ -2740,7 +2740,7 @@ static void
 dump_tx_ring(struct net_device *dev)
 {
 	if (vortex_debug > 0) {
-		struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 		long ioaddr = dev->base_addr;
 		
 		if (vp->full_bus_master_tx) {
@@ -2773,7 +2773,7 @@ dump_tx_ring(struct net_device *dev)
 
 static struct net_device_stats *vortex_get_stats(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	unsigned long flags;
 
 	if (netif_device_present(dev)) {	/* AKPM: Used to be netif_running */
@@ -2793,7 +2793,7 @@ static struct net_device_stats *vortex_g
 	*/
 static void update_stats(long ioaddr, struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	int old_window = inw(ioaddr + EL3_CMD);
 
 	if (old_window == 0xffff)	/* Chip suspended or ejected. */
@@ -2855,7 +2855,7 @@ static struct ethtool_ops vortex_ethtool
 
 static int vortex_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	struct mii_ioctl_data *data = (struct mii_ioctl_data *)&rq->ifr_data;
 	int phy = vp->phys[0] & 0x1f;
@@ -2942,7 +2942,7 @@ static void mdio_sync(long ioaddr, int b
 
 static int mdio_read(struct net_device *dev, int phy_id, int location)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	int i;
 	long ioaddr = dev->base_addr;
 	int read_cmd = (0xf6 << 10) | (phy_id << 5) | location;
@@ -2976,7 +2976,7 @@ static int mdio_read(struct net_device *
 
 static void mdio_write(struct net_device *dev, int phy_id, int location, int value)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 	int write_cmd = 0x50020000 | (phy_id << 23) | (location << 18) | value;
 	long mdio_addr = ioaddr + Wn4_PhysicalMgmt;
@@ -3010,7 +3010,7 @@ static void mdio_write(struct net_device
 /* Set Wake-On-LAN mode and put the board into D3 (power-down) state. */
 static void acpi_set_WOL(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = dev->priv;
 	long ioaddr = dev->base_addr;
 
 	/* Power up on: 1==Downloaded Filter, 2==Magic Packets, 4==Link Status. */

_


--
~Randy
