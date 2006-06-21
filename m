From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 5/6] ehea: eHEA Makefile
Date: Wed, 21 Jun 2006 14:41:59 +0200
Message-ID: <44993E97.50503@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:21982 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751536AbWFUMmF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:42:05 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k5LCg480179104
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:42:04 +0100
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LChJcq143936
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:43:19 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LCg0fw032494
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:42:00 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>


  drivers/net/ehea/Makefile |    7 +++++++
  1 file changed, 7 insertions(+)



--- linux-2.6.17.1-orig/drivers/net/ehea/Makefile	1969-12-31 16:00:00.000000000 -0800
+++ kernel/drivers/net/ehea/Makefile	2006-06-21 04:44:50.132489472 -0700
@@ -0,0 +1,7 @@
+#
+# Makefile for the eHEA ethernet device driver for IBM eServer System p
+#
+
+ehea_mod-objs = ehea_main.o ehea_phyp.o ehea_qmr.o ehea_ethtool.o ehea_phyp.o
+obj-$(CONFIG_EHEA) += ehea_mod.o
+

