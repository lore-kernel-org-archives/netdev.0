From: Balavasu <kp.balavasu@gmail.com>
Subject: [PATCH] staging: octeon: Replace memcpy with ETH_ALEN
Date: Sat, 18 Oct 2014 00:17:05 +0530
Message-ID: <20141017184705.GA17944@vasu-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the checkpatch.pl issue
WARNING: memcpy(dev->dev_addr, mac, ETH_ALEN);

Signed-off-by: Balavasu <kp.balavasu@gmail.com>
---
 drivers/staging/octeon/ethernet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 8f9e3fb..47d4277 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -452,7 +452,7 @@ int cvm_oct_common_init(struct net_device *dev)
 		mac = of_get_mac_address(priv->of_node);
 
 	if (mac)
-		memcpy(dev->dev_addr, mac, ETH_ALEN);
+		ether_addr_copy(dev->dev_addr, mac);
 	else
 		eth_hw_addr_random(dev);
 
-- 
1.9.1
