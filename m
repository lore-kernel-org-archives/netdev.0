From: Kumar Gala <galak@kernel.crashing.org>
Subject: [PATCH 1/2] gianfar: Remove unused header
Date: Tue, 31 Mar 2009 08:42:58 -0500
Message-ID: <1238506979-8678-1-git-send-email-galak@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org>
List-Unsubscribe: <https://ozlabs.org/mailman/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Now that the driver is exclusively an of_platform driver we no longer
use the structs and #defines in fsl_devices.h

Signed-off-by: Kumar Gala <galak@kernel.crashing.org>
---
 drivers/net/gianfar.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index dd499d7..0642d52 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -45,7 +45,6 @@
 #include <linux/crc32.h>
 #include <linux/workqueue.h>
 #include <linux/ethtool.h>
-#include <linux/fsl_devices.h>
 
 /* The maximum number of packets to be handled in one call of gfar_poll */
 #define GFAR_DEV_WEIGHT 64
-- 
1.5.6.6
