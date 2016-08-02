From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0071/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 18:38:31 +0800
Message-ID: <20160802103831.18486-1-baolex.ni@intel.com>
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: 3chas3@gmail.com, tj@kernel.org, lenb@kernel.org, x86@kernel.org,
	hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24276 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755234AbcHBLUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 07:20:01 -0400
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
 drivers/atm/idt77252.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index 074616b..7d6e420 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -3796,7 +3796,7 @@ MODULE_LICENSE("GPL");
 module_param(vpibits, uint, 0);
 MODULE_PARM_DESC(vpibits, "number of VPI bits supported (0, 1, or 2)");
 #ifdef CONFIG_ATM_IDT77252_DEBUG
-module_param(debug, ulong, 0644);
+module_param(debug, ulong, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug,   "debug bitmap, see drivers/atm/idt77252.h");
 #endif
 
-- 
2.9.2
