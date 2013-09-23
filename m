From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/10] 8390: Remove extern from function prototypes
Date: Mon, 23 Sep 2013 15:11:29 -0700
Message-ID: <6ba89944a5841cbbd76b9a1412e1e7b6c41e1efe.1379974101.git.joe@perches.com>
References: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5570169a078375fa8662adeb2a7f24c1ae718bfb.1379974101.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are a mix of function prototypes with and without extern
in the kernel sources.  Standardize on not using extern for
function prototypes.

Function prototypes don't need to be written with extern.
extern is assumed by the compiler.  Its use is as unnecessary as
using auto to declare automatic/local variables in a block.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/8390/8390.h | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/8390/8390.h b/drivers/net/ethernet/8390/8390.h
index ef325ff..2923c51 100644
--- a/drivers/net/ethernet/8390/8390.h
+++ b/drivers/net/ethernet/8390/8390.h
@@ -28,42 +28,42 @@ extern int ei_debug;
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-extern void ei_poll(struct net_device *dev);
-extern void eip_poll(struct net_device *dev);
+void ei_poll(struct net_device *dev);
+void eip_poll(struct net_device *dev);
 #endif
 
 
 /* Without I/O delay - non ISA or later chips */
-extern void NS8390_init(struct net_device *dev, int startp);
-extern int ei_open(struct net_device *dev);
-extern int ei_close(struct net_device *dev);
-extern irqreturn_t ei_interrupt(int irq, void *dev_id);
-extern void ei_tx_timeout(struct net_device *dev);
-extern netdev_tx_t ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
-extern void ei_set_multicast_list(struct net_device *dev);
-extern struct net_device_stats *ei_get_stats(struct net_device *dev);
+void NS8390_init(struct net_device *dev, int startp);
+int ei_open(struct net_device *dev);
+int ei_close(struct net_device *dev);
+irqreturn_t ei_interrupt(int irq, void *dev_id);
+void ei_tx_timeout(struct net_device *dev);
+netdev_tx_t ei_start_xmit(struct sk_buff *skb, struct net_device *dev);
+void ei_set_multicast_list(struct net_device *dev);
+struct net_device_stats *ei_get_stats(struct net_device *dev);
 
 extern const struct net_device_ops ei_netdev_ops;
 
-extern struct net_device *__alloc_ei_netdev(int size);
+struct net_device *__alloc_ei_netdev(int size);
 static inline struct net_device *alloc_ei_netdev(void)
 {
 	return __alloc_ei_netdev(0);
 }
 
 /* With I/O delay form */
-extern void NS8390p_init(struct net_device *dev, int startp);
-extern int eip_open(struct net_device *dev);
-extern int eip_close(struct net_device *dev);
-extern irqreturn_t eip_interrupt(int irq, void *dev_id);
-extern void eip_tx_timeout(struct net_device *dev);
-extern netdev_tx_t eip_start_xmit(struct sk_buff *skb, struct net_device *dev);
-extern void eip_set_multicast_list(struct net_device *dev);
-extern struct net_device_stats *eip_get_stats(struct net_device *dev);
+void NS8390p_init(struct net_device *dev, int startp);
+int eip_open(struct net_device *dev);
+int eip_close(struct net_device *dev);
+irqreturn_t eip_interrupt(int irq, void *dev_id);
+void eip_tx_timeout(struct net_device *dev);
+netdev_tx_t eip_start_xmit(struct sk_buff *skb, struct net_device *dev);
+void eip_set_multicast_list(struct net_device *dev);
+struct net_device_stats *eip_get_stats(struct net_device *dev);
 
 extern const struct net_device_ops eip_netdev_ops;
 
-extern struct net_device *__alloc_eip_netdev(int size);
+struct net_device *__alloc_eip_netdev(int size);
 static inline struct net_device *alloc_eip_netdev(void)
 {
 	return __alloc_eip_netdev(0);
-- 
1.8.1.2.459.gbcd45b4.dirty
