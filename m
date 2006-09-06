From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 7/7] ehea: Makefile & Kconfig
Date: Wed, 6 Sep 2006 15:38:34 +0200
Message-ID: <200609061538.34319.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <tklein@de.ibm.com>, Jan-Bernd Themann <themann@de.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-ppc <linuxppc-dev@ozlabs.org>, Christoph Raisch <raisch@de.ibm.com>,
	Marcus Eder <meder@de.ibm.com>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>
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

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com> 


 drivers/net/Kconfig  |    9 +++++++++
 drivers/net/Makefile |    1 +
 2 files changed, 10 insertions(+)



diff -Nurp -X dontdiff linux-2.6.18-rc6/drivers/net/Kconfig patched_kernel/drivers/net/Kconfig
--- linux-2.6.18-rc6/drivers/net/Kconfig	2006-09-04 04:19:48.000000000 +0200
+++ patched_kernel/drivers/net/Kconfig	2006-09-04 11:38:59.000000000 +0200
@@ -2318,6 +2318,15 @@ config CHELSIO_T1
           To compile this driver as a module, choose M here: the module
           will be called cxgb.
 
+config EHEA
+	tristate "eHEA Ethernet support"
+	depends on IBMEBUS
+	---help---
+	  This driver supports the IBM pSeries eHEA ethernet adapter.
+
+	  To compile the driver as a module, choose M here. The module
+	  will be called ehea.
+
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
 	depends on PCI
diff -Nurp -X dontdiff linux-2.6.18-rc6/drivers/net/Makefile patched_kernel/drivers/net/Makefile
--- linux-2.6.18-rc6/drivers/net/Makefile	2006-09-04 04:19:48.000000000 +0200
+++ patched_kernel/drivers/net/Makefile	2006-09-04 11:39:06.000000000 +0200
@@ -10,6 +10,7 @@ obj-$(CONFIG_E1000) += e1000/
 obj-$(CONFIG_IBM_EMAC) += ibm_emac/
 obj-$(CONFIG_IXGB) += ixgb/
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
+obj-$(CONFIG_EHEA) += ehea/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
