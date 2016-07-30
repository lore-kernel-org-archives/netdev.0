From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: tulip: fix spelling mistake: "attemping" -> "attempting"
Date: Sat, 30 Jul 2016 17:47:07 +0100
Message-ID: <1469897227-5476-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>,
	Antonio Quartulli <a@unstable.cc>,
	Felipe Balbi <felipe.balbi@linux.intel.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org
Return-path: <linux-parisc-owner@vger.kernel.org>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake in printk message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/dec/tulip/de4x5.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index cbe8497..f0e9e2e 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -1319,7 +1319,7 @@ de4x5_open(struct net_device *dev)
 
     if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 		                                     lp->adapter_name, dev)) {
-	printk("de4x5_open(): Requested IRQ%d is busy - attemping FAST/SHARE...", dev->irq);
+	printk("de4x5_open(): Requested IRQ%d is busy - attempting FAST/SHARE...", dev->irq);
 	if (request_irq(dev->irq, de4x5_interrupt, IRQF_SHARED,
 			                             lp->adapter_name, dev)) {
 	    printk("\n              Cannot get IRQ- reconfigure your hardware.\n");
-- 
2.8.1

