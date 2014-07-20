From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 24/30] sis900: remove unnecessary break after return
Date: Sun, 20 Jul 2014 16:27:49 +0200
Message-ID: <1405866475-24754-5-git-send-email-fabf@skynet.be>
References: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405866475-24754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/sis/sis900.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 6072f09..7bea17c 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -2258,7 +2258,6 @@ static int sis900_set_config(struct net_device *dev, struct ifmap *map)
 		case IF_PORT_100BASEFX: /* 100BaseFx */
                 	/* These Modes are not supported (are they?)*/
 			return -EOPNOTSUPP;
-			break;
 
 		default:
 			return -EINVAL;
-- 
1.9.1
