From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH 2/2] drivers: net: emac: add const to mii_phy_ops structures
Date: Thu,  8 Jun 2017 11:30:58 +0530
Message-ID: <1496901658-6476-3-git-send-email-bhumirks@gmail.com>
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
 drivers/net/ethernet/ibm/emac/phy.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ibm/emac/phy.c b/drivers/net/ethernet/ibm/emac/phy.c
index 5b88cc6..35865d0 100644
--- a/drivers/net/ethernet/ibm/emac/phy.c
+++ b/drivers/net/ethernet/ibm/emac/phy.c
@@ -276,7 +276,7 @@ static int genmii_read_link(struct mii_phy *phy)
 }
 
 /* Generic implementation for most 10/100/1000 PHYs */
-static struct mii_phy_ops generic_phy_ops = {
+static const struct mii_phy_ops generic_phy_ops = {
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
 	.poll_link	= genmii_poll_link,
@@ -340,7 +340,7 @@ static int cis8201_init(struct mii_phy *phy)
 	return 0;
 }
 
-static struct mii_phy_ops cis8201_phy_ops = {
+static const struct mii_phy_ops cis8201_phy_ops = {
 	.init		= cis8201_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
@@ -420,7 +420,7 @@ static int et1011c_init(struct mii_phy *phy)
 	return 0;
 }
 
-static struct mii_phy_ops et1011c_phy_ops = {
+static const struct mii_phy_ops et1011c_phy_ops = {
 	.init		= et1011c_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
@@ -439,7 +439,7 @@ static struct mii_phy_def et1011c_phy_def = {
 
 
 
-static struct mii_phy_ops m88e1111_phy_ops = {
+static const struct mii_phy_ops m88e1111_phy_ops = {
 	.init		= m88e1111_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
@@ -455,7 +455,7 @@ static struct mii_phy_def m88e1111_phy_def = {
 	.ops		= &m88e1111_phy_ops,
 };
 
-static struct mii_phy_ops m88e1112_phy_ops = {
+static const struct mii_phy_ops m88e1112_phy_ops = {
 	.init		= m88e1112_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
@@ -480,7 +480,7 @@ static int ar8035_init(struct mii_phy *phy)
 	return 0;
 }
 
-static struct mii_phy_ops ar8035_phy_ops = {
+static const struct mii_phy_ops ar8035_phy_ops = {
 	.init		= ar8035_init,
 	.setup_aneg	= genmii_setup_aneg,
 	.setup_forced	= genmii_setup_forced,
-- 
2.7.4
