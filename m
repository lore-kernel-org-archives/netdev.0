From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum: Fix ordering in mlxsw_sp_fini
Date: Fri,  6 May 2016 22:20:59 +0200
Message-ID: <1462566059-2128-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35244 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758671AbcEFUVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 16:21:07 -0400
Received: by mail-wm0-f67.google.com with SMTP id e201so10440853wme.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 13:21:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fixes: 0f433fa0ec ("mlxsw: spectrum_buffers: Implement shared buffer configuration")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 4758516..4a72737 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2449,8 +2449,8 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 {
 	struct mlxsw_sp *mlxsw_sp = mlxsw_core_driver_priv(mlxsw_core);
 
-	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
+	mlxsw_sp_buffers_fini(mlxsw_sp);
 	mlxsw_sp_traps_fini(mlxsw_sp);
 	mlxsw_sp_event_unregister(mlxsw_sp, MLXSW_TRAP_ID_PUDE);
 	mlxsw_sp_ports_remove(mlxsw_sp);
-- 
2.5.5
