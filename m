From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 0/5] ehea: IBM eHEA Ethernet Device Driver
Date: Thu, 08 Jun 2006 11:55:18 +0200
Message-ID: <4487F406.6040907@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:35964 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP id S964810AbWFHJzU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 05:55:20 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k589tJLG095582
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 09:55:19 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k589vIb6100990
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:57:18 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k589tIpm011410
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:55:18 +0200
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

thanks for your comments. It seems that yesterday's patch 1/4 has not been
delivered. We changed some things according to your comments.

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by:  Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg05813.html

Changelog:

- reduce number of parameters for debug macro calls
- ehea prefix added to some non static functions
- Makefile and Kconfig improved

  drivers/net/ehea/Kconfig     |    6
  drivers/net/ehea/Makefile    |    7
  drivers/net/ehea/ehea.h      |  434 +++++++
  drivers/net/ehea/ehea_hw.h   |  319 +++++
  drivers/net/ehea/ehea_main.c | 2562 +++++++++++++++++++++++++++++++++++++++++++
  drivers/net/ehea/ehea_phyp.c | 1023 +++++++++++++++++
  drivers/net/ehea/ehea_phyp.h |  625 ++++++++++
  drivers/net/ehea/ehea_qmr.c  |  719 ++++++++++++
  drivers/net/ehea/ehea_qmr.h  |  390 ++++++
  9 files changed, 6085 insertions(+)


