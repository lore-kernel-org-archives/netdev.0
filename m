From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum_buffers: Use MLXSW_SP_PB_UNUSED define for unused pb
Date: Fri, 15 Apr 2016 15:09:38 +0200
Message-ID: <1460725778-14655-3-git-send-email-jiri@resnulli.us>
References: <1460725778-14655-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37540 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbcDONJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 09:09:43 -0400
Received: by mail-wm0-f50.google.com with SMTP id n3so31840917wmn.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 06:09:42 -0700 (PDT)
In-Reply-To: <1460725778-14655-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index 64166dd..a3720a0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -167,6 +167,7 @@ static const u16 mlxsw_sp_pbs[] = {
 };
 
 #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
+#define MLXSW_SP_PB_UNUSED 8
 
 static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 {
@@ -176,7 +177,7 @@ static int mlxsw_sp_port_pb_init(struct mlxsw_sp_port *mlxsw_sp_port)
 	mlxsw_reg_pbmc_pack(pbmc_pl, mlxsw_sp_port->local_port,
 			    0xffff, 0xffff / 2);
 	for (i = 0; i < MLXSW_SP_PBS_LEN; i++) {
-		if (i == 8)
+		if (i == MLXSW_SP_PB_UNUSED)
 			continue;
 		mlxsw_reg_pbmc_lossy_buffer_pack(pbmc_pl, i, mlxsw_sp_pbs[i]);
 	}
-- 
2.5.5
