From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 2/2] r8169: fix setting rx vlan
Date: Fri, 12 Sep 2014 11:35:12 +0800
Message-ID: <1394712342-15778-40-Taiwan-albertk@realtek.com>
References: <1394712342-15778-38-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-38-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The setting should depend on the new features not the current one.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f3ce284..7a7860a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1796,7 +1796,7 @@ static void __rtl8169_set_features(struct net_device *dev,
 		else
 			tp->cp_cmd &= ~RxChkSum;
 
-		if (dev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		if (features & NETIF_F_HW_VLAN_CTAG_RX)
 			tp->cp_cmd |= RxVlan;
 		else
 			tp->cp_cmd &= ~RxVlan;
-- 
1.9.3
