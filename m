From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum_buffers: Use designated initializers for mlxsw_sp_pbs
Date: Fri, 15 Apr 2016 15:09:37 +0200
Message-ID: <1460725778-14655-2-git-send-email-jiri@resnulli.us>
References: <1460725778-14655-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, David.Laight@ACULAB.COM
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37525 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbcDONJm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 09:09:42 -0400
Received: by mail-wm0-f48.google.com with SMTP id n3so31840207wmn.0
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 06:09:41 -0700 (PDT)
In-Reply-To: <1460725778-14655-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Suggested-by: David Laight <David.Laight@ACULAB.COM>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c | 12 ++----------
 1 file changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
index f2e073a..64166dd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_buffers.c
@@ -162,16 +162,8 @@ static int mlxsw_sp_sb_pm_occ_query(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 }
 
 static const u16 mlxsw_sp_pbs[] = {
-	2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
-	0,
-	0,
-	0,
-	0,
-	0,
-	0,
-	0,
-	0, /* Unused */
-	2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU),
+	[0] = 2 * MLXSW_SP_BYTES_TO_CELLS(ETH_FRAME_LEN),
+	[9] = 2 * MLXSW_SP_BYTES_TO_CELLS(MLXSW_PORT_MAX_MTU),
 };
 
 #define MLXSW_SP_PBS_LEN ARRAY_SIZE(mlxsw_sp_pbs)
-- 
2.5.5
