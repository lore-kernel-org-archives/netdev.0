From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 02/39] mv643xx_eth: trim unnecessary includes
Date: Tue,  3 Jun 2008 13:02:17 +0200
Message-ID: <1212490974-23719-3-git-send-email-buytenh@wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:48755 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756115AbYFCMAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 08:00:42 -0400
In-Reply-To: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   18 +-----------------
 1 files changed, 1 insertions(+), 17 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 835b85d..c04058c 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -34,34 +34,18 @@
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
-#include <linux/init.h>
-#include <linux/dma-mapping.h>
+
 #include <linux/in.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/etherdevice.h>
-
-#include <linux/bitops.h>
-#include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/platform_device.h>
-
 #include <linux/module.h>
-#include <linux/kernel.h>
 #include <linux/spinlock.h>
-#include <linux/workqueue.h>
 #include <linux/mii.h>
-
 #include <linux/mv643xx_eth.h>
 
-#include <asm/io.h>
-#include <asm/types.h>
-#include <asm/pgtable.h>
-#include <asm/system.h>
-#include <asm/delay.h>
-#include <asm/dma-mapping.h>
-
 static char mv643xx_driver_name[] = "mv643xx_eth";
 static char mv643xx_driver_version[] = "1.0";
 
-- 
1.5.3.4

