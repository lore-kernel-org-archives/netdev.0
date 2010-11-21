From: Joe Perches <joe@perches.com>
Subject: [PATCH 05/62] at1700: Use static const
Date: Sat, 20 Nov 2010 18:38:06 -0800
Message-ID: <eeec670c8100c9b6c6dcf60f15806b635e129b39.1290305775.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
   9083	    370	   2232	  11685	   2da5	drivers/net/at1700.o.new
   9167	    370	   2232	  11769	   2df9	drivers/net/at1700.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/at1700.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/at1700.c b/drivers/net/at1700.c
index 871b163..f4744fc 100644
--- a/drivers/net/at1700.c
+++ b/drivers/net/at1700.c
@@ -270,9 +270,9 @@ static const struct net_device_ops at1700_netdev_ops = {
 
 static int __init at1700_probe1(struct net_device *dev, int ioaddr)
 {
-	char fmv_irqmap[4] = {3, 7, 10, 15};
-	char fmv_irqmap_pnp[8] = {3, 4, 5, 7, 9, 10, 11, 15};
-	char at1700_irqmap[8] = {3, 4, 5, 9, 10, 11, 14, 15};
+	static const char fmv_irqmap[4] = {3, 7, 10, 15};
+	static const char fmv_irqmap_pnp[8] = {3, 4, 5, 7, 9, 10, 11, 15};
+	static const char at1700_irqmap[8] = {3, 4, 5, 9, 10, 11, 14, 15};
 	unsigned int i, irq, is_fmv18x = 0, is_at1700 = 0;
 	int slot, ret = -ENODEV;
 	struct net_local *lp = netdev_priv(dev);
-- 
1.7.3.2.245.g03276.dirty
