From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in net/wireless/
Date: Sun, 29 Feb 2004 14:42:18 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229144218.5d6b915d.rddunlap@osdl.org>
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


 drivers/net/wireless/atmel.c   |    8 ++++----
 drivers/net/wireless/orinoco.c |    8 ++++----
 2 files changed, 8 insertions(+), 8 deletions(-)

diff -puN drivers/net/wireless/atmel.c~net_wireless_casts drivers/net/wireless/atmel.c
--- linux-263-229/drivers/net/wireless/atmel.c~net_wireless_casts	2004-02-29 13:57:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wireless/atmel.c	2004-02-29 13:57:33.000000000 -0800
@@ -796,7 +796,7 @@ static void tx_update_descriptor(struct 
 
 static int start_tx (struct sk_buff *skb, struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = dev->priv;
 	struct ieee802_11_hdr header;
 	unsigned long flags;
 	u16 buff, frame_ctl, len = (ETH_ZLEN < skb->len) ? skb->len : ETH_ZLEN;
@@ -1234,13 +1234,13 @@ static irqreturn_t service_interrupt(int
 
 static struct net_device_stats *atmel_get_stats (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = dev->priv;
 	return &priv->stats;
 }
 
 static struct iw_statistics *atmel_get_wireless_stats (struct net_device *dev)
 {
-	struct atmel_private *priv = (struct atmel_private *)dev->priv;
+	struct atmel_private *priv = dev->priv;
 
 	/* update the link quality here in case we are seeing no beacons 
 	   at all to drive the process */
@@ -3053,7 +3053,7 @@ static void atmel_management_frame(struc
 static void atmel_management_timer(u_long a)
 {
   struct net_device *dev = (struct net_device *) a;
-  struct atmel_private *priv = (struct atmel_private *)dev->priv;
+  struct atmel_private *priv = dev->priv;
   unsigned long flags;
   
   /* Check if the card has been yanked. */
diff -puN drivers/net/wireless/orinoco.c~net_wireless_casts drivers/net/wireless/orinoco.c
--- linux-263-229/drivers/net/wireless/orinoco.c~net_wireless_casts	2004-02-29 13:57:33.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/wireless/orinoco.c	2004-02-29 13:57:33.000000000 -0800
@@ -2271,7 +2271,7 @@ orinoco_get_wireless_stats(struct net_de
 static inline void orinoco_spy_gather(struct net_device *dev, u_char *mac,
 				    int level, int noise)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = dev->priv;
 	int i;
 
 	/* Gather wireless spy statistics: for each packet, compare the
@@ -2290,7 +2290,7 @@ orinoco_stat_gather(struct net_device *d
 		    struct sk_buff *skb,
 		    struct hermes_rx_descriptor *desc)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = dev->priv;
 
 	/* Using spy support with lots of Rx packets, like in an
 	 * infrastructure (AP), will really slow down everything, because
@@ -2311,7 +2311,7 @@ orinoco_stat_gather(struct net_device *d
 static int
 orinoco_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = dev->priv;
 	struct net_device_stats *stats = &priv->stats;
 	hermes_t *hw = &priv->hw;
 	int err = 0;
@@ -2449,7 +2449,7 @@ orinoco_xmit(struct sk_buff *skb, struct
 static void
 orinoco_tx_timeout(struct net_device *dev)
 {
-	struct orinoco_private *priv = (struct orinoco_private *)dev->priv;
+	struct orinoco_private *priv = dev->priv;
 	struct net_device_stats *stats = &priv->stats;
 	struct hermes *hw = &priv->hw;
 

_


--
~Randy
