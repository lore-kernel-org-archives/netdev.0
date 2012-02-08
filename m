From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 13/50] dnet: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:20 +0100
Message-ID: <1328735457-29986-14-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Richard Cochran <richard.cochran@omicron.at>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Wan ZongShun <mcuos.com@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/dnet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/dnet.c b/drivers/net/ethernet/dnet.c
index 925c9ba..9f88165 100644
--- a/drivers/net/ethernet/dnet.c
+++ b/drivers/net/ethernet/dnet.c
@@ -897,7 +897,7 @@ static int __devinit dnet_probe(struct platform_device *pdev)
 
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		/* choose a random ethernet address */
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 		__dnet_set_hwaddr(bp);
 	}
 
-- 
1.7.7.3
