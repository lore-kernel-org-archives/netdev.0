From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 19/50] macsonic: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:26 +0100
Message-ID: <1328735457-29986-20-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Wan ZongShun <mcuos.com@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Finn Thain <fthain@telegraphics.com.au>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/natsemi/macsonic.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/natsemi/macsonic.c b/drivers/net/ethernet/natsemi/macsonic.c
index f1b8556..c3819dc 100644
--- a/drivers/net/ethernet/natsemi/macsonic.c
+++ b/drivers/net/ethernet/natsemi/macsonic.c
@@ -307,7 +307,7 @@ static void __devinit mac_onboard_sonic_ethernet_addr(struct net_device *dev)
 
 	printk(KERN_WARNING "macsonic: MAC address in CAM entry 15 "
 	                    "seems invalid, will use a random MAC\n");
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 }
 
 static int __devinit mac_onboard_sonic_probe(struct net_device *dev)
-- 
1.7.7.3
