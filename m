From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 02/30] eth_v10: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:16:10 +0200
Message-ID: <1405865801-18806-3-git-send-email-fabf@skynet.be>
References: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405865801-18806-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/cris/eth_v10.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 29e272c..64c016a 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -1496,7 +1496,6 @@ e100_set_config(struct net_device *dev, struct ifmap *map)
 		case IF_PORT_AUI:
 			spin_unlock(&np->lock);
 			return -EOPNOTSUPP;
-			break;
 		default:
 			printk(KERN_ERR "%s: Invalid media selected", dev->name);
 			spin_unlock(&np->lock);
-- 
1.9.1
