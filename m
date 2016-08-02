From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0992/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:06:07 +0800
Message-ID: <20160802120607.16209-1-baolex.ni@intel.com>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	mathias.nyman@linux.intel.com, stern@rowland.harvard.edu,
	oneukum@suse.com
To: mst@redhat.com, gregkh@linuxfoundation.org, m.chehab@samsung.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/vhost/vhost.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index 669fef1..bf338d1 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -31,7 +31,7 @@
 #include "vhost.h"
 
 static ushort max_mem_regions = 64;
-module_param(max_mem_regions, ushort, 0444);
+module_param(max_mem_regions, ushort, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_mem_regions,
 	"Maximum number of memory regions in memory map. (default: 64)");
 
-- 
2.9.2

