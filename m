From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] net: dsa: make some structures const
Date: Tue, 29 Aug 2017 22:17:52 +0530
Message-ID: <1504025272-8304-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these const as they are not modified anywhere.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 2 +-
 drivers/net/dsa/qca8k.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index bbcb405..8492c9d 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -983,7 +983,7 @@ static int bcm_sf2_core_write64(struct b53_device *dev, u8 page, u8 reg,
 	return 0;
 }
 
-static struct b53_io_ops bcm_sf2_io_ops = {
+static const struct b53_io_ops bcm_sf2_io_ops = {
 	.read8	= bcm_sf2_core_read8,
 	.read16	= bcm_sf2_core_read16,
 	.read32	= bcm_sf2_core_read32,
diff --git a/drivers/net/dsa/qca8k.c b/drivers/net/dsa/qca8k.c
index 17977f0..5ada7a41 100644
--- a/drivers/net/dsa/qca8k.c
+++ b/drivers/net/dsa/qca8k.c
@@ -250,7 +250,7 @@
 
 };
 
-static struct regmap_access_table qca8k_readable_table = {
+static const struct regmap_access_table qca8k_readable_table = {
 	.yes_ranges = qca8k_readable_ranges,
 	.n_yes_ranges = ARRAY_SIZE(qca8k_readable_ranges),
 };
-- 
1.9.1
