From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 2/2] mlxsw: reg: Fix SPVMLR max record count
Date: Tue, 14 Mar 2017 14:00:01 +0100
Message-ID: <1489496401-4820-3-git-send-email-jiri@resnulli.us>
References: <1489496401-4820-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:35305 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751014AbdCNNAH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:00:07 -0400
Received: by mail-wr0-f194.google.com with SMTP id u108so23844296wrb.2
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:00:05 -0700 (PDT)
In-Reply-To: <1489496401-4820-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The num_rec field is 8 bit, so the maximal count number is 255.
This fixes vlans learning not being enabled for wider ranges than 255.

Fixes: a4feea74cd7a ("mlxsw: reg: Add Switch Port VLAN MAC Learning register definition")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 65e1942..d9616da 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -1702,7 +1702,7 @@ static inline void mlxsw_reg_sfmr_pack(char *payload,
 #define MLXSW_REG_SPVMLR_ID 0x2020
 #define MLXSW_REG_SPVMLR_BASE_LEN 0x04 /* base length, without records */
 #define MLXSW_REG_SPVMLR_REC_LEN 0x04 /* record length */
-#define MLXSW_REG_SPVMLR_REC_MAX_COUNT 256
+#define MLXSW_REG_SPVMLR_REC_MAX_COUNT 255
 #define MLXSW_REG_SPVMLR_LEN (MLXSW_REG_SPVMLR_BASE_LEN + \
 			      MLXSW_REG_SPVMLR_REC_LEN * \
 			      MLXSW_REG_SPVMLR_REC_MAX_COUNT)
-- 
2.7.4
