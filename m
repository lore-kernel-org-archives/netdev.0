From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6.9-rc4] dummy: use netdev_priv
Date: Fri, 15 Oct 2004 15:32:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041015153230.60e718af@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Can use netdev_priv in dummy device.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/dummy.c b/drivers/net/dummy.c
--- a/drivers/net/dummy.c	2004-10-15 14:25:11 -07:00
+++ b/drivers/net/dummy.c	2004-10-15 14:25:11 -07:00
@@ -77,7 +77,7 @@
 
 static int dummy_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net_device_stats *stats = dev->priv;
+	struct net_device_stats *stats = netdev_priv(dev);
 
 	stats->tx_packets++;
 	stats->tx_bytes+=skb->len;
@@ -88,7 +88,7 @@
 
 static struct net_device_stats *dummy_get_stats(struct net_device *dev)
 {
-	return dev->priv;
+	return netdev_priv(dev);
 }
 
 static struct net_device **dummies;
