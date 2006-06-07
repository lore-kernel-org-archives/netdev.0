From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 0/4] ehea: IBM eHEA Ethernet Device Driver
Date: Wed, 07 Jun 2006 17:12:45 +0200
Message-ID: <4486ECED.9080608@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: raisch@de.ibm.com, themann@de.ibm.com, tklein@de.ibm.com,
	meder@de.ibm.com, schickhj@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:59401 "EHLO
	mtagate4.de.ibm.com") by vger.kernel.org with ESMTP id S932164AbWFGPMu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jun 2006 11:12:50 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k57FCmae126622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 15:12:49 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k57FElFF105158
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:14:47 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k57FCmUU018768
	for <netdev@vger.kernel.org>; Wed, 7 Jun 2006 17:12:48 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

this is the first version of the IBM eHEA Ethernet Device Driver.
It supports a new IBM ethernet chip on System p.

Main functionality including broadcast multicast and some parts of
ethtool already work.

Things we're still working on:
- vlan support
- performance improvements in SMP systems
- kernel coding style

This code is not ready for kernel inclusion as is, but we definetly
want to get there.

The patch series consists of 4 patches
01: interfaces to network stack and headers
02: pHYP interface
03: queue managment
04: Kconfig and Makefile

Signed-off-by:  Jan-Bernd Themann <themann@de.ibm.com>

 drivers/net/ehea/Kconfig     |    6
 drivers/net/ehea/Makefile    |   45
 drivers/net/ehea/ehea.h      |  434 +++++++
 drivers/net/ehea/ehea_hw.h   |  319 +++++
 drivers/net/ehea/ehea_main.c | 2571 
+++++++++++++++++++++++++++++++++++++++++++
 drivers/net/ehea/ehea_phyp.c | 1026 +++++++++++++++++
 drivers/net/ehea/ehea_phyp.h |  625 ++++++++++
 drivers/net/ehea/ehea_qmr.c  |  719 ++++++++++++
 drivers/net/ehea/ehea_qmr.h  |  390 ++++++
 9 files changed, 6135 insertions(+)



