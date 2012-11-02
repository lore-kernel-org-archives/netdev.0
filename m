From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial] net: bnx2x: Fix typo in bnx2x driver
Date: Fri,  2 Nov 2012 23:36:17 +0900
Message-ID: <1351866977-6251-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kernel@vger.kernel.org,
	eilong@broadcom.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo in bnx2x driver

Signed-off-by: Masanari Iida <standby24x7@gmail.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c    | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c65295d..6e5bdd1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1702,7 +1702,7 @@ static int bnx2x_set_eee(struct net_device *dev, struct ethtool_eee *edata)
 				      SHMEM_EEE_ADV_STATUS_SHIFT);
 	if ((advertised != (eee_cfg & SHMEM_EEE_ADV_STATUS_MASK))) {
 		DP(BNX2X_MSG_ETHTOOL,
-		   "Direct manipulation of EEE advertisment is not supported\n");
+		   "Direct manipulation of EEE advertisement is not supported\n");
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index e2e45ee..5be223e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9878,7 +9878,7 @@ static int bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 		else
 			rc = bnx2x_8483x_disable_eee(phy, params, vars);
 		if (rc) {
-			DP(NETIF_MSG_LINK, "Failed to set EEE advertisment\n");
+			DP(NETIF_MSG_LINK, "Failed to set EEE advertisement\n");
 			return rc;
 		}
 	} else {
@@ -12919,7 +12919,7 @@ static u8 bnx2x_analyze_link_error(struct link_params *params,
 		DP(NETIF_MSG_LINK, "Analyze TX Fault\n");
 		break;
 	default:
-		DP(NETIF_MSG_LINK, "Analyze UNKOWN\n");
+		DP(NETIF_MSG_LINK, "Analyze UNKNOWN\n");
 	}
 	DP(NETIF_MSG_LINK, "Link changed:[%x %x]->%x\n", vars->link_up,
 	   old_status, status);
-- 
1.8.0.rc3.16.g8ead1bf
