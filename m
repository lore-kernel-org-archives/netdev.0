From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1103/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:16:52 +0800
Message-ID: <20160802121652.23664-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, aarcange@redhat.com,
	aryabinin@virtuozzo.com
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, m.szyprowski@samsung.com,
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
 net/ipv4/tcp_cubic.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp_cubic.c
index c99230e..c05e380 100644
--- a/net/ipv4/tcp_cubic.c
+++ b/net/ipv4/tcp_cubic.c
@@ -59,24 +59,24 @@ static u32 beta_scale __read_mostly;
 static u64 cube_factor __read_mostly;
 
 /* Note parameters that are used for precomputing scale factors are read-only */
-module_param(fast_convergence, int, 0644);
+module_param(fast_convergence, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fast_convergence, "turn on/off fast convergence");
-module_param(beta, int, 0644);
+module_param(beta, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(beta, "beta for multiplicative increase");
-module_param(initial_ssthresh, int, 0644);
+module_param(initial_ssthresh, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(initial_ssthresh, "initial value of slow start threshold");
-module_param(bic_scale, int, 0444);
+module_param(bic_scale, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bic_scale, "scale (scaled by 1024) value for bic function (bic_scale/1024)");
-module_param(tcp_friendliness, int, 0644);
+module_param(tcp_friendliness, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(tcp_friendliness, "turn on/off tcp friendliness");
-module_param(hystart, int, 0644);
+module_param(hystart, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hystart, "turn on/off hybrid slow start algorithm");
-module_param(hystart_detect, int, 0644);
+module_param(hystart_detect, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hystart_detect, "hyrbrid slow start detection mechanisms"
 		 " 1: packet-train 2: delay 3: both packet-train and delay");
-module_param(hystart_low_window, int, 0644);
+module_param(hystart_low_window, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hystart_low_window, "lower bound cwnd for hybrid slow start");
-module_param(hystart_ack_delta, int, 0644);
+module_param(hystart_ack_delta, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hystart_ack_delta, "spacing between ack's indicating train (msecs)");
 
 /* BIC TCP Parameters */
-- 
2.9.2
