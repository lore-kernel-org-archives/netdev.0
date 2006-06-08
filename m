From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 5/5] ehea: makefile and Kconfig
Date: Thu, 08 Jun 2006 11:56:05 +0200
Message-ID: <4487F435.7090007@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:47524 "EHLO
	mtagate2.de.ibm.com") by vger.kernel.org with ESMTP id S932115AbWFHJ4H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 05:56:07 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.6/8.13.6) with ESMTP id k589u6YS153348
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 09:56:06 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k589w5qI112258
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:58:05 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k589u56B013170
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:56:05 +0200
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/ehea/Kconfig  |    6 ++++++
  drivers/net/ehea/Makefile |    7 +++++++
  2 files changed, 13 insertions(+)



--- linux-2.6.16-rc5-orig/drivers/net/ehea/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Makefile	2006-06-08 01:58:28.839212488 -0700
@@ -0,0 +1,7 @@
+#
+# Makefile for the eHEA ethernet device driver for IBM eServer System p
+#
+
+ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+obj-$(CONFIG_EHEA) += ehea_mod.o
+
--- linux-2.6.16-rc5-orig/drivers/net/ehea/Kconfig	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Kconfig	2006-06-08 01:58:28.842212032 -0700
@@ -0,0 +1,6 @@
+config EHEA
+       tristate "eHEA Ethernet support"
+       depends on IBMEBUS
+       ---help---
+       This driver supports the IBM pSeries ethernet adapter
+


