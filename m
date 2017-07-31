From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/8] mlxsw: spectrum_acl: Fix a typo
Date: Mon, 31 Jul 2017 09:27:23 +0200
Message-ID: <20170731072730.3256-2-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35530 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751017AbdGaH1f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id c24so27265370wra.2
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:34 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index 01a1501..508b5fc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -369,7 +369,7 @@ int mlxsw_sp_acl_rulei_act_fwd(struct mlxsw_sp *mlxsw_sp,
 		local_port = mlxsw_sp_port->local_port;
 		in_port = false;
 	} else {
-		/* If out_dev is NULL, the called wants to
+		/* If out_dev is NULL, the caller wants to
 		 * set forward to ingress port.
 		 */
 		local_port = 0;
-- 
2.9.3
