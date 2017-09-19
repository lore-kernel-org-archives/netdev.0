From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/13] mlxsw: reg: Rename the flexible action set length field
Date: Tue, 19 Sep 2017 10:00:12 +0200
Message-ID: <20170919080020.5870-6-jiri@resnulli.us>
References: <20170919080020.5870-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:37473 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751589AbdISIA1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 04:00:27 -0400
Received: by mail-wr0-f195.google.com with SMTP id u48so1708369wrf.4
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 01:00:27 -0700 (PDT)
In-Reply-To: <20170919080020.5870-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

The MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN is relevant for the multicast router
registers too, so rename it to have a general name which is not bound to a
specific register.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index cc27c5d..fb8ab44 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2142,15 +2142,14 @@ MLXSW_REG_DEFINE(pefa, MLXSW_REG_PEFA_ID, MLXSW_REG_PEFA_LEN);
  */
 MLXSW_ITEM32(reg, pefa, index, 0x00, 0, 24);
 
-#define MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN 0xA8
+#define MLXSW_REG_FLEX_ACTION_SET_LEN 0xA8
 
 /* reg_pefa_flex_action_set
  * Action-set to perform when rule is matched.
  * Must be zero padded if action set is shorter.
  * Access: RW
  */
-MLXSW_ITEM_BUF(reg, pefa, flex_action_set, 0x08,
-	       MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN);
+MLXSW_ITEM_BUF(reg, pefa, flex_action_set, 0x08, MLXSW_REG_FLEX_ACTION_SET_LEN);
 
 static inline void mlxsw_reg_pefa_pack(char *payload, u32 index,
 				       const char *flex_action_set)
@@ -2243,7 +2242,7 @@ MLXSW_ITEM_BUF(reg, ptce2, mask, 0x80,
  * Access: RW
  */
 MLXSW_ITEM_BUF(reg, ptce2, flex_action_set, 0xE0,
-	       MLXSW_REG_PXXX_FLEX_ACTION_SET_LEN);
+	       MLXSW_REG_FLEX_ACTION_SET_LEN);
 
 static inline void mlxsw_reg_ptce2_pack(char *payload, bool valid,
 					enum mlxsw_reg_ptce2_op op,
-- 
2.9.5
