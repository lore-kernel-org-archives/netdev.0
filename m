From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0753/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:57 +0800
Message-ID: <20160802114257.32317-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, daniel@iogearbox.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, baolex.ni@intel.com,
	hannes@stressinduktion.org, chuansheng.liu@intel.com
To: mst@redhat.com, f.fainelli@gmail.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com, kyungmin.park@samsung.com,
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
 drivers/net/virtio_net.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e0638e5..39815e4 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -30,11 +30,11 @@
 #include <net/busy_poll.h>
 
 static int napi_weight = NAPI_POLL_WEIGHT;
-module_param(napi_weight, int, 0444);
+module_param(napi_weight, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 static bool csum = true, gso = true;
-module_param(csum, bool, 0444);
-module_param(gso, bool, 0444);
+module_param(csum, bool, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(gso, bool, S_IRUSR | S_IRGRP | S_IROTH);
 
 /* FIXME: MTU in config. */
 #define GOOD_PACKET_LEN (ETH_HLEN + VLAN_HLEN + ETH_DATA_LEN)
-- 
2.9.2
