From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/8] mlxsw: Update specification of reg_ritr_type
Date: Mon, 31 Jul 2017 09:27:26 +0200
Message-ID: <20170731072730.3256-5-jiri@resnulli.us>
References: <20170731072730.3256-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34584 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751091AbdGaH1k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 03:27:40 -0400
Received: by mail-wr0-f193.google.com with SMTP id o33so23299576wrb.1
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 00:27:39 -0700 (PDT)
In-Reply-To: <20170731072730.3256-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Machata <petrm@mellanox.com>

The comments really belong to the individual enumerators. The comment
at the register should instead reference the enum.

Signed-off-by: Petr Machata <petrm@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b4ea8cb..a671438 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3992,16 +3992,16 @@ MLXSW_ITEM32(reg, ritr, ipv4, 0x00, 29, 1);
 MLXSW_ITEM32(reg, ritr, ipv6, 0x00, 28, 1);
 
 enum mlxsw_reg_ritr_if_type {
+	/* VLAN interface. */
 	MLXSW_REG_RITR_VLAN_IF,
+	/* FID interface. */
 	MLXSW_REG_RITR_FID_IF,
+	/* Sub-port interface. */
 	MLXSW_REG_RITR_SP_IF,
 };
 
 /* reg_ritr_type
- * Router interface type.
- * 0 - VLAN interface.
- * 1 - FID interface.
- * 2 - Sub-port interface.
+ * Router interface type as per enum mlxsw_reg_ritr_if_type.
  * Access: RW
  */
 MLXSW_ITEM32(reg, ritr, type, 0x00, 23, 3);
-- 
2.9.3
