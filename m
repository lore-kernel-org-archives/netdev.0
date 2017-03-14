From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: reg: Fix SPVM max record count
Date: Tue, 14 Mar 2017 14:00:00 +0100
Message-ID: <1489496401-4820-2-git-send-email-jiri@resnulli.us>
References: <1489496401-4820-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:33983 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdCNNAF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:00:05 -0400
Received: by mail-wr0-f196.google.com with SMTP id u48so23889200wrc.1
        for <netdev@vger.kernel.org>; Tue, 14 Mar 2017 06:00:04 -0700 (PDT)
In-Reply-To: <1489496401-4820-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The num_rec field is 8 bit, so the maximal count number is 255. This
fixes vlans not being enabled for wider ranges than 255.

Fixes: b2e345f9a454 ("mlxsw: reg: Add Switch Port VID and Switch Port VLAN Membership registers definitions")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0899e2d..65e1942 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -769,7 +769,7 @@ static inline void mlxsw_reg_spvid_pack(char *payload, u8 local_port, u16 pvid)
 #define MLXSW_REG_SPVM_ID 0x200F
 #define MLXSW_REG_SPVM_BASE_LEN 0x04 /* base length, without records */
 #define MLXSW_REG_SPVM_REC_LEN 0x04 /* record length */
-#define MLXSW_REG_SPVM_REC_MAX_COUNT 256
+#define MLXSW_REG_SPVM_REC_MAX_COUNT 255
 #define MLXSW_REG_SPVM_LEN (MLXSW_REG_SPVM_BASE_LEN +	\
 		    MLXSW_REG_SPVM_REC_LEN * MLXSW_REG_SPVM_REC_MAX_COUNT)
 
-- 
2.7.4
