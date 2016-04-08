From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] mlxsw: reg: Fix SBPM register name
Date: Fri,  8 Apr 2016 17:45:25 +0200
Message-ID: <1460130325-14931-6-git-send-email-jiri@resnulli.us>
References: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35697 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754361AbcDHPpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:45:36 -0400
Received: by mail-wm0-f66.google.com with SMTP id a140so5283210wma.2
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 08:45:35 -0700 (PDT)
In-Reply-To: <1460130325-14931-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix copy&paste error and state the name of SBPM register correctly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 19bdc82..57e4a63 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3598,8 +3598,8 @@ static inline void mlxsw_reg_sbcm_pack(char *payload, u8 local_port, u8 pg_buff,
 	mlxsw_reg_sbcm_pool_set(payload, pool);
 }
 
-/* SBPM - Shared Buffer Class Management Register
- * ----------------------------------------------
+/* SBPM - Shared Buffer Port Management Register
+ * ---------------------------------------------
  * The SBPM register configures and retrieves the shared buffer allocation
  * and configuration according to Port-Pool, including the definition
  * of the associated quota.
-- 
2.5.5
