From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/10] mlxsw: spectrum_router: Use helper to check for last neighbor
Date: Mon, 25 Sep 2017 10:32:24 +0200
Message-ID: <20170925083230.1193-5-jiri@resnulli.us>
References: <20170925083230.1193-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36503 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753234AbdIYIcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 04:32:35 -0400
Received: by mail-wm0-f65.google.com with SMTP id r136so6475030wmf.3
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 01:32:35 -0700 (PDT)
In-Reply-To: <20170925083230.1193-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Use list_is_last helper to check for last neighbor.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index e8c2170..8e78a95 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1332,7 +1332,7 @@ mlxsw_sp_rif_neigh_next(struct mlxsw_sp_rif *rif,
 						typeof(*neigh_entry),
 						rif_list_node);
 	}
-	if (neigh_entry->rif_list_node.next == &rif->neigh_list)
+	if (list_is_last(&neigh_entry->rif_list_node, &rif->neigh_list))
 		return NULL;
 	return list_next_entry(neigh_entry, rif_list_node);
 }
-- 
2.9.5
