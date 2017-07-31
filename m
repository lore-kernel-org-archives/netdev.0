From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: spectrum_router: Simplify a piece of code
Date: Mon, 31 Jul 2017 09:27:30 +0200
Message-ID: <20170731072730.3256-9-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33606 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751740AbdGaH1p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:45 -0400
Received: by mail-wr0-f193.google.com with SMTP id y43so30762712wrd.0
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:45 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Express the same logic more succinctly.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c69efbd..802f5b8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1752,9 +1752,9 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 static void __mlxsw_sp_nexthop_neigh_update(struct mlxsw_sp_nexthop *nh,
 					    bool removing)
 {
-	if (!removing && !nh->should_offload)
+	if (!removing)
 		nh->should_offload = 1;
-	else if (removing && nh->offloaded)
+	else if (nh->offloaded)
 		nh->should_offload = 0;
 	nh->update = 1;
 }
-- 
2.9.3
