From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/10] more s390/net updates
Date: Tue, 11 Apr 2017 16:11:09 +0200
Message-ID: <20170411141119.82526-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:45193 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751921AbdDKOLh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:11:37 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3BE8m55123687
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:36 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29rrne5vu9-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 10:11:36 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 11 Apr 2017 15:11:33 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a second batch of s390/net patches for net-next.
A mixed bunch of qeth cleanups, and a few patches to add support for
ETHTOOL_GLINKSETTINGS.

Thanks,
Julian

Julian Wiedmann (10):
  s390/qeth: move common ioctl handling to core
  s390/qeth: move NAPI poll routine to core
  s390/qeth: move gdev shutdown handler to core
  s390/qeth: remove unused parameter
  s390/qeth: use correct return type for hard_start_xmit()
  s390/qeth: use and remove some defines
  s390/qeth: clean up qeth_set_ecmd_adv_sup()
  s390/qeth: convert to ETHTOOL_GLINKSETTINGS API
  s390/qeth: use LINK_MODE_* to report the link characteristics
  s390/qeth: remove unimplemented gdev routines

 drivers/s390/net/qeth_core.h      |  21 +--
 drivers/s390/net/qeth_core_main.c | 349 ++++++++++++++++++++++++++------------
 drivers/s390/net/qeth_l2_main.c   | 153 +----------------
 drivers/s390/net/qeth_l3_main.c   | 138 +--------------
 4 files changed, 268 insertions(+), 393 deletions(-)

-- 
2.10.2
