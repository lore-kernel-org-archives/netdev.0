From: Joe Perches <joe@perches.com>
Subject: [PATCH 6/8] irda: w83977af_ir: Parenthesis alignment
Date: Thu, 24 Nov 2016 11:10:33 -0800
Message-ID: <26613875135bd9e3e606a2e1e3e29891b9d87eee.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neaten function declaration and definition arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 5d776fb716f4..9c5b780b1d39 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -90,7 +90,7 @@ static int  w83977af_probe(int iobase, int irq, int dma);
 static int  w83977af_dma_receive(struct w83977af_ir *self);
 static int  w83977af_dma_receive_complete(struct w83977af_ir *self);
 static netdev_tx_t  w83977af_hard_xmit(struct sk_buff *skb,
-					     struct net_device *dev);
+				       struct net_device *dev);
 static int  w83977af_pio_write(int iobase, __u8 *buf, int len, int fifo_size);
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase);
 static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed);
@@ -477,7 +477,7 @@ static void w83977af_change_speed(struct w83977af_ir *self, __u32 speed)
  *
  */
 static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
-					    struct net_device *dev)
+				      struct net_device *dev)
 {
 	struct w83977af_ir *self;
 	__s32 speed;
-- 
2.10.0.rc2.1.g053435c
