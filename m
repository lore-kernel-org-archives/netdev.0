From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/22] mlxsw: reg: Enable IPv6 on router interfaces
Date: Tue, 18 Jul 2017 10:10:10 +0200
Message-ID: <20170718081030.2781-3-jiri@resnulli.us>
References: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34152 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdGRIKg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:36 -0400
Received: by mail-wr0-f193.google.com with SMTP id w4so2851966wrb.1
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:36 -0700 (PDT)
In-Reply-To: <20170718081030.2781-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Enable IPv6 and IPv6 forwarding on router interfaces (RIFs), so that
they will be able to receive and forward IPv6 traffic.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index ce6c63d..8282acb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -4206,10 +4206,12 @@ static inline void mlxsw_reg_ritr_pack(char *payload, bool enable,
 	MLXSW_REG_ZERO(ritr, payload);
 	mlxsw_reg_ritr_enable_set(payload, enable);
 	mlxsw_reg_ritr_ipv4_set(payload, 1);
+	mlxsw_reg_ritr_ipv6_set(payload, 1);
 	mlxsw_reg_ritr_type_set(payload, type);
 	mlxsw_reg_ritr_op_set(payload, op);
 	mlxsw_reg_ritr_rif_set(payload, rif);
 	mlxsw_reg_ritr_ipv4_fe_set(payload, 1);
+	mlxsw_reg_ritr_ipv6_fe_set(payload, 1);
 	mlxsw_reg_ritr_lb_en_set(payload, 1);
 	mlxsw_reg_ritr_virtual_router_set(payload, vr_id);
 	mlxsw_reg_ritr_mtu_set(payload, mtu);
-- 
2.9.3
