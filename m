From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: reg: Fix max temperature getting
Date: Fri, 11 Dec 2015 16:10:39 +0100
Message-ID: <1449846639-20527-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35422 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753951AbbLKPKn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 10:10:43 -0500
Received: by mail-wm0-f47.google.com with SMTP id l68so17958231wml.0
        for <netdev@vger.kernel.org>; Fri, 11 Dec 2015 07:10:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix copy & paste error in MTPM unpack helper.

Fixes: 85926f877040 ("mlxsw: reg: Add definition of temperature management registers")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4e4e4dc..af631df 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2684,7 +2684,7 @@ static inline void mlxsw_reg_mtmp_unpack(char *payload, unsigned int *p_temp,
 		*p_temp = MLXSW_REG_MTMP_TEMP_TO_MC(temp);
 	}
 	if (p_max_temp) {
-		temp = mlxsw_reg_mtmp_temperature_get(payload);
+		temp = mlxsw_reg_mtmp_max_temperature_get(payload);
 		*p_max_temp = MLXSW_REG_MTMP_TEMP_TO_MC(temp);
 	}
 	if (sensor_name)
-- 
1.9.3
