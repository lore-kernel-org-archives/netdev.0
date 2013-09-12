From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] ethernet: amd: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 05:52:50 +0200
Message-ID: <1378957970-3666-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: rusty@rustcorp.com.au, benh@kernel.crashing.org,
	silviupopescu1990@gmail.com, geert@linux-m68k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag from
drivers/net/ethernet/amd/sun3lance.c

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/ethernet/amd/sun3lance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/sun3lance.c b/drivers/net/ethernet/amd/sun3lance.c
index d6b2029..3d8c6b2 100644
--- a/drivers/net/ethernet/amd/sun3lance.c
+++ b/drivers/net/ethernet/amd/sun3lance.c
@@ -358,7 +358,7 @@ static int __init lance_probe( struct net_device *dev)
 
 	REGA(CSR0) = CSR0_STOP;
 
-	if (request_irq(LANCE_IRQ, lance_interrupt, IRQF_DISABLED, "SUN3 Lance", dev) < 0) {
+	if (request_irq(LANCE_IRQ, lance_interrupt, 0, "SUN3 Lance", dev) < 0) {
 #ifdef CONFIG_SUN3
 		iounmap((void __iomem *)ioaddr);
 #endif
-- 
1.8.1.2
