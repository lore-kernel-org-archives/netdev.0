From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] atm/idt77252: correct printk of dma_addr_t
Date: Tue, 3 Feb 2004 15:34:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040203153448.5c81e49d.rddunlap@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas@cmf.nrl.navy.mil
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


description:	fix dma_addr_t type error with CONFIG_HIGHMEM64G=y;
product_versions: linux-262-rc3

diffstat:=
 drivers/atm/idt77252.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff -Naurp ./drivers/atm/idt77252.c~idt_dma ./drivers/atm/idt77252.c
--- ./drivers/atm/idt77252.c~idt_dma	2004-01-08 22:59:33.000000000 -0800
+++ ./drivers/atm/idt77252.c	2004-02-03 14:14:08.000000000 -0800
@@ -664,8 +664,8 @@ alloc_scq(struct idt77252_dev *card, int
 	skb_queue_head_init(&scq->transmit);
 	skb_queue_head_init(&scq->pending);
 
-	TXPRINTK("idt77252: SCQ: base 0x%p, next 0x%p, last 0x%p, paddr %08x\n",
-		 scq->base, scq->next, scq->last, scq->paddr);
+	TXPRINTK("idt77252: SCQ: base 0x%p, next 0x%p, last 0x%p, paddr %08llx\n",
+		 scq->base, scq->next, scq->last, (unsigned long long)scq->paddr);
 
 	return scq;
 }


--
~Randy
