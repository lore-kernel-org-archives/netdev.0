From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 0/6] ehea: IBM eHEA Ethernet Device Driver
Date: Wed, 21 Jun 2006 14:39:44 +0200
Message-ID: <44993E10.7040809@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:36966 "EHLO
	mtagate1.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751540AbWFUMk0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 08:40:26 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.6/8.13.6) with ESMTP id k5LCeNhp171412
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 12:40:25 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5LCgY2F045476
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 14:42:39 +0200
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5LCdicR026402
	for <netdev@vger.kernel.org>; Wed, 21 Jun 2006 13:39:45 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

one piece of the patch set posted on Thu, 08 Jun 2006 got lost
due to the spam filter of this mailing list. Here is the complete
patch set once again including the (previously missing) main component
in the patch 1/5.

Feedback is highly appreciated.

Thanks,
Jan-Bernd

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by:  Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg06022.html

Changelog:
- Comments triggering the spam filter removed


  drivers/net/Kconfig             |    7
  drivers/net/Makefile            |    1
  drivers/net/ehea/Makefile       |    7
  drivers/net/ehea/ehea.h         |  434 ++++++
  drivers/net/ehea/ehea_ethtool.c |  325 +++++
  drivers/net/ehea/ehea_hcall.h   |   52
  drivers/net/ehea/ehea_hw.h      |  319 ++++
  drivers/net/ehea/ehea_main.c    | 2557 ++++++++++++++++++++++++++++++++++++++++
  drivers/net/ehea/ehea_phyp.c    | 1020 +++++++++++++++
  drivers/net/ehea/ehea_phyp.h    |  625 +++++++++
  drivers/net/ehea/ehea_qmr.c     |  719 +++++++++++
  drivers/net/ehea/ehea_qmr.h     |  390 ++++++
  12 files changed, 6456 insertions(+)



