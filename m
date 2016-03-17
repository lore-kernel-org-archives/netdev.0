From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 07/13] mlxsw: reg: Fix SBPM register name
Date: Thu, 17 Mar 2016 18:13:47 +0100
Message-ID: <1458234833-25836-8-git-send-email-jiri@resnulli.us>
References: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36541 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031757AbcCQROF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2016 13:14:05 -0400
Received: by mail-wm0-f65.google.com with SMTP id l68so433511wml.3
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2016 10:14:04 -0700 (PDT)
In-Reply-To: <1458234833-25836-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix copy&paste error and state the name of SBPM register correctly.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index fa1c7bd..41186cc 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -3107,8 +3107,8 @@ static inline void mlxsw_reg_sbcm_pack(char *payload, u8 local_port, u8 pg_buff,
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
2.5.0
