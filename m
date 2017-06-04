From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: Fix typo inside enumeration
Date: Sun,  4 Jun 2017 16:53:39 +0200
Message-ID: <20170604145340.14447-3-jiri@resnulli.us>
References: <20170604145340.14447-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33659 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751267AbdFDOxp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 10:53:45 -0400
Received: by mail-wr0-f193.google.com with SMTP id v104so5317356wrb.0
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 07:53:45 -0700 (PDT)
In-Reply-To: <20170604145340.14447-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reviewed-by: Petr Machata <petrm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 182150a..157b9b6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -958,7 +958,7 @@ enum mlxsw_flood_table_type {
 	MLXSW_REG_SFGC_TABLE_TYPE_VID = 1,
 	MLXSW_REG_SFGC_TABLE_TYPE_SINGLE = 2,
 	MLXSW_REG_SFGC_TABLE_TYPE_ANY = 0,
-	MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST = 3,
+	MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFSET = 3,
 	MLXSW_REG_SFGC_TABLE_TYPE_FID = 4,
 };
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
index c7590ae..6afbe9e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c
@@ -373,19 +373,19 @@ static const struct mlxsw_sp_flood_table mlxsw_sp_fid_8021q_flood_tables[] = {
 	{
 		.packet_type	= MLXSW_SP_FLOOD_TYPE_UC,
 		.bridge_type	= MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
-		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST,
+		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFSET,
 		.table_index	= 0,
 	},
 	{
 		.packet_type	= MLXSW_SP_FLOOD_TYPE_MC,
 		.bridge_type	= MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
-		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST,
+		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFSET,
 		.table_index	= 1,
 	},
 	{
 		.packet_type	= MLXSW_SP_FLOOD_TYPE_BC,
 		.bridge_type	= MLXSW_REG_SFGC_BRIDGE_TYPE_1Q_FID,
-		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFEST,
+		.table_type	= MLXSW_REG_SFGC_TABLE_TYPE_FID_OFFSET,
 		.table_index	= 2,
 	},
 };
-- 
2.9.3
