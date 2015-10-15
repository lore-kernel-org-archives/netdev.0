From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/15] mlxsw: reg: Remove extra space in SFGC ID define
Date: Thu, 15 Oct 2015 17:43:24 +0200
Message-ID: <1444923809-20785-11-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:35986 "EHLO
	mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753718AbbJOPno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:44 -0400
Received: by qkht68 with SMTP id t68so40675654qkh.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:43 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index a2ebb79..34b95a1 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -205,7 +205,7 @@ static inline void mlxsw_reg_spms_pack(char *payload, u8 local_port, u16 vid,
  * The following register controls the association of flooding tables and MIDs
  * to packet types used for flooding.
  */
-#define MLXSW_REG_SFGC_ID  0x2011
+#define MLXSW_REG_SFGC_ID 0x2011
 #define MLXSW_REG_SFGC_LEN 0x10
 
 static const struct mlxsw_reg_info mlxsw_reg_sfgc = {
-- 
1.9.3
