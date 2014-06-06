From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] net: use SPEED_UNKNOWN and DUPLEX_UNKNOWN when appropriate
Date: Fri,  6 Jun 2014 14:17:00 +0200
Message-ID: <1402057021-12867-2-git-send-email-jiri@resnulli.us>
References: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jeffrey.t.kirsher@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:39090 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751706AbaFFMRH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2014 08:17:07 -0400
Received: by mail-wi0-f177.google.com with SMTP id f8so862061wiw.16
        for <netdev@vger.kernel.org>; Fri, 06 Jun 2014 05:17:06 -0700 (PDT)
In-Reply-To: <1402057021-12867-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c      | 4 ++--
 drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c      | 4 ++--
 drivers/net/ethernet/atheros/atlx/atl1.c                | 4 ++--
 drivers/net/ethernet/atheros/atlx/atl2.c                | 4 ++--
 drivers/net/ethernet/broadcom/bnx2.c                    | 4 ++--
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c         | 4 ++--
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c               | 4 ++--
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c         | 4 ++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c          | 4 ++--
 drivers/net/ethernet/dec/tulip/uli526x.c                | 4 ++--
 drivers/net/ethernet/dlink/dl2k.c                       | 4 ++--
 drivers/net/ethernet/ibm/ehea/ehea_ethtool.c            | 4 ++--
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c        | 4 ++--
 drivers/net/ethernet/intel/e1000e/ethtool.c             | 4 ++--
 drivers/net/ethernet/intel/igb/igb_ethtool.c            | 4 ++--
 drivers/net/ethernet/intel/igbvf/ethtool.c              | 4 ++--
 drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c          | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c        | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ethtool.c            | 4 ++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c         | 4 ++--
 drivers/net/ethernet/neterion/s2io.c                    | 4 ++--
 drivers/net/ethernet/neterion/vxge/vxge-ethtool.c       | 4 ++--
 drivers/net/ethernet/nvidia/forcedeth.c                 | 4 ++--
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c | 2 +-
 drivers/net/vmxnet3/vmxnet3_ethtool.c                   | 4 ++--
 25 files changed, 49 insertions(+), 49 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
index ecacaae..48694c2 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_ethtool.c
@@ -56,8 +56,8 @@ static int atl1c_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
index 206e9b7..1be072f 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_ethtool.c
@@ -57,8 +57,8 @@ static int atl1e_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index dfd0e91..b460db7 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -3258,8 +3258,8 @@ static int atl1_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 	if (hw->media_type == MEDIA_TYPE_AUTO_SENSOR ||
 	    hw->media_type == MEDIA_TYPE_1000M_FULL)
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 2587fed..6746bd7 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -1769,8 +1769,8 @@ static int atl2_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 0ab8370..67d2b00 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6916,8 +6916,8 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 	}
 	else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 	spin_unlock_bh(&bp->phy_lock);
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index adca62b..882cad7 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -266,8 +266,8 @@ bnad_get_settings(struct net_device *netdev, struct ethtool_cmd *cmd)
 		ethtool_cmd_speed_set(cmd, SPEED_10000);
 		cmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 	cmd->transceiver = XCVR_EXTERNAL;
 	cmd->maxtxpkt = 0;
