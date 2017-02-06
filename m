From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: spectrum_router: Fix typo in comment
Date: Mon,  6 Feb 2017 16:20:17 +0100
Message-ID: <1486394417-8011-9-git-send-email-jiri@resnulli.us>
References: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33723 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753315AbdBFPUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:30 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so22464981wmv.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:29 -0800 (PST)
In-Reply-To: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index ec022f9..b19f69f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1353,7 +1353,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	/* Take a reference of neigh here ensuring that neigh would
 	 * not be detructed before the nexthop entry is finished.
 	 * The reference is taken either in neigh_lookup() or
-	 * in neith_create() in case n is not found.
+	 * in neigh_create() in case n is not found.
 	 */
 	n = neigh_lookup(&arp_tbl, &fib_nh->nh_gw, dev);
 	if (!n) {
-- 
2.7.4
