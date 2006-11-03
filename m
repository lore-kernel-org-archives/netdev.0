From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.19-rc4 2/3] ehea: Removed redundant define
Date: Fri, 3 Nov 2006 17:47:52 +0100
Message-ID: <200611031747.52210.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>, linux-ppc <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
To: Jeff Garzik <jeff@garzik.org>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org

Removed define H_CB_ALIGNMENT which is already defined in include/asm-powerpc/hvcall.h

Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---

diff -Nurp git.netdev-2.6.base/drivers/net/ehea/ehea.h git.netdev-2.6/drivers/net/ehea/ehea.h
--- git.netdev-2.6.base/drivers/net/ehea/ehea.h	2006-11-03 14:19:51.000000000 +0100
+++ git.netdev-2.6/drivers/net/ehea/ehea.h	2006-11-03 14:37:30.000000000 +0100
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0034"
+#define DRV_VERSION	"EHEA_0043"
 
 #define EHEA_MSG_DEFAULT (NETIF_MSG_LINK | NETIF_MSG_TIMER \
 	| NETIF_MSG_RX_ERR | NETIF_MSG_TX_ERR)
@@ -105,9 +105,6 @@
 #define EHEA_BCMC_VLANID_ALL	0x01
 #define EHEA_BCMC_VLANID_SINGLE	0x00
 
-/* Use this define to kmallocate pHYP control blocks */
-#define H_CB_ALIGNMENT		4096
-
 #define EHEA_CACHE_LINE          128
 
 /* Memory Regions */
