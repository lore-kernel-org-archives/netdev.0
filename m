From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/12] mlxsw: spectrum_dpipe: Fix erif table op name space
Date: Thu, 24 Aug 2017 08:40:01 +0200
Message-ID: <20170824064010.1646-4-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:37219 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751353AbdHXGkT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:19 -0400
Received: by mail-wm0-f67.google.com with SMTP id v186so1689284wmf.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:19 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Fix ERIF's table operations name space.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index af2c65a..e9e1f7a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -215,8 +215,8 @@ static int mlxsw_sp_erif_entry_get(struct mlxsw_sp *mlxsw_sp,
 }
 
 static int
-mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
-				 struct devlink_dpipe_dump_ctx *dump_ctx)
+mlxsw_sp_dpipe_table_erif_entries_dump(void *priv, bool counters_enabled,
+				       struct devlink_dpipe_dump_ctx *dump_ctx)
 {
 	struct devlink_dpipe_value match_value, action_value;
 	struct devlink_dpipe_action action = {0};
@@ -279,7 +279,7 @@ mlxsw_sp_table_erif_entries_dump(void *priv, bool counters_enabled,
 	return err;
 }
 
-static int mlxsw_sp_table_erif_counters_update(void *priv, bool enable)
+static int mlxsw_sp_dpipe_table_erif_counters_update(void *priv, bool enable)
 {
 	struct mlxsw_sp *mlxsw_sp = priv;
 	int i;
@@ -304,8 +304,8 @@ static int mlxsw_sp_table_erif_counters_update(void *priv, bool enable)
 static struct devlink_dpipe_table_ops mlxsw_sp_erif_ops = {
 	.matches_dump = mlxsw_sp_dpipe_table_erif_matches_dump,
 	.actions_dump = mlxsw_sp_dpipe_table_erif_actions_dump,
-	.entries_dump = mlxsw_sp_table_erif_entries_dump,
-	.counters_set_update = mlxsw_sp_table_erif_counters_update,
+	.entries_dump = mlxsw_sp_dpipe_table_erif_entries_dump,
+	.counters_set_update = mlxsw_sp_dpipe_table_erif_counters_update,
 };
 
 static int mlxsw_sp_dpipe_erif_table_init(struct mlxsw_sp *mlxsw_sp)
-- 
2.9.3
