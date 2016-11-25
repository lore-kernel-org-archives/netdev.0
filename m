From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 13/19] mlxsw: resources: Add max trap groups resource
Date: Fri, 25 Nov 2016 10:33:41 +0100
Message-ID: <1480066427-3961-14-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33899 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752744AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f68.google.com with SMTP id g23so7223807wme.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:34:04 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

Add the max number of trap groups to resource query.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index a031e45..07b09f8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -42,6 +42,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_KVD_SIZE,
 	MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE,
 	MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE,
+	MLXSW_RES_ID_MAX_TRAP_GROUPS,
 	MLXSW_RES_ID_MAX_SPAN,
 	MLXSW_RES_ID_MAX_SYSTEM_PORT,
 	MLXSW_RES_ID_MAX_LAG,
@@ -63,6 +64,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_KVD_SIZE] = 0x1001,
 	[MLXSW_RES_ID_KVD_SINGLE_MIN_SIZE] = 0x1002,
 	[MLXSW_RES_ID_KVD_DOUBLE_MIN_SIZE] = 0x1003,
+	[MLXSW_RES_ID_MAX_TRAP_GROUPS] = 0x2201,
 	[MLXSW_RES_ID_MAX_SPAN] = 0x2420,
 	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
-- 
2.7.4
