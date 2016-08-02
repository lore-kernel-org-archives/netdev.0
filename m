From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1088/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:15:27 +0800
Message-ID: <20160802121527.22660-1-baolex.ni@intel.com>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, mhocko@suse.com, koct9i@gmail.com,
	aarcange@redhat.com, aryabinin@virtuozzo.com
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
 net/bluetooth/l2cap_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
index eb4f5f2..1dfb4bc 100644
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -7636,5 +7636,5 @@ void l2cap_exit(void)
 	l2cap_cleanup_sockets();
 }
 
-module_param(disable_ertm, bool, 0644);
+module_param(disable_ertm, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(disable_ertm, "Disable enhanced retransmission mode");
-- 
2.9.2
