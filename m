From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 7/7] ehea: Makefile & Kconfig
Date: Mon, 14 Aug 2006 18:32:00 +0200
Message-ID: <44E0A580.9020507@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-ppc <linuxppc-dev@ozlabs.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Marcus Eder <meder@de.ibm.com>,
	Christoph Raisch <raisch@de.ibm.com>,
	Thomas Klein <osstklei@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:10424 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1750927AbWHNQcC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Aug 2006 12:32:02 -0400
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/Kconfig  |    6 ++++++
  drivers/net/Makefile |    1 +
  2 files changed, 7 insertions(+)



diff -Nurp -X dontdiff linux-2.6.18-rc4/drivers/net/Kconfig patched_kernel/drivers/net/Kconfig
--- linux-2.6.18-rc4/drivers/net/Kconfig	2006-08-06 11:20:11.000000000 -0700
+++ patched_kernel/drivers/net/Kconfig	2006-08-08 03:00:49.526421944 -0700
@@ -2277,6 +2277,12 @@ config CHELSIO_T1
            To compile this driver as a module, choose M here: the module
            will be called cxgb.

+config EHEA
+        tristate "eHEA Ethernet support"
+        depends on IBMEBUS
+        ---help---
+          This driver supports the IBM pSeries ethernet adapter
+
  config IXGB
  	tristate "Intel(R) PRO/10GbE support"
  	depends on PCI
diff -Nurp -X dontdiff linux-2.6.18-rc4/drivers/net/Makefile patched_kernel/drivers/net/Makefile
--- linux-2.6.18-rc4/drivers/net/Makefile	2006-08-06 11:20:11.000000000 -0700
+++ patched_kernel/drivers/net/Makefile	2006-08-08 03:00:30.061451584 -0700
@@ -10,6 +10,7 @@ obj-$(CONFIG_E1000) += e1000/
  obj-$(CONFIG_IBM_EMAC) += ibm_emac/
  obj-$(CONFIG_IXGB) += ixgb/
  obj-$(CONFIG_CHELSIO_T1) += chelsio/
+obj-$(CONFIG_EHEA) += ehea/
  obj-$(CONFIG_BONDING) += bonding/
  obj-$(CONFIG_GIANFAR) += gianfar_driver.o



