From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] remove dead extern's in netdevice.h
Date: Wed, 2 Mar 2005 10:59:02 -0800
Message-ID: <20050302105902.72f2b983@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following definitions are historical relics.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	2005-03-02 10:53:22 -08:00
+++ b/include/linux/netdevice.h	2005-03-02 10:53:22 -08:00
@@ -921,8 +921,6 @@
 extern void		dev_mcast_init(void);
 extern int		netdev_max_backlog;
 extern int		weight_p;
-extern unsigned long	netdev_fc_xoff;
-extern atomic_t netdev_dropping;
 extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
 extern int skb_checksum_help(struct sk_buff *skb, int inward);
 /* rx skb timestamps */
