From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0072/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 18:38:35 +0800
Message-ID: <20160802103835.18552-1-baolex.ni@intel.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org,
	hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:45434 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755140AbcHBLam (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 07:30:42 -0400
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
 drivers/atm/iphase.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/iphase.c b/drivers/atm/iphase.c
index 809dd1e..091752e 100644
--- a/drivers/atm/iphase.c
+++ b/drivers/atm/iphase.c
@@ -86,7 +86,7 @@ module_param(IA_TX_BUF, int, 0);
 module_param(IA_TX_BUF_SZ, int, 0);
 module_param(IA_RX_BUF, int, 0);
 module_param(IA_RX_BUF_SZ, int, 0);
-module_param(IADebugFlag, uint, 0644);
+module_param(IADebugFlag, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 MODULE_LICENSE("GPL");
 
-- 
2.9.2
