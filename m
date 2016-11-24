From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/8] irda: w83977af_ir: Remove unnecessary blank lines
Date: Thu, 24 Nov 2016 11:10:30 -0800
Message-ID: <27a5cbfc2f59a978ad84ff19ddd76d6a333adfba.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These just add unnecessary vertical whitespace.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 4ad91f4f867f..5aa61413aea8 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -178,7 +178,6 @@ static int w83977af_open(int i, unsigned int iobase, unsigned int irq,
 	self = netdev_priv(dev);
 	spin_lock_init(&self->lock);
 
-
 	/* Initialize IO */
 	self->io.fir_base   = iobase;
 	self->io.irq       = irq;
@@ -553,6 +552,7 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 static void w83977af_dma_write(struct w83977af_ir *self, int iobase)
 {
 	__u8 set;
+
 	pr_debug("%s(), len=%d\n", __func__, self->tx_buff.len);
 
 	/* Save current set */
@@ -652,7 +652,6 @@ static void w83977af_dma_xmit_complete(struct w83977af_ir *self)
 	} else
 		self->netdev->stats.tx_packets++;
 
-
 	if (self->new_speed) {
 		w83977af_change_speed(self, self->new_speed);
 		self->new_speed = 0;
@@ -1114,7 +1113,6 @@ static int w83977af_net_open(struct net_device *dev)
 	char hwname[32];
 	__u8 set;
 
-
 	IRDA_ASSERT(dev != NULL, return -1;);
 	self = netdev_priv(dev);
 
@@ -1263,7 +1261,6 @@ MODULE_AUTHOR("Dag Brattli <dagb@cs.uit.no>");
 MODULE_DESCRIPTION("Winbond W83977AF IrDA Device Driver");
 MODULE_LICENSE("GPL");
 
-
 module_param(qos_mtt_bits, int, 0);
 MODULE_PARM_DESC(qos_mtt_bits, "Mimimum Turn Time");
 module_param_array(io, int, NULL, 0);
-- 
2.10.0.rc2.1.g053435c
