From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/8] mlxsw: spectrum_router: Fix a typo
Date: Mon, 31 Jul 2017 09:27:25 +0200
Message-ID: <20170731072730.3256-4-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33584 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751701AbdGaH1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:38 -0400
Received: by mail-wr0-f195.google.com with SMTP id y43so30762546wrd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:37 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 8bf076d..b6df3c3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1804,7 +1804,7 @@ static int mlxsw_sp_nexthop_neigh_init(struct mlxsw_sp *mlxsw_sp,
 		return 0;
 
 	/* Take a reference of neigh here ensuring that neigh would
-	 * not be detructed before the nexthop entry is finished.
+	 * not be destructed before the nexthop entry is finished.
 	 * The reference is taken either in neigh_lookup() or
 	 * in neigh_create() in case n is not found.
 	 */
-- 
2.9.3
