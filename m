From: Prashant Shah <pshah.mumbai@gmail.com>
Subject: [PATCH] Change request_irq() to use struct net_device *dev->name
Date: Wed, 24 Jul 2013 11:39:59 +0530
Message-ID: <1374646199-9398-1-git-send-email-pshah.mumbai@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kernel-mentors@selenic.com
To: netdev@vger.kernel.org
Return-path: <kernel-mentors-bounces@selenic.com>
List-Unsubscribe: <http://selenic.com/mailman/options/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=unsubscribe>
List-Archive: <http://selenic.com/pipermail/kernel-mentors>
List-Post: <mailto:kernel-mentors@selenic.com>
List-Help: <mailto:kernel-mentors-request@selenic.com?subject=help>
List-Subscribe: <http://selenic.com/mailman/listinfo/kernel-mentors>,
	<mailto:kernel-mentors-request@selenic.com?subject=subscribe>
Sender: kernel-mentors-bounces@selenic.com
Errors-To: kernel-mentors-bounces@selenic.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Prashant Shah <pshah.mumbai@gmail.com>
---
 drivers/net/ethernet/8390/wd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/8390/wd.c b/drivers/net/ethernet/8390/wd.c
index 03eb3ee..b43a63f 100644
--- a/drivers/net/ethernet/8390/wd.c
+++ b/drivers/net/ethernet/8390/wd.c
@@ -308,7 +308,7 @@ static int __init wd_probe1(struct net_device *dev, int ioaddr)
 
 	/* Snarf the interrupt now.  There's no point in waiting since we cannot
 	   share and the board will usually be enabled. */
-	i = request_irq(dev->irq, ei_interrupt, 0, DRV_NAME, dev);
+	i = request_irq(dev->irq, ei_interrupt, 0, dev->name, dev);
 	if (i) {
 		printk (" unable to get IRQ %d.\n", dev->irq);
 		return i;
-- 
1.7.9.5
