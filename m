From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/8] mlxsw: spectrum_router: Simplify a piece of code
Date: Mon, 31 Jul 2017 09:27:28 +0200
Message-ID: <20170731072730.3256-7-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:38619 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdGaH1m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:42 -0400
Received: by mail-wr0-f193.google.com with SMTP id g32so13545794wrd.5
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:42 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index b6df3c3..600268c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3124,9 +3124,7 @@ mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *rif, struct net_device *dev,
 
 	switch (event) {
 	case NETDEV_UP:
-		if (!rif)
-			return true;
-		return false;
+		return rif == NULL;
 	case NETDEV_DOWN:
 		idev = __in_dev_get_rtnl(dev);
 		if (idev && idev->ifa_list)
-- 
2.9.3
