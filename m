From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: Re: [janitor] remove unneeded casts in /appletalk/ & /fc/
Date: Sun, 29 Feb 2004 14:35:30 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040229143530.12d9426d.rddunlap@osdl.org>
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


 drivers/net/appletalk/cops.c |   16 ++++++++--------
 drivers/net/fc/iph5526.c     |    2 +-
 2 files changed, 9 insertions(+), 9 deletions(-)

diff -puN drivers/net/appletalk/cops.c~net_atalk_fc_casts drivers/net/appletalk/cops.c
--- linux-263-229/drivers/net/appletalk/cops.c~net_atalk_fc_casts	2004-02-29 13:54:59.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/appletalk/cops.c	2004-02-29 13:54:59.000000000 -0800
@@ -422,7 +422,7 @@ static int __init cops_irq (int ioaddr, 
  */
 static int cops_open(struct net_device *dev)
 {
-    struct cops_local *lp = (struct cops_local *)dev->priv;
+    struct cops_local *lp = dev->priv;
 
 	if(dev->irq==0)
 	{
@@ -456,7 +456,7 @@ static int cops_open(struct net_device *
  */
 static int cops_jumpstart(struct net_device *dev)
 {
-	struct cops_local *lp = (struct cops_local *)dev->priv;
+	struct cops_local *lp = dev->priv;
 
 	/*
          *      Once the card has the firmware loaded and has acquired
@@ -490,7 +490,7 @@ static void tangent_wait_reset(int ioadd
  */
 static void cops_reset(struct net_device *dev, int sleep)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = dev->priv;
         int ioaddr=dev->base_addr;
 
         if(lp->board==TANGENT)
@@ -869,7 +869,7 @@ static void cops_rx(struct net_device *d
 
 static void cops_timeout(struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = dev->priv;
         int ioaddr = dev->base_addr;
 
 	lp->stats.tx_errors++;
@@ -891,7 +891,7 @@ static void cops_timeout(struct net_devi
 
 static int cops_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = dev->priv;
         int ioaddr = dev->base_addr;
         unsigned long flags;
 
@@ -966,7 +966,7 @@ static int cops_hard_header(struct sk_bu
  
 static int cops_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = dev->priv;
         struct sockaddr_at *sa = (struct sockaddr_at *)&ifr->ifr_addr;
         struct atalk_addr *aa = (struct atalk_addr *)&lp->node_addr;
 
@@ -1002,7 +1002,7 @@ static int cops_ioctl(struct net_device 
  
 static int cops_close(struct net_device *dev)
 {
-	struct cops_local *lp = (struct cops_local *)dev->priv;
+	struct cops_local *lp = dev->priv;
 
 	/* If we were running polled, yank the timer.
 	 */
@@ -1019,7 +1019,7 @@ static int cops_close(struct net_device 
  */
 static struct net_device_stats *cops_get_stats(struct net_device *dev)
 {
-        struct cops_local *lp = (struct cops_local *)dev->priv;
+        struct cops_local *lp = dev->priv;
         return &lp->stats;
 }
 
diff -puN drivers/net/fc/iph5526.c~net_atalk_fc_casts drivers/net/fc/iph5526.c
--- linux-263-229/drivers/net/fc/iph5526.c~net_atalk_fc_casts	2004-02-29 13:54:59.000000000 -0800
+++ linux-263-229-rddunlap/drivers/net/fc/iph5526.c	2004-02-29 13:54:59.000000000 -0800
@@ -238,7 +238,7 @@ int __init iph5526_probe(struct net_devi
 
 static int __init iph5526_probe_pci(struct net_device *dev)
 {
-	struct fc_info *fi = (struct fc_info *)dev->priv;
+	struct fc_info *fi = dev->priv;
 	fi->dev = dev;
 	dev->base_addr = fi->base_addr;
 	dev->irq = fi->irq;

_


--
~Randy
--
~Randy
