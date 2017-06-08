From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/3] mlxsw: spectrum_router: Mark only first LPM tree as reserved
Date: Thu,  8 Jun 2017 08:47:43 +0200
Message-ID: <20170608064745.4900-2-jiri@resnulli.us>
References: <20170608064745.4900-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36793 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751506AbdFHGru (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 02:47:50 -0400
Received: by mail-wm0-f65.google.com with SMTP id d17so833020wme.3
        for <netdev@vger.kernel.org>; Wed, 07 Jun 2017 23:47:49 -0700 (PDT)
In-Reply-To: <20170608064745.4900-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

In new firmware versions (that we can now enforce via
request_firmware()), only the first LPM tree is reserved and not the
first two as in older versions.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2006105..700cc8c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -591,7 +591,7 @@ static int mlxsw_sp_lpm_tree_put(struct mlxsw_sp *mlxsw_sp,
 	return 0;
 }
 
-#define MLXSW_SP_LPM_TREE_MIN 2 /* trees 0 and 1 are reserved */
+#define MLXSW_SP_LPM_TREE_MIN 1 /* tree 0 is reserved */
 
 static int mlxsw_sp_lpm_init(struct mlxsw_sp *mlxsw_sp)
 {
-- 
2.9.3
