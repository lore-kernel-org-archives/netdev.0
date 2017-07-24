From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 5/6] netvsc: include rtnetlink.h
Date: Mon, 24 Jul 2017 10:57:29 -0700
Message-ID: <20170724175730.31806-6-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Since these files use rtnl_derefernce make sure and include rtnetlink.h

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c   | 2 ++
 drivers/net/hyperv/rndis_filter.c | 1 +
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 99ae7fb6ec11..b2b0a1f96940 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -33,6 +33,8 @@
 #include <linux/if_vlan.h>
 #include <linux/in.h>
 #include <linux/slab.h>
+#include <linux/rtnetlink.h>
+
 #include <net/arp.h>
 #include <net/route.h>
 #include <net/sock.h>
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index e439886f72c1..eaa3f0d5682a 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -28,6 +28,7 @@
 #include <linux/if_vlan.h>
 #include <linux/nls.h>
 #include <linux/vmalloc.h>
+#include <linux/rtnetlink.h>
 
 #include "hyperv_net.h"
 
-- 
2.11.0
