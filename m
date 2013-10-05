From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] net: wan: remove deprecated IRQF_DISABLED
Date: Sat,  5 Oct 2013 06:45:30 +0200
Message-ID: <1380948330-4517-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the use of the IRQF_DISABLED flag

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/wan/hostess_sv11.c | 2 +-
 drivers/net/wan/sealevel.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/hostess_sv11.c b/drivers/net/wan/hostess_sv11.c
index 3d80e42..3d74166 100644
--- a/drivers/net/wan/hostess_sv11.c
+++ b/drivers/net/wan/hostess_sv11.c
@@ -220,7 +220,7 @@ static struct z8530_dev *sv11_init(int iobase, int irq)
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, 0,
 			"Hostess SV11", sv) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_irq;
diff --git a/drivers/net/wan/sealevel.c b/drivers/net/wan/sealevel.c
index 4f77484..27860b4 100644
--- a/drivers/net/wan/sealevel.c
+++ b/drivers/net/wan/sealevel.c
@@ -266,7 +266,7 @@ static __init struct slvl_board *slvl_init(int iobase, int irq,
 	/* We want a fast IRQ for this device. Actually we'd like an even faster
 	   IRQ ;) - This is one driver RtLinux is made for */
 
-	if (request_irq(irq, z8530_interrupt, IRQF_DISABLED,
+	if (request_irq(irq, z8530_interrupt, 0,
 			"SeaLevel", dev) < 0) {
 		pr_warn("IRQ %d already in use\n", irq);
 		goto err_request_irq;
-- 
1.8.1.2
