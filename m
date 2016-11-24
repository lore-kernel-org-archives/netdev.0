From: Joe Perches <joe@perches.com>
Subject: [PATCH 8/8] irda: w83977af_ir: Fix misindented block
Date: Thu, 24 Nov 2016 11:10:35 -0800
Message-ID: <8361ddc9645d8c6a47674e80f3d0866966bcbfbc.1480014088.git.joe@perches.com>
References: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1480014088.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

One indent level too many is too many.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/irda/w83977af_ir.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/irda/w83977af_ir.c b/drivers/net/irda/w83977af_ir.c
index 19b171af0e81..b865e93f01a0 100644
--- a/drivers/net/irda/w83977af_ir.c
+++ b/drivers/net/irda/w83977af_ir.c
@@ -517,15 +517,15 @@ static netdev_tx_t w83977af_hard_xmit(struct sk_buff *skb,
 
 		mtt = irda_get_mtt(skb);
 		pr_debug("%s: %ld, mtt=%d\n", __func__, jiffies, mtt);
-			if (mtt > 1000)
-				mdelay(mtt / 1000);
-			else if (mtt)
-				udelay(mtt);
+		if (mtt > 1000)
+			mdelay(mtt / 1000);
+		else if (mtt)
+			udelay(mtt);
 
-			/* Enable DMA interrupt */
-			switch_bank(iobase, SET0);
-			outb(ICR_EDMAI, iobase + ICR);
-			w83977af_dma_write(self, iobase);
+		/* Enable DMA interrupt */
+		switch_bank(iobase, SET0);
+		outb(ICR_EDMAI, iobase + ICR);
+		w83977af_dma_write(self, iobase);
 	} else {
 		self->tx_buff.data = self->tx_buff.head;
 		self->tx_buff.len = async_wrap_skb(skb, self->tx_buff.data,
-- 
2.10.0.rc2.1.g053435c
