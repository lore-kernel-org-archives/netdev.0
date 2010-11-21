From: Joe Perches <joe@perches.com>
Subject: [PATCH 20/62] eexpress: Use static const
Date: Sat, 20 Nov 2010 18:38:21 -0800
Message-ID: <58f58a1c0786269a4369629c7ef7debe7adf3b02.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philip Blundell <philb@gnu.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  20165	     73	   4400	  24638	   603e	drivers/net/eexpress.o.new
  20165	     73	   4400	  24638	   603e	drivers/net/eexpress.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/eexpress.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/eexpress.c b/drivers/net/eexpress.c
index 12c37d2..48ee51b 100644
--- a/drivers/net/eexpress.c
+++ b/drivers/net/eexpress.c
@@ -1103,7 +1103,7 @@ static int __init eexp_hw_probe(struct net_device *dev, unsigned short ioaddr)
 		dev->dev_addr[i] = ((unsigned char *)hw_addr)[5-i];
 
 	{
-		static char irqmap[]={0, 9, 3, 4, 5, 10, 11, 0};
+		static const char irqmap[] = { 0, 9, 3, 4, 5, 10, 11, 0 };
 		unsigned short setupval = eexp_hw_readeeprom(ioaddr,0);
 
 		/* Use the IRQ from EEPROM if none was given */
-- 
1.7.3.2.245.g03276.dirty
