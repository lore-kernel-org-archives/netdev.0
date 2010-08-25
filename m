From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next-2.6 1/1]: bna: Fix build break for allyesconfig
Date: Wed, 25 Aug 2010 14:32:10 -0700
Message-ID: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <amathur@brocade.com>, <ddutt@brocade.com>, <huangj@brocade.com>,
	<rmody@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:50352 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752894Ab0HYVcN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 17:32:13 -0400
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o7PLU12g021096
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 14:32:12 -0700
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.140.11])
	by mx0b-000f0801.pphosted.com with ESMTP id qw7wwg62p-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 14:32:12 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This patch contains a fix for the build break caused by multiple
definitions of symbols between Brocade's FC/FCOE driver(BFA) 
and 10G Networking Driver(BNA).

The fix is to make BNA a module only driver.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 Kconfig |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -ruP net-next-2.6.36-rc1-orig/drivers/net/Kconfig net-next-2.6.36-rc1-mod/drivers/net/Kconfig
--- net-next-2.6.36-rc1-orig/drivers/net/Kconfig	2010-08-25 00:59:00.000000000 -0700
+++ net-next-2.6.36-rc1-mod/drivers/net/Kconfig	2010-08-25 14:24:54.236217000 -0700
@@ -2871,7 +2871,7 @@
 
 config BNA
         tristate "Brocade 1010/1020 10Gb Ethernet Driver support"
-        depends on PCI
+        depends on PCI && m
         ---help---
           This driver supports Brocade 1010/1020 10Gb CEE capable Ethernet
           cards.
