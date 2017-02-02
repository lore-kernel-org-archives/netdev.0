From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/19] mlxsw: resources: Add ACL related resources
Date: Thu,  2 Feb 2017 16:12:54 +0100
Message-ID: <1486048379-19237-15-git-send-email-jiri@resnulli.us>
References: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        ivecera@redhat.com, jbenc@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:33531 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751982AbdBBPN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 10:13:29 -0500
Received: by mail-wj0-f196.google.com with SMTP id le4so1335989wjb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 07:13:28 -0800 (PST)
In-Reply-To: <1486048379-19237-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Add couple of resource limits related to ACL.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/resources.h | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/resources.h b/drivers/net/ethernet/mellanox/mlxsw/resources.h
index 3c2171d..bce8c2e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/resources.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/resources.h
@@ -1,7 +1,7 @@
 /*
  * drivers/net/ethernet/mellanox/mlxsw/resources.h
- * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
- * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
+ * Copyright (c) 2016-2017 Mellanox Technologies. All rights reserved.
+ * Copyright (c) 2016-2017 Jiri Pirko <jiri@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -48,6 +48,14 @@ enum mlxsw_res_id {
 	MLXSW_RES_ID_MAX_LAG,
 	MLXSW_RES_ID_MAX_LAG_MEMBERS,
 	MLXSW_RES_ID_MAX_BUFFER_SIZE,
+	MLXSW_RES_ID_ACL_MAX_TCAM_REGIONS,
+	MLXSW_RES_ID_ACL_MAX_TCAM_RULES,
+	MLXSW_RES_ID_ACL_MAX_REGIONS,
+	MLXSW_RES_ID_ACL_MAX_GROUPS,
+	MLXSW_RES_ID_ACL_MAX_GROUP_SIZE,
+	MLXSW_RES_ID_ACL_FLEX_KEYS,
+	MLXSW_RES_ID_ACL_MAX_ACTION_PER_RULE,
+	MLXSW_RES_ID_ACL_ACTIONS_PER_SET,
 	MLXSW_RES_ID_MAX_CPU_POLICERS,
 	MLXSW_RES_ID_MAX_VRS,
 	MLXSW_RES_ID_MAX_RIFS,
@@ -72,6 +80,14 @@ static u16 mlxsw_res_ids[] = {
 	[MLXSW_RES_ID_MAX_LAG] = 0x2520,
 	[MLXSW_RES_ID_MAX_LAG_MEMBERS] = 0x2521,
 	[MLXSW_RES_ID_MAX_BUFFER_SIZE] = 0x2802,	/* Bytes */
+	[MLXSW_RES_ID_ACL_MAX_TCAM_REGIONS] = 0x2901,
+	[MLXSW_RES_ID_ACL_MAX_TCAM_RULES] = 0x2902,
+	[MLXSW_RES_ID_ACL_MAX_REGIONS] = 0x2903,
+	[MLXSW_RES_ID_ACL_MAX_GROUPS] = 0x2904,
+	[MLXSW_RES_ID_ACL_MAX_GROUP_SIZE] = 0x2905,
+	[MLXSW_RES_ID_ACL_FLEX_KEYS] = 0x2910,
+	[MLXSW_RES_ID_ACL_MAX_ACTION_PER_RULE] = 0x2911,
+	[MLXSW_RES_ID_ACL_ACTIONS_PER_SET] = 0x2912,
 	[MLXSW_RES_ID_MAX_CPU_POLICERS] = 0x2A13,
 	[MLXSW_RES_ID_MAX_VRS] = 0x2C01,
 	[MLXSW_RES_ID_MAX_RIFS] = 0x2C02,
-- 
2.7.4
