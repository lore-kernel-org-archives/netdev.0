From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 22/30] net: tulip: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:47 +0200
Message-ID: <1405866475-24754-3-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Grant Grundler <grundler@parisc-linux.org>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/dec/tulip/de4x5.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index c05b66d..7091fa6 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -3250,7 +3250,6 @@ srom_map_media(struct net_device *dev)
 	printk("%s: Bad media code [%d] detected in SROM!\n", dev->name,
 	                                                  lp->infoblock_media);
 	return -1;
-	break;
     }
 
     return 0;
-- 
1.9.1
