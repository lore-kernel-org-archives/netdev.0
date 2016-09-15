From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/7] 390: qeth patches
Date: Thu, 15 Sep 2016 14:39:20 +0200
Message-ID: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:37110 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934346AbcIOMjk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:40 -0400
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCX8Ch000636
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:38 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25f8ucurxe-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:37 -0400
Received: from localhost
        by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:35 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are several fixes for the s390 qeth driver, built for net.

Thanks,
Ursula

Hans Wippel (1):
  qeth: restore device features after recovery

Thomas Richter (1):
  s390/qeth: fix setting VIPA address

Ursula Braun (5):
  s390/qeth: use ip_lock for hsuid configuration
  s390/qeth: allow hsuid configuration in DOWN state
  qeth: check not more than 16 SBALEs on the completion queue
  qeth: do not limit number of gso segments
  qeth: do not turn on SG per default

 drivers/s390/net/qeth_core.h      |  1 +
 drivers/s390/net/qeth_core_main.c | 32 +++++++++++++++++++++++++++++++-
 drivers/s390/net/qeth_l2_main.c   |  6 +++---
 drivers/s390/net/qeth_l3_main.c   | 29 ++++++++++++++++++++---------
 drivers/s390/net/qeth_l3_sys.c    |  5 +++++
 5 files changed, 60 insertions(+), 13 deletions(-)

-- 
2.8.4
