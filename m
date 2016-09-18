From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] phy: mark lan88xx_suspend() static
Date: Sun, 18 Sep 2016 16:26:34 +0800
Message-ID: <1474187194-21322-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/phy/microchip.c:58:5: warning: no previous prototype for 'lan88xx_suspend' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/phy/microchip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/microchip.c b/drivers/net/phy/microchip.c
index 15f8206..7c00e50 100644
--- a/drivers/net/phy/microchip.c
+++ b/drivers/net/phy/microchip.c
@@ -55,7 +55,7 @@ static int lan88xx_phy_ack_interrupt(struct phy_device *phydev)
 	return rc < 0 ? rc : 0;
 }
 
-int lan88xx_suspend(struct phy_device *phydev)
+static int lan88xx_suspend(struct phy_device *phydev)
 {
 	struct lan88xx_priv *priv = phydev->priv;
 
-- 
2.7.4
