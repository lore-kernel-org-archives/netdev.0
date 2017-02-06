From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: reg: Fix HTGT register length
Date: Mon,  6 Feb 2017 13:56:27 +0100
Message-ID: <1486385787-2122-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eladr@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36361 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751164AbdBFM4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 07:56:30 -0500
Received: by mail-wm0-f65.google.com with SMTP id r18so21791126wmd.3
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 04:56:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

HTGT register length is limited to 32 bytes and not 256 bytes.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index b50a312..0899e2d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3653,7 +3653,7 @@ static inline void mlxsw_reg_pspa_pack(char *payload, u8 swid, u8 local_port)
  * Configures the properties for forwarding to CPU.
  */
 #define MLXSW_REG_HTGT_ID 0x7002
-#define MLXSW_REG_HTGT_LEN 0x100
+#define MLXSW_REG_HTGT_LEN 0x20
 
 MLXSW_REG_DEFINE(htgt, MLXSW_REG_HTGT_ID, MLXSW_REG_HTGT_LEN);
 
-- 
2.7.4
