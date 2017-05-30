From: mikelley@exchange.microsoft.com
Subject: [PATCH v2 net-next 1/1] netvsc: Add #include's for csum_* function
 declarations
Date: Tue, 30 May 2017 11:36:56 -0700
Message-ID: <1496169416-23563-1-git-send-email-mikelley@exchange.microsoft.com>
Reply-To: mikelley@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Michael Kelley <mikelley@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
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

From: Michael Kelley <mikelley@microsoft.com>

Add direct #include statements for declarations of csum_tcpudp_magic()
and csum_ipv6_magic().  While the needed #include's are picked up
indirectly for the x86 architecture, they aren't on other
architectures, resulting in compile errors.

Signed-off-by: Michael Kelley <mikelley@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 4421a6d..2564ac8 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -37,6 +37,8 @@
 #include <net/route.h>
 #include <net/sock.h>
 #include <net/pkt_sched.h>
+#include <net/checksum.h>
+#include <net/ip6_checksum.h>
 
 #include "hyperv_net.h"
 
-- 
1.7.1
