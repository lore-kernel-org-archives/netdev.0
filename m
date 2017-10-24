From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] mlxsw: spectrum: mr: Make the function mlxsw_sp_mr_dev_vif_lookup static
Date: Tue, 24 Oct 2017 11:17:16 +0200
Message-ID: <20171024091717.1180-3-jiri@resnulli.us>
References: <20171024091717.1180-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:49806 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdJXJRV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 05:17:21 -0400
Received: by mail-wm0-f68.google.com with SMTP id b189so14224136wmd.4
        for <netdev@vger.kernel.org>; Tue, 24 Oct 2017 02:17:21 -0700 (PDT)
In-Reply-To: <20171024091717.1180-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The function is only used internally in spectrum_mr.c and is not declared
in the header file, thus make it static.

Cleans up sparse warning:
symbol 'mlxsw_sp_mr_dev_vif_lookup' was not declared. Should it be static?

Fixes: c011ec1bbfd6 ("mlxsw: spectrum: Add the multicast routing offloading logic")
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
index 3f7d2d1..d20b143 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr.c
@@ -768,7 +768,7 @@ void mlxsw_sp_mr_vif_del(struct mlxsw_sp_mr_table *mr_table, vifi_t vif_index)
 	mlxsw_sp_mr_vif_unresolve(mr_table, NULL, mr_vif);
 }
 
-struct mlxsw_sp_mr_vif *
+static struct mlxsw_sp_mr_vif *
 mlxsw_sp_mr_dev_vif_lookup(struct mlxsw_sp_mr_table *mr_table,
 			   const struct net_device *dev)
 {
-- 
2.9.5
