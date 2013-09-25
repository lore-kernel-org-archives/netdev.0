From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Subject: [PATCH] hamradio: baycom: remove deprecated IRQF_DISABLED
Date: Wed, 25 Sep 2013 20:17:45 +0200
Message-ID: <1380133065-13712-1-git-send-email-michael.opdenacker@free-electrons.com>
Cc: linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Michael Opdenacker <michael.opdenacker@free-electrons.com>
To: t.sailer@alumni.ethz.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch proposes to remove the IRQF_DISABLED flag
from drivers/net/hamradio/baycom_*

It's a NOOP since 2.6.35 and it will be removed one day.

Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>
---
 drivers/net/hamradio/baycom_ser_fdx.c | 2 +-
 drivers/net/hamradio/baycom_ser_hdx.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hamradio/baycom_ser_fdx.c b/drivers/net/hamradio/baycom_ser_fdx.c
index a974727..636b65c 100644
--- a/drivers/net/hamradio/baycom_ser_fdx.c
+++ b/drivers/net/hamradio/baycom_ser_fdx.c
@@ -445,7 +445,7 @@ static int ser12_open(struct net_device *dev)
 	outb(0, FCR(dev->base_addr));  /* disable FIFOs */
 	outb(0x0d, MCR(dev->base_addr));
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
 			"baycom_ser_fdx", dev)) {
 		release_region(dev->base_addr, SER12_EXTENT);
 		return -EBUSY;
diff --git a/drivers/net/hamradio/baycom_ser_hdx.c b/drivers/net/hamradio/baycom_ser_hdx.c
index e349d86..f9a8976 100644
--- a/drivers/net/hamradio/baycom_ser_hdx.c
+++ b/drivers/net/hamradio/baycom_ser_hdx.c
@@ -490,7 +490,7 @@ static int ser12_open(struct net_device *dev)
 	outb(0, FCR(dev->base_addr));  /* disable FIFOs */
 	outb(0x0d, MCR(dev->base_addr));
 	outb(0, IER(dev->base_addr));
-	if (request_irq(dev->irq, ser12_interrupt, IRQF_DISABLED | IRQF_SHARED,
+	if (request_irq(dev->irq, ser12_interrupt, IRQF_SHARED,
 			"baycom_ser12", dev)) {
 		release_region(dev->base_addr, SER12_EXTENT);       
 		return -EBUSY;
-- 
1.8.1.2
