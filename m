From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/4] mlxsw: resources: Add maximum buffer size
Date: Mon, 28 Nov 2016 18:01:23 +0100
Message-ID: <1480352486-18518-2-git-send-email-jiri@resnulli.us>
References: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35550 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933351AbcK1RBa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:01:30 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so20103017wme.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:01:29 -0800 (PST)
In-Reply-To: <1480352486-18518-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We need to be able to limit the size of shared buffer pools, so query
the maximum size from the device during init.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 1c2119b..3c2171d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -47,6 +47,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_SYSTEM_PORT,
 	MLXSW_RES_ID_MAX_LAG,
 	MLXSW_RES_ID_MAX_LAG_MEMBERS,
+	MLXSW_RES_ID_MAX_BUFFER_SIZE,
 	MLXSW_RES_ID_MAX_CPU_POLICERS,
 	MLXSW_RES_ID_MAX_VRS,
 	MLXSW_RES_ID_MAX_RIFS,
@@ -70,6 +71,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_SYSTEM_PORT] = 0x2502,
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
 	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
+	[MLXSW_RES_ID_MAX_BUFFER_SIZE] = 0x2802,	/* Bytes */
 	[MLXSW_RES_ID_MAX_CPU_POLICERS] = 0x2A13,
 	[MLXSW_RES_ID_MAX_VRS] = 0x2C01,
 	[MLXSW_RES_ID_MAX_RIFS] = 0x2C02,
-- 
2.7.4
