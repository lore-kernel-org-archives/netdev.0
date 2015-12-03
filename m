From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: core: Change BUG to WARN in hwmon code
Date: Thu,  3 Dec 2015 10:12:03 +0100
Message-ID: <1449133923-3021-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:33293 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380AbbLCJMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 04:12:07 -0500
Received: by wmec201 with SMTP id c201so16658298wme.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 01:12:05 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Better to just warn the user that something really odd is going on and
continue to run.

Suggested-by: Or Gerlitz <gerlitz.or@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index ad8b274..4dad146 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -215,7 +215,7 @@ static void mlxsw_hwmon_attr_add(struct mlxsw_hwmon *mlxsw_hwmon,
 			 "pwm%u", num + 1);
 		break;
 	default:
-		BUG();
+		WARN_ON(1);
 	}
 
 	mlxsw_hwmon_attr->type_index = type_index;
-- 
1.9.3
