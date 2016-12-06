From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 6/7] irda: w83977af_ir: Parenthesis alignment
Date: Tue,  6 Dec 2016 10:16:05 -0800
Message-ID: <c021dfdea94bdce7868713204073c52396d53026.1481047792.git.joe@perches.com>
References: <cover.1481047792.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1481047792.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Neaten function declaration and definition arguments.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 5d5ec8938e2b..2f95ee26ed49 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -84,13 +84,13 @@ static struct w83977af_ir *dev_self[] = { NULL, NULL, NULL, NULL};
 
 /* Some prototypes */
 static int  w83977af_open(int i, unsigned int iobase, unsigned int irq,
-                          unsigned int dma);
+			  unsigned int dma);
 static int  w83977af_close(struct w83977af_ir *self);
 static int  w83977af_probe(int iobase, int irq, int dma);
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
