From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1087/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:15:20 +0800
Message-ID: <20160802121520.22594-1-baolex.ni@intel.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, danny.schweizer@proofnet.de,
	chuansheng.liu@intel.com, baolex.ni@intel.com, mhocko@suse.com,
	koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com
To: marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
	davem@davemloft.net, jiangshanlai@gmail.com, m.chehab@samsung.com,
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
 net/bluetooth/bnep/core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/bnep/core.c b/net/bluetooth/bnep/core.c
index fbf251f..d8f9f58 100644
--- a/net/bluetooth/bnep/core.c
+++ b/net/bluetooth/bnep/core.c
@@ -759,10 +759,10 @@ static void __exit bnep_exit(void)
 module_init(bnep_init);
 module_exit(bnep_exit);
 
-module_param(compress_src, bool, 0644);
+module_param(compress_src, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(compress_src, "Compress sources headers");
 
-module_param(compress_dst, bool, 0644);
+module_param(compress_dst, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(compress_dst, "Compress destination headers");
 
 MODULE_AUTHOR("Marcel Holtmann <marcel@holtmann.org>");
-- 
2.9.2
