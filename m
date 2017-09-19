From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/13] mlxsw: resources: Add multicast ERIF list entries resource
Date: Tue, 19 Sep 2017 10:00:15 +0200
Message-ID: <20170919080020.5870-9-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33764 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751590AbdISIAa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:30 -0400
Received: by mail-wr0-f196.google.com with SMTP id b9so1724072wra.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:30 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The multicast ERIF list entries resource indicates the number of entries
that can be put in one rigr2 register operation. While the register can
hold up to MLXSW_REG_RIGR2_MAX_ERIFS ( = 32) ERIF entries, the actual
number allowed by firmware is indicated with this resource.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 9556d93..087aad5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -63,6 +63,7 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_CPU_POLICERS,
 	MLXSW_RES_ID_MAX_VRS,
 	MLXSW_RES_ID_MAX_RIFS,
+	MLXSW_RES_ID_MC_ERIF_LIST_ENTRIES,
 	MLXSW_RES_ID_MAX_LPM_TREES,
 
 	/* Internal resources.
@@ -100,6 +101,7 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_CPU_POLICERS] = 0x2A13,
 	[MLXSW_RES_ID_MAX_VRS] = 0x2C01,
 	[MLXSW_RES_ID_MAX_RIFS] = 0x2C02,
+	[MLXSW_RES_ID_MC_ERIF_LIST_ENTRIES] = 0x2C10,
 	[MLXSW_RES_ID_MAX_LPM_TREES] = 0x2C30,
 };
 
-- 
2.9.5
