From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/11] wan: Remove extern from function prototypes
Date: Wed, 25 Sep 2013 12:37:20 -0700
Message-ID: <65c8f953621acc51fd45662191ca21126b75d142.1380137609.git.joe@perches.com>
References: <cover.1380137609.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1380137609.git.joe@perches.com>
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
 drivers/net/wan/x25_asy.h |  2 +-
 drivers/net/wan/z85230.h  | 27 +++++++++++++--------------
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wan/x25_asy.h b/drivers/net/wan/x25_asy.h
index 8f0fc2e..f57ee67 100644
--- a/drivers/net/wan/x25_asy.h
+++ b/drivers/net/wan/x25_asy.h
@@ -41,6 +41,6 @@ struct x25_asy {
 
 #define X25_ASY_MAGIC 0x5303
 
-extern int x25_asy_init(struct net_device *dev);
+int x25_asy_init(struct net_device *dev);
 
 #endif	/* _LINUX_X25_ASY.H */
diff --git a/drivers/net/wan/z85230.h b/drivers/net/wan/z85230.h
index f29d554..2416a9d 100644
--- a/drivers/net/wan/z85230.h
+++ b/drivers/net/wan/z85230.h
@@ -395,20 +395,19 @@ struct z8530_dev
 extern u8 z8530_dead_port[];
 extern u8 z8530_hdlc_kilostream_85230[];
 extern u8 z8530_hdlc_kilostream[];
-extern irqreturn_t z8530_interrupt(int, void *);
-extern void z8530_describe(struct z8530_dev *, char *mapping, unsigned long io);
-extern int z8530_init(struct z8530_dev *);
-extern int z8530_shutdown(struct z8530_dev *);
-extern int z8530_sync_open(struct net_device *, struct z8530_channel *);
-extern int z8530_sync_close(struct net_device *, struct z8530_channel *);
-extern int z8530_sync_dma_open(struct net_device *, struct z8530_channel *);
-extern int z8530_sync_dma_close(struct net_device *, struct z8530_channel *);
-extern int z8530_sync_txdma_open(struct net_device *, struct z8530_channel *);
-extern int z8530_sync_txdma_close(struct net_device *, struct z8530_channel *);
-extern int z8530_channel_load(struct z8530_channel *, u8 *);
-extern netdev_tx_t z8530_queue_xmit(struct z8530_channel *c,
-					  struct sk_buff *skb);
-extern void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb);
+irqreturn_t z8530_interrupt(int, void *);
+void z8530_describe(struct z8530_dev *, char *mapping, unsigned long io);
+int z8530_init(struct z8530_dev *);
+int z8530_shutdown(struct z8530_dev *);
+int z8530_sync_open(struct net_device *, struct z8530_channel *);
+int z8530_sync_close(struct net_device *, struct z8530_channel *);
+int z8530_sync_dma_open(struct net_device *, struct z8530_channel *);
+int z8530_sync_dma_close(struct net_device *, struct z8530_channel *);
+int z8530_sync_txdma_open(struct net_device *, struct z8530_channel *);
+int z8530_sync_txdma_close(struct net_device *, struct z8530_channel *);
+int z8530_channel_load(struct z8530_channel *, u8 *);
+netdev_tx_t z8530_queue_xmit(struct z8530_channel *c, struct sk_buff *skb);
+void z8530_null_rx(struct z8530_channel *c, struct sk_buff *skb);
 
 
 /*
-- 
1.8.1.2.459.gbcd45b4.dirty
