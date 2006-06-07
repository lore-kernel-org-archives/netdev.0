From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 4/4] ehea: Kconfig and Makefile
Date: Wed, 07 Jun 2006 19:06:03 +0200
Message-ID: <4487077B.4020405@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:44399 "EHLO
	mtagate6.de.ibm.com") by vger.kernel.org with ESMTP id S932336AbWFGRGF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 13:06:05 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.6/8.13.6) with ESMTP id k57H641I065430
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:06:04 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k57H83KB109246
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 19:08:03 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k57H64BY017283
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 19:06:04 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by:  Jan-Bernd Themann <themann@de.ibm.com>


drivers/net/ehea/Kconfig  |    6 ++++++
drivers/net/ehea/Makefile |   45 +++++++++++++++++++++++++++++++++++++++++++++
2 files changed, 51 insertions(+)



--- linux-2.6.16-rc5-orig/drivers/net/ehea/Makefile    1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Makefile    2006-06-07 07:01:14.634178704 -0700
@@ -0,0 +1,45 @@
+# Server eHEA ethernet device driver for Linux on POWER
+#
+#
+#  linux/drivers/net/ehea/Makefile
+#
+#  eHEA ethernet device driver for IBM eServer System p
+#
+#  (C) Copyright IBM Corp. 2006
+#
+#  Authors:
+#       Christoph Raisch <raisch@de.ibm.com>
+#       Jan-Bernd Themann <themann@de.ibm.com>
+#       Heiko-Joerg Schick <schickhj@de.ibm.com>
+#       Thomas Klein <tklein@de.ibm.com>
+#
+#
+# This program is free software; you can redistribute it and/or modify
+# it under the terms of the GNU General Public License as published by
+# the Free Software Foundation; either version 2, or (at your option)
+# any later version.
+#
+# This program is distributed in the hope that it will be useful,
+# but WITHOUT ANY WARRANTY; without even the implied warranty of
+# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.     See the
+# GNU General Public License for more details.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software
+# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+
+
+
+
+# To compile module type:
+# make -C /root/linux-2.6.5-7.244 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m
+# make -C /usr/src/linux-2.6.17-rc5 SUBDIRS=`pwd` V=1 modules CONFIG_EHEA=m
+
+ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+
+obj-$(CONFIG_EHEA) += ehea_mod.o
+
+#CFLAGS += -Werror
+
+
+
--- linux-2.6.16-rc5-orig/drivers/net/ehea/Kconfig    1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Kconfig    2006-06-07 07:01:14.637178248 -0700
@@ -0,0 +1,6 @@
+config EHEA
+       tristate "eHEA Ethernet support"
+       depends on IBMEBUS
+       ---help---
+       This driver supports the IBM pSeries
+       Ethernet adapter



