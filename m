From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 03/21] mlxsw: reg: Move enum mlxsw_reg_ratr_trap_id
Date: Sat,  2 Sep 2017 23:49:11 +0200
Message-ID: <20170902214929.2890-4-jiri@resnulli.us>
References: <20170902214929.2890-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37539 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752776AbdIBVti (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 17:49:38 -0400
Received: by mail-wr0-f196.google.com with SMTP id y15so1123010wrc.4
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 14:49:38 -0700 (PDT)
In-Reply-To: <20170902214929.2890-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

This enum is used with reg_ratr_trap_id, so move it next to the register
definition.

While at it, drop the enumerator initializers.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 6a7757f..bf936b6 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4423,17 +4423,17 @@ enum mlxsw_reg_ratr_trap_action {
  */
 MLXSW_ITEM32(reg, ratr, trap_action, 0x0C, 28, 4);
 
-enum mlxsw_reg_ratr_trap_id {
-	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS0 = 0,
-	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS1 = 1,
-};
-
 /* reg_ratr_adjacency_index_high
  * Bits 23:16 of the adjacency_index.
  * Access: Index
  */
 MLXSW_ITEM32(reg, ratr, adjacency_index_high, 0x0C, 16, 8);
 
+enum mlxsw_reg_ratr_trap_id {
+	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS0,
+	MLXSW_REG_RATR_TRAP_ID_RTR_EGRESS1,
+};
+
 /* reg_ratr_trap_id
  * Trap ID to be reported to CPU.
  * Trap-ID is RTR_EGRESS0 or RTR_EGRESS1.
-- 
2.9.3
