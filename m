From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] irda: update comment mentioning IRQF_DISABLED
Date: Sun, 13 Oct 2013 08:26:31 +0200
Message-ID: <1381645591-9565-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: samuel@sortiz.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes a comment mentioning IRQF_DISABLED,
which is deprecated.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 include/net/irda/irda_device.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/irda/irda_device.h b/include/net/irda/irda_device.h
index 94c852d..1141747 100644
--- a/include/net/irda/irda_device.h
+++ b/include/net/irda/irda_device.h
@@ -162,7 +162,7 @@ typedef struct {
         int irq, irq2;        /* Interrupts used */
         int dma, dma2;        /* DMA channel(s) used */
         int fifo_size;        /* FIFO size */
-        int irqflags;         /* interrupt flags (ie, IRQF_SHARED|IRQF_DISABLED) */
+        int irqflags;         /* interrupt flags (ie, IRQF_SHARED) */
 	int direction;        /* Link direction, used by some FIR drivers */
 	int enabled;          /* Powered on? */
 	int suspended;        /* Suspended by APM */
-- 
1.8.1.2
