From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/11] drivers/net/ax88796.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:02 -0800
Message-ID: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe__27575.6720257506$1197671711$gmane$org@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934001AbXLNWeo@vger.kernel.org>
Message-Id: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ax88796.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 7495a9e..107c11f 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -750,14 +750,10 @@ static int ax_init_dev(struct net_device *dev, int first_init)
 	ax_NS8390_init(dev, 0);
 
 	if (first_init) {
-		printk("AX88796: %dbit, irq %d, %lx, MAC: ",
-		       ei_status.word16 ? 16:8, dev->irq, dev->base_addr);
-
-		for (i = 0; i < ETHER_ADDR_LEN; i++)
-			printk("%2.2x%c", dev->dev_addr[i],
-			       (i < (ETHER_ADDR_LEN-1) ? ':' : ' '));
