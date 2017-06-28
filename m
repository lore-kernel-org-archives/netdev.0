From: Colin King <colin.king@canonical.com>
Subject: [PATCH] amd-xgbe: fix spelling mistake: "avialable" -> "available"
Date: Wed, 28 Jun 2017 17:51:10 +0100
Message-ID: <20170628165110.29130-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Tom Lendacky <thomas.lendacky@amd.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake in netdev_err message

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 920566a3a599..67a2e52ad25d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -247,7 +247,7 @@ static int xgbe_set_pauseparam(struct net_device *netdev,
 
 	if (pause->autoneg && (pdata->phy.autoneg != AUTONEG_ENABLE)) {
 		netdev_err(netdev,
-			   "autoneg disabled, pause autoneg not avialable\n");
+			   "autoneg disabled, pause autoneg not available\n");
 		return -EINVAL;
 	}
 
-- 
2.11.0
