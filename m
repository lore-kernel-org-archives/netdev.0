From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1096/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:17 +0800
Message-ID: <20160802121617.23201-1-baolex.ni@intel.com>
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, aduyck@mirantis.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, johan.hedberg@gmail.com,
	jiangshanlai@gmail.com, m.chehab@samsung.com,
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
 net/decnet/dn_dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index b2c26b0..77c28b6 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1396,7 +1396,7 @@ static const struct file_operations dn_dev_seq_fops = {
 #endif /* CONFIG_PROC_FS */
 
 static int addr[2];
-module_param_array(addr, int, NULL, 0444);
+module_param_array(addr, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(addr, "The DECnet address of this machine: area,node");
 
 void __init dn_dev_init(void)
-- 
2.9.2
