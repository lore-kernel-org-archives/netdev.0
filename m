From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: mdio-gpio: make mdiobb_ops const
Date: Tue, 22 Aug 2017 13:43:29 +0530
Message-ID: <1503389609-17490-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, andrew@lunn.ch, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make this const as it is only stored in a const field of a
mdiobb_ctrl structure.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/phy/mdio-gpio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/phy/mdio-gpio.c b/drivers/net/phy/mdio-gpio.c
index 7faa79b..4333c6e 100644
--- a/drivers/net/phy/mdio-gpio.c
+++ b/drivers/net/phy/mdio-gpio.c
@@ -116,7 +116,7 @@ static void mdc_set(struct mdiobb_ctrl *ctrl, int what)
 	gpiod_set_value(bitbang->mdc, what);
 }
 
-static struct mdiobb_ops mdio_gpio_ops = {
+static const struct mdiobb_ops mdio_gpio_ops = {
 	.owner = THIS_MODULE,
 	.set_mdc = mdc_set,
 	.set_mdio_dir = mdio_dir,
-- 
1.9.1
