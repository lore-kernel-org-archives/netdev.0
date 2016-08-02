From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0722/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:57 +0800
Message-ID: <20160802113957.30193-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, fw@strlen.de, davem@davemloft.net,
	Baohua.Song@csr.com
To: yishaih@mellanox.com, benh@kernel.crashing.org, paulus@samba.org,
	mpe@ellerman.id.au, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8256 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934335AbcHBMRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:17:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/ethernet/mellanox/mlx4/catas.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/catas.c b/drivers/net/ethernet/mellanox/mlx4/catas.c
index c7e9399..8daefc9 100644
--- a/drivers/net/ethernet/mellanox/mlx4/catas.c
+++ b/drivers/net/ethernet/mellanox/mlx4/catas.c
@@ -43,7 +43,7 @@ enum {
 
 
 int mlx4_internal_err_reset = 1;
-module_param_named(internal_err_reset, mlx4_internal_err_reset,  int, 0644);
+module_param_named(internal_err_reset, mlx4_internal_err_reset,  int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(internal_err_reset,
 		 "Reset device on internal errors if non-zero (default 1)");
 
-- 
2.9.2
