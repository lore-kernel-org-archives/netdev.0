From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: Change the RX LAG hash function from XOR to CRC
Date: Mon, 19 Sep 2016 08:28:24 +0200
Message-ID: <1474266504-5723-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35568 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757296AbcISG21 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 02:28:27 -0400
Received: by mail-wm0-f68.google.com with SMTP id 133so13164584wmq.2
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 23:28:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Change the RX hash function from XOR to CRC in order to have better
distribution of the traffic.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4e2354c..6460c72 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1392,7 +1392,7 @@ static inline void mlxsw_reg_slcr_pack(char *payload, u16 lag_hash)
 {
 	MLXSW_REG_ZERO(slcr, payload);
 	mlxsw_reg_slcr_pp_set(payload, MLXSW_REG_SLCR_PP_GLOBAL);
-	mlxsw_reg_slcr_type_set(payload, MLXSW_REG_SLCR_TYPE_XOR);
+	mlxsw_reg_slcr_type_set(payload, MLXSW_REG_SLCR_TYPE_CRC);
 	mlxsw_reg_slcr_lag_hash_set(payload, lag_hash);
 }
 
-- 
2.5.5
