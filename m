From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum_router: Fix a typo
Date: Mon,  2 Oct 2017 12:21:57 +0200
Message-ID: <20171002102158.2443-2-jiri@resnulli.us>
References: <20171002102158.2443-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:48512 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750986AbdJBKWB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2017 06:22:01 -0400
Received: by mail-wm0-f67.google.com with SMTP id i82so7435452wmd.3
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 03:22:00 -0700 (PDT)
In-Reply-To: <20171002102158.2443-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index ef4b86b..75078a3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1680,7 +1680,7 @@ __mlxsw_sp_router_neighs_update_rauhtd(struct mlxsw_sp *mlxsw_sp,
 		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(rauhtd),
 				      rauhtd_pl);
 		if (err) {
-			dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to dump neighbour talbe\n");
+			dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to dump neighbour table\n");
 			break;
 		}
 		num_rec = mlxsw_reg_rauhtd_num_rec_get(rauhtd_pl);
-- 
2.9.5
