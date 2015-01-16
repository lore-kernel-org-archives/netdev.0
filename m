From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 01/12] amd-xgbe: Checkpatch fixes
Date: Fri, 16 Jan 2015 12:46:24 -0600
Message-ID: <20150116184624.18809.20731.stgit@tlendack-t1.amdoffice.net>
References: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [165.204.77.2] ([165.204.77.2]:44027 "EHLO
	tlendack-t1.amdoffice.net" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756797AbbAPSya (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 13:54:30 -0500
In-Reply-To: <20150116184618.18809.319.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set of patches resolves some checks reported by the checkpatch
tool.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-drv.c     |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe-mdio.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
index 76479d0..2c063b6 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-debugfs.c
@@ -328,7 +328,7 @@ void xgbe_debugfs_init(struct xgbe_prv_data *pdata)
 
 	buf = kasprintf(GFP_KERNEL, "amd-xgbe-%s", pdata->netdev->name);
 	pdata->xgbe_debugfs = debugfs_create_dir(buf, NULL);
-	if (pdata->xgbe_debugfs == NULL) {
+	if (!pdata->xgbe_debugfs) {
 		netdev_err(pdata->netdev, "debugfs_create_dir failed\n");
 		return;
 	}
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
index 2ba1dd2..e2e9217 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-drv.c
@@ -692,7 +692,7 @@ static void xgbe_adjust_link(struct net_device *netdev)
 	struct phy_device *phydev = pdata->phydev;
 	int new_state = 0;
 
-	if (phydev == NULL)
+	if (!phydev)
 		return;
 
 	if (phydev->link) {
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
index 363b210..7eeb03d 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
@@ -220,7 +220,7 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
 	}
 
 	mii = mdiobus_alloc();
-	if (mii == NULL) {
+	if (!mii) {
 		dev_err(pdata->dev, "mdiobus_alloc failed\n");
 		ret = -ENOMEM;
 		goto err_node_get;
