From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/4] net/mlx4_core: Fix sl_to_vl_change bit offset in flags2 dump
Date: Tue,  1 Aug 2017 16:43:44 +0300
Message-ID: <1501595026-32368-3-git-send-email-tariqt@mellanox.com>
References: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Jack Morgenstein <jackm@dev.mellanox.co.il>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43038 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751865AbdHANog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 09:44:36 -0400
In-Reply-To: <1501595026-32368-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jack Morgenstein <jackm@dev.mellanox.co.il>

The index value in function dump_dev_cap_flags2() for outputting
"sl to vl mapping table change event support" needs to be
consistent with the value of the enumerated constant
MLX4_DEV_CAP_FLAG2_SL_TO_VL_CHANGE_EVENT defined in file
include/linux/mlx4_device.h

The change here restores that consistency.

Fixes: fd10ed8e6f42 ("IB/mlx4: Fix possible vl/sl field mismatch in LRH header in QP1 packets")
Reported-by: Mukesh Kacker <mukesh.kacker@oracle.com>
Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index c165f16623a9..009dd03466d6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -160,7 +160,7 @@ static void dump_dev_cap_flags2(struct mlx4_dev *dev, u64 flags)
 		[33] = "RoCEv2 support",
 		[34] = "DMFS Sniffer support (UC & MC)",
 		[35] = "QinQ VST mode support",
-		[36] = "sl to vl mapping table change event support"
+		[37] = "sl to vl mapping table change event support",
 	};
 	int i;
 
-- 
1.8.3.1
