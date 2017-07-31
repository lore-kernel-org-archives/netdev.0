From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/8] mlxsw: spectrum_router: Clarify a piece of code
Date: Mon, 31 Jul 2017 09:27:29 +0200
Message-ID: <20170731072730.3256-8-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34135 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751680AbdGaH1o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:44 -0400
Received: by mail-wm0-f67.google.com with SMTP id x64so10145522wmg.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:43 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Prefer logical operator that expresses the intent to bitwise one that
happens to give the same result.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 600268c..c69efbd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1668,7 +1668,7 @@ mlxsw_sp_nexthop_group_refresh(struct mlxsw_sp *mlxsw_sp,
 	for (i = 0; i < nh_grp->count; i++) {
 		nh = &nh_grp->nexthops[i];
 
-		if (nh->should_offload ^ nh->offloaded) {
+		if (nh->should_offload != nh->offloaded) {
 			offload_change = true;
 			if (nh->should_offload)
 				nh->update = 1;
-- 
2.9.3
