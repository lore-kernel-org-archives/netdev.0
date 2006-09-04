From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [2.6.19 PATCH 7/7] ehea: Makefile & Kconfig
Date: Mon, 4 Sep 2006 12:44:53 +0200
Message-ID: <200609041244.53416.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:16481 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP id S964793AbWIDL07
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Sep 2006 07:26:59 -0400
Content-Disposition: inline
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
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
 

-- 
VGER BF report: H 0.160317
