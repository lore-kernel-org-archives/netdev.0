From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0991/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:06:01 +0800
Message-ID: <20160802120601.16143-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mathias.nyman@linux.intel.com, kvm@vger.kernel.org, netdev@vger.kernel.org,
	oneukum@suse.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, baolex.ni@intel.com,
	stern@rowland.harvard.edu, chuansheng.liu@intel.com
To: mst@redhat.com, gregkh@linuxfoundation.org, m.chehab@samsung.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/vhost/net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
index f744eeb..e6d5620 100644
--- a/drivers/vhost/net.c
+++ b/drivers/vhost/net.c
@@ -31,7 +31,7 @@
 #include "vhost.h"
 
 static int experimental_zcopytx = 1;
-module_param(experimental_zcopytx, int, 0444);
+module_param(experimental_zcopytx, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
 		                       " 1 -Enable; 0 - Disable");
 
-- 
2.9.2
