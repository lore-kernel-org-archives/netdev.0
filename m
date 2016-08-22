From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH] phy: micrel: Reenable interrupts during resume for ksz9031
Date: Mon, 22 Aug 2016 15:57:16 -0500
Message-ID: <1471899436-56626-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        brad.mouring@ni.com, nathan.sullivan@ni.com, xander.huff@ni.com
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Like the ksz8081, the ksz9031 has the behavior where it will clear the
interrupt enable bits when leaving power down. This takes advantage of the
solution provided by f5aba91.

Signed-off-by: Xander Huff <xander.huff@ni.com>
Signed-off-by: Nathan Sullivan <nathan.sullivan@ni.com>
---
 drivers/net/phy/micrel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
index 053e879..885ac9c 100644
--- a/drivers/net/phy/micrel.c
+++ b/drivers/net/phy/micrel.c
@@ -964,7 +964,7 @@ static struct phy_driver ksphy_driver[] = {
 	.get_strings	= kszphy_get_strings,
 	.get_stats	= kszphy_get_stats,
 	.suspend	= genphy_suspend,
-	.resume		= genphy_resume,
+	.resume		= kszphy_resume,
 }, {
 	.phy_id		= PHY_ID_KSZ8873MLL,
 	.phy_id_mask	= MICREL_PHY_ID_MASK,
-- 
1.9.1
