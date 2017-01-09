From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/5] mlxsw: cmd: Fix API name comments for event-queues
Date: Mon,  9 Jan 2017 11:25:45 +0100
Message-ID: <1483957548-3531-3-git-send-email-jiri@resnulli.us>
References: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33101 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758593AbdAIKZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:25:53 -0500
Received: by mail-wm0-f68.google.com with SMTP id r144so12136904wme.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:25:52 -0800 (PST)
In-Reply-To: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Probably some copy-paste error from "int_msix" that caused "int_" prefix to
appear in the comments for all "eq_" APIs.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/cmd.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/cmd.h b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
index 56e19b0..a1b4842 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/cmd.h
@@ -1132,12 +1132,12 @@ static inline int mlxsw_cmd_sw2hw_eq(struct mlxsw_core *mlxsw_core,
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, int_msix, 0x00, 24, 1);
 
-/* cmd_mbox_sw2hw_eq_int_oi
+/* cmd_mbox_sw2hw_eq_oi
  * When set, overrun ignore is enabled.
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, oi, 0x00, 12, 1);
 
-/* cmd_mbox_sw2hw_eq_int_st
+/* cmd_mbox_sw2hw_eq_st
  * Event delivery state machine
  * 0x0 - FIRED
  * 0x1 - ARMED (Request for Notification)
@@ -1146,19 +1146,19 @@ MLXSW_ITEM32(cmd_mbox, sw2hw_eq, oi, 0x00, 12, 1);
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, st, 0x00, 8, 2);
 
-/* cmd_mbox_sw2hw_eq_int_log_eq_size
+/* cmd_mbox_sw2hw_eq_log_eq_size
  * Log (base 2) of the EQ size (in entries).
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, log_eq_size, 0x00, 0, 4);
 
-/* cmd_mbox_sw2hw_eq_int_producer_counter
+/* cmd_mbox_sw2hw_eq_producer_counter
  * Producer Counter. The counter is incremented for each EQE that is written
  * by the HW to the EQ.
  * Maintained by HW (valid for the QUERY_EQ command only)
  */
 MLXSW_ITEM32(cmd_mbox, sw2hw_eq, producer_counter, 0x04, 0, 16);
 
-/* cmd_mbox_sw2hw_eq_int_pa
+/* cmd_mbox_sw2hw_eq_pa
  * Physical Address.
  */
 MLXSW_ITEM64_INDEXED(cmd_mbox, sw2hw_eq, pa, 0x10, 11, 53, 0x08, 0x00, true);
-- 
2.7.4
