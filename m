From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/17] mlxsw: reg: Use correct PBMC register length
Date: Wed,  6 Apr 2016 17:10:04 +0200
Message-ID: <1459955416-23786-6-git-send-email-jiri@resnulli.us>
References: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34869 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754079AbcDFPK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 11:10:27 -0400
Received: by mail-wm0-f66.google.com with SMTP id a140so14162913wma.2
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 08:10:26 -0700 (PDT)
In-Reply-To: <1459955416-23786-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The last field of the PBMC register is at offset 0x64 and its size is
0x8, so the correct register's length is 0x6C bytes.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 0995bee..f08a17f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -2427,7 +2427,7 @@ static inline void mlxsw_reg_pptb_pack(char *payload, u8 local_port)
  * allocation for different Prios, and the Pause threshold management.
  */
 #define MLXSW_REG_PBMC_ID 0x500C
-#define MLXSW_REG_PBMC_LEN 0x68
+#define MLXSW_REG_PBMC_LEN 0x6C
 
 static const struct mlxsw_reg_info mlxsw_reg_pbmc = {
 	.id = MLXSW_REG_PBMC_ID,
-- 
2.5.5
