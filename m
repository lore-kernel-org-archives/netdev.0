From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 09/50] Cadence MACB: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:16 +0100
Message-ID: <1328735457-29986-10-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/cadence/macb.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 2320068..3ee8d79 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -87,7 +87,7 @@ static void __init macb_get_hwaddr(struct macb *bp)
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
 	} else {
 		netdev_info(bp->dev, "invalid hw address, using random\n");
-		random_ether_addr(bp->dev->dev_addr);
+		dev_hw_addr_random(bp->dev, bp->dev->dev_addr);
 	}
 }
 
-- 
1.7.7.3