diff --git a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
index c1b2c1d..3784a8b 100644
--- a/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
+++ b/drivers/net/ethernet/chelsio/cxgb/cxgb2.c
@@ -580,8 +580,8 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		ethtool_cmd_speed_set(cmd, p->link_config.speed);
 		cmd->duplex = p->link_config.duplex;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 3ed5079..5d9cce0 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -1809,8 +1809,8 @@ static int get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		ethtool_cmd_speed_set(cmd, p->link_config.speed);
 		cmd->duplex = p->link_config.duplex;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	cmd->port = (cmd->supported & SUPPORTED_TP) ? PORT_TP : PORT_FIBRE;
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 1882db2..2e50b54 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -104,8 +104,8 @@ static int enic_get_settings(struct net_device *netdev,
 		ethtool_cmd_speed_set(ecmd, vnic_dev_port_speed(enic->vdev));
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/ethernet/dec/tulip/uli526x.c b/drivers/net/ethernet/dec/tulip/uli526x.c
index aa801a6..80afec3 100644
--- a/drivers/net/ethernet/dec/tulip/uli526x.c
+++ b/drivers/net/ethernet/dec/tulip/uli526x.c
@@ -962,8 +962,8 @@ ULi_ethtool_gset(struct uli526x_board_info *db, struct ethtool_cmd *ecmd)
 	}
 	if(db->link_failed)
 	{
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	if (db->media_mode & ULI526X_AUTO)
diff --git a/drivers/net/ethernet/dlink/dl2k.c b/drivers/net/ethernet/dlink/dl2k.c
index 2324f2d..1274b6f 100644
--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1185,8 +1185,8 @@ static int rio_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		ethtool_cmd_speed_set(cmd, np->speed);
 		cmd->duplex = np->full_duplex ? DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 	if ( np->an_enable)
 		cmd->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
index 6055e3e..85a3866 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_ethtool.c
@@ -63,8 +63,8 @@ static int ehea_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		cmd->duplex = port->full_duplex == 1 ?
 						     DUPLEX_FULL : DUPLEX_HALF;
 	} else {
-		speed = ~0;
-		cmd->duplex = -1;
+		speed = SPEED_UNKNOWN;
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 	ethtool_cmd_speed_set(cmd, speed);
 
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 08b207d..d50f78a 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -168,8 +168,8 @@ static int e1000_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = ((hw->media_type == e1000_media_type_fiber) ||
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index e9a48bb..815e26c 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -159,8 +159,8 @@ static int e1000_get_settings(struct net_device *netdev,
 		ecmd->transceiver = XCVR_EXTERNAL;
 	}
 
-	speed = -1;
-	ecmd->duplex = -1;
+	speed = SPEED_UNKNOWN;
+	ecmd->duplex = DUPLEX_UNKNOWN;
 
 	if (netif_running(netdev)) {
 		if (netif_carrier_ok(netdev)) {
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 80e3763..fca9a0e 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -229,8 +229,8 @@ static int igb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ecmd->speed = -1;
-		ecmd->duplex = -1;
+		ecmd->speed = SPEED_UNKNOWN;
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 	if ((hw->phy.media_type == e1000_media_type_fiber) ||
 	    hw->mac.autoneg)
diff --git a/drivers/net/ethernet/intel/igbvf/ethtool.c b/drivers/net/ethernet/intel/igbvf/ethtool.c
index 7d4e855..2178f87 100644
--- a/drivers/net/ethernet/intel/igbvf/ethtool.c
+++ b/drivers/net/ethernet/intel/igbvf/ethtool.c
@@ -101,8 +101,8 @@ static int igbvf_get_settings(struct net_device *netdev,
 		else
 			ecmd->duplex = DUPLEX_HALF;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
index 1da2d98..b311e9e 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -107,8 +107,8 @@ ixgb_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ethtool_cmd_speed_set(ecmd, SPEED_10000);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	ecmd->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 23e4e6a..a452730 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -296,8 +296,8 @@ static int ixgbe_get_settings(struct net_device *netdev,
 		}
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index a757f07..d420f12 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -135,8 +135,8 @@ static int ixgbevf_get_settings(struct net_device *netdev,
 		ethtool_cmd_speed_set(ecmd, speed);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index c021c96..fa1a069 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -378,8 +378,8 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		ethtool_cmd_speed_set(cmd, priv->port_state.link_speed);
 		cmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(cmd, -1);
-		cmd->duplex = -1;
+		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
+		cmd->duplex = DUPLEX_UNKNOWN;
 	}
 
 	if (trans_type > 0 && trans_type <= 0xC) {
diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index e3cf38e..be58764 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -5360,8 +5360,8 @@ static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 		ethtool_cmd_speed_set(info, SPEED_10000);
 		info->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(info, -1);
-		info->duplex = -1;
+		ethtool_cmd_speed_set(info, SPEED_UNKNOWN);
+		info->duplex = DUPLEX_UNKNOWN;
 	}
 
 	info->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
index ddcc81a..b07d552 100644
--- a/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
+++ b/drivers/net/ethernet/neterion/vxge/vxge-ethtool.c
@@ -62,8 +62,8 @@ static int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 		ethtool_cmd_speed_set(info, SPEED_10000);
 		info->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(info, -1);
-		info->duplex = -1;
+		ethtool_cmd_speed_set(info, SPEED_UNKNOWN);
+		info->duplex = DUPLEX_UNKNOWN;
 	}
 
 	info->autoneg = AUTONEG_DISABLE;
diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 6f255f5..9afc536 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -4285,8 +4285,8 @@ static int nv_get_settings(struct net_device *dev, struct ethtool_cmd *ecmd)
 		if (np->duplex)
 			ecmd->duplex = DUPLEX_FULL;
 	} else {
-		speed = -1;
-		ecmd->duplex = -1;
+		speed = SPEED_UNKNOWN;
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 	ethtool_cmd_speed_set(ecmd, speed);
 	ecmd->autoneg = np->autoneg;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
index 114d2fe..4fe8ea9 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_ethtool.c
@@ -91,7 +91,7 @@ static int pch_gbe_get_settings(struct net_device *netdev,
 	ecmd->advertising &= ~(ADVERTISED_TP | ADVERTISED_1000baseT_Half);
 
 	if (!netif_carrier_ok(adapter->netdev))
-		ethtool_cmd_speed_set(ecmd, -1);
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
 	return ret;
 }
 
diff --git a/drivers/net/vmxnet3/vmxnet3_ethtool.c b/drivers/net/vmxnet3/vmxnet3_ethtool.c
index 9396cca..40c1c7b 100644
--- a/drivers/net/vmxnet3/vmxnet3_ethtool.c
+++ b/drivers/net/vmxnet3/vmxnet3_ethtool.c
@@ -431,8 +431,8 @@ vmxnet3_get_settings(struct net_device *netdev, struct ethtool_cmd *ecmd)
 		ethtool_cmd_speed_set(ecmd, adapter->link_speed);
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(ecmd, -1);
-		ecmd->duplex = -1;
+		ethtool_cmd_speed_set(ecmd, SPEED_UNKNOWN);
+		ecmd->duplex = DUPLEX_UNKNOWN;
 	}
 	return 0;
 }
-- 
1.9.0
