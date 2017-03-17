From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/2] mlxsw: spectrum: Align the matchall default case returned value
Date: Fri, 17 Mar 2017 09:38:01 +0100
Message-ID: <1489739881-2826-3-git-send-email-jiri@resnulli.us>
References: <1489739881-2826-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36792 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750932AbdCQIpN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Mar 2017 04:45:13 -0400
Received: by mail-wm0-f67.google.com with SMTP id x124so2057949wmf.3
        for <netdev@vger.kernel.org>; Fri, 17 Mar 2017 01:45:11 -0700 (PDT)
In-Reply-To: <1489739881-2826-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Align the default case for matchall offload with what's there
for flower.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index cbc1646..3ed77e1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1423,7 +1423,7 @@ static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
 						       tc->cls_mall);
 			return 0;
 		default:
-			return -EINVAL;
+			return -EOPNOTSUPP;
 		}
 	case TC_SETUP_CLSFLOWER:
 		switch (tc->cls_flower->command) {
-- 
2.7.4
