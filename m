From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 1/2] drivers/net/sungem: add const to mii_phy_ops structures
Date: Thu,  8 Jun 2017 11:30:57 +0530
Message-ID: <1496901658-6476-2-git-send-email-bhumirks@gmail.com>
References: <1496901658-6476-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com,
        davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1496901658-6476-1-git-send-email-bhumirks@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The object references of mii_phy_ops structures are only stored
in the ops field of a mii_phy_def structure. This ops field is of type
const. So, mii_phy_ops structures having similar properties can be
declared as const.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/sungem_phy.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 92578d72..63a8ff8 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -886,7 +886,7 @@ static int marvell_read_link(struct mii_phy *phy)
 	 SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)
 
 /* Broadcom BCM 5201 */
-static struct mii_phy_ops bcm5201_phy_ops = {
+static const struct mii_phy_ops bcm5201_phy_ops = {
 	.init		= bcm5201_init,
 	.suspend	= bcm5201_suspend,
 	.setup_aneg	= genmii_setup_aneg,
@@ -905,7 +905,7 @@ static struct mii_phy_def bcm5201_phy_def = {
 };
 
 /* Broadcom BCM 5221 */
-static struct mii_phy_ops bcm5221_phy_ops = {
+static const struct mii_phy_ops bcm5221_phy_ops = {
 	.suspend	= bcm5221_suspend,
 	.init		= bcm5221_init,
 	.setup_aneg	= genmii_setup_aneg,
@@ -924,7 +924,7 @@ static struct mii_phy_def bcm5221_phy_def = {
 };
 
 /* Broadcom BCM 5241 */
-static struct mii_phy_ops bcm5241_phy_ops = {
+static const struct mii_phy_ops bcm5241_phy_ops = {
 	.suspend	= bcm5241_suspend,
 	.init		= bcm5241_init,
 	.setup_aneg	= genmii_setup_aneg,
@@ -942,7 +942,7 @@ static struct mii_phy_def bcm5241_phy_def = {
 };
 
 /* Broadcom BCM 5400 */
-static struct mii_phy_ops bcm5400_phy_ops = {
+static const struct mii_phy_ops bcm5400_phy_ops = {
 	.init		= bcm5400_init,
 	.suspend	= bcm5400_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -961,7 +961,7 @@ static struct mii_phy_def bcm5400_phy_def = {
 };
 
 /* Broadcom BCM 5401 */
-static struct mii_phy_ops bcm5401_phy_ops = {
+static const struct mii_phy_ops bcm5401_phy_ops = {
 	.init		= bcm5401_init,
 	.suspend	= bcm5401_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -980,7 +980,7 @@ static struct mii_phy_def bcm5401_phy_def = {
 };
 
 /* Broadcom BCM 5411 */
-static struct mii_phy_ops bcm5411_phy_ops = {
+static const struct mii_phy_ops bcm5411_phy_ops = {
 	.init		= bcm5411_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -999,7 +999,7 @@ static struct mii_phy_def bcm5411_phy_def = {
 };
 
 /* Broadcom BCM 5421 */
-static struct mii_phy_ops bcm5421_phy_ops = {
+static const struct mii_phy_ops bcm5421_phy_ops = {
 	.init		= bcm5421_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -1019,7 +1019,7 @@ static struct mii_phy_def bcm5421_phy_def = {
 };
 
 /* Broadcom BCM 5421 built-in K2 */
-static struct mii_phy_ops bcm5421k2_phy_ops = {
+static const struct mii_phy_ops bcm5421k2_phy_ops = {
 	.init		= bcm5421_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -1037,7 +1037,7 @@ static struct mii_phy_def bcm5421k2_phy_def = {
 	.ops		= &bcm5421k2_phy_ops
 };
 
-static struct mii_phy_ops bcm5461_phy_ops = {
+static const struct mii_phy_ops bcm5461_phy_ops = {
 	.init		= bcm5421_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -1057,7 +1057,7 @@ static struct mii_phy_def bcm5461_phy_def = {
 };
 
 /* Broadcom BCM 5462 built-in Vesta */
-static struct mii_phy_ops bcm5462V_phy_ops = {
+static const struct mii_phy_ops bcm5462V_phy_ops = {
 	.init		= bcm5421_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= bcm54xx_setup_aneg,
@@ -1076,7 +1076,7 @@ static struct mii_phy_def bcm5462V_phy_def = {
 };
 
 /* Marvell 88E1101 amd 88E1111 */
-static struct mii_phy_ops marvell88e1101_phy_ops = {
+static const struct mii_phy_ops marvell88e1101_phy_ops = {
 	.suspend	= generic_suspend,
 	.setup_aneg	= marvell_setup_aneg,
 	.setup_forced	= marvell_setup_forced,
@@ -1084,7 +1084,7 @@ static struct mii_phy_ops marvell88e1101_phy_ops = {
 	.read_link	= marvell_read_link
 };
 
-static struct mii_phy_ops marvell88e1111_phy_ops = {
+static const struct mii_phy_ops marvell88e1111_phy_ops = {
 	.init		= marvell88e1111_init,
 	.suspend	= generic_suspend,
 	.setup_aneg	= marvell_setup_aneg,
@@ -1122,7 +1122,7 @@ static struct mii_phy_def marvell88e1111_phy_def = {
 };
 
 /* Generic implementation for most 10/100 PHYs */
-static struct mii_phy_ops generic_phy_ops = {
+static const struct mii_phy_ops generic_phy_ops = {
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
 	.poll_link	= genmii_poll_link,
-- 
2.7.4
