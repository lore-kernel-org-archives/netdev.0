From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1083/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:14:55 +0800
Message-ID: <20160802121455.22326-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, oleg@redhat.com,
	gang.chen.5i5j@gmail.com, mhocko@suse.com, koct9i@gmail.com,
	aarcange@redhat.com, aryabinin@virtuozzo.com
To: davem@davemloft.net, jiangshanlai@gmail.com, rostedt@goodmis.org,
	mathieu.desnoyers@efficios.com, m.chehab@samsung.com,
	gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/802/garp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index b38ee6d..ecc976a 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -22,7 +22,7 @@
 #include <asm/unaligned.h>
 
 static unsigned int garp_join_time __read_mostly = 200;
-module_param(garp_join_time, uint, 0644);
+module_param(garp_join_time, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(garp_join_time, "Join time in ms (default 200ms)");
 MODULE_LICENSE("GPL");
 
-- 
2.9.2
