From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum: Change ipv6 unregistered mc table
Date: Mon, 13 Feb 2017 21:03:02 +0100
Message-ID: <1487016182-1896-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36159 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751578AbdBMUDF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 15:03:05 -0500
Received: by mail-wr0-f195.google.com with SMTP id k90so25449810wrc.3
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 12:03:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Point back the unregister IPv6 mc table to the bc table.
It is done since IPv6 mcast snooping is not supported for Spectrum yet.

Reported-by: Jiri Pirko <jiri@mellanox.com>
Fixes: 71c365bdc439 ("mlxsw: spectrum: Separate bc and mc floods")
Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Tested-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 37c018b..16484f2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3078,7 +3078,6 @@ static int __mlxsw_sp_flood_init(struct mlxsw_core *mlxsw_core,
 		flood_table = MLXSW_SP_FLOOD_TABLE_UC;
 		break;
 	case MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4:
-	case MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6:
 		flood_table = MLXSW_SP_FLOOD_TABLE_MC;
 		break;
 	default:
-- 
2.7.4
