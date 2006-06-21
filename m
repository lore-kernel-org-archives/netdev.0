From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 6/6] ehea: Makefile & Kconfig
Date: Wed, 21 Jun 2006 14:42:28 +0200
Message-ID: <44993EB4.6020908@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:28322 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751545AbWFUMmb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:42:31 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5LCgTZO043974
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 12:42:30 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LChmHv130864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:43:48 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LCgTNo001263
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:42:29 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/Kconfig  |    7 +++++++
  drivers/net/Makefile |    1 +
  2 files changed, 8 insertions(+)



diff -Nurp -X dontdiff linux-2.6.17.1/drivers/net/Kconfig patched_kernel/drivers/net/Kconfig
--- linux-2.6.17.1/drivers/net/Kconfig	2006-06-20 02:31:55.000000000 -0700
+++ patched_kernel/drivers/net/Kconfig	2006-06-20 03:53:45.896352432 -0700
@@ -2247,6 +2247,13 @@ config CHELSIO_T1
            To compile this driver as a module, choose M here: the module
            will be called cxgb.

+config EHEA
+        tristate "eHEA Ethernet support"
+        depends on IBMEBUS
+        ---help---
+          This driver supports the eHEA IBM ethernet adapter for eServer System p
+
+
  config IXGB
  	tristate "Intel(R) PRO/10GbE support"
  	depends on PCI
diff -Nurp -X dontdiff linux-2.6.17.1/drivers/net/Makefile patched_kernel/drivers/net/Makefile
--- linux-2.6.17.1/drivers/net/Makefile	2006-06-20 02:31:55.000000000 -0700
+++ patched_kernel/drivers/net/Makefile	2006-06-20 03:54:17.239380552 -0700
@@ -10,6 +10,7 @@ obj-$(CONFIG_E1000) += e1000/
  obj-$(CONFIG_IBM_EMAC) += ibm_emac/
  obj-$(CONFIG_IXGB) += ixgb/
  obj-$(CONFIG_CHELSIO_T1) += chelsio/
+obj-$(CONFIG_EHEA) += ehea/
  obj-$(CONFIG_BONDING) += bonding/
  obj-$(CONFIG_GIANFAR) += gianfar_driver.o


