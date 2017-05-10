From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net 0/4] s390/net fixes
Date: Wed, 10 May 2017 19:07:50 +0200
Message-ID: <20170510170754.53922-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:33225 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753585AbdEJRIK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 13:08:10 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4AH3fZK094311
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:09 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2abhbb664k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:09 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 10 May 2017 18:08:06 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

some qeth fixes for -net, the OSM/OSN one being the most crucial.
Please also queue these up for stable.

Thanks,
Julian

Julian Wiedmann (2):
  s390/qeth: unbreak OSM and OSN support
  s390/qeth: avoid null pointer dereference on OSN

Ursula Braun (2):
  s390/qeth: handle sysfs error during initialization
  s390/qeth: add missing hash table initializations

 drivers/s390/net/qeth_core.h      |  4 ++++
 drivers/s390/net/qeth_core_main.c | 21 ++++++++++++---------
 drivers/s390/net/qeth_core_sys.c  | 24 ++++++++++++++++--------
 drivers/s390/net/qeth_l2.h        |  2 ++
 drivers/s390/net/qeth_l2_main.c   | 26 ++++++++++++++++++++------
 drivers/s390/net/qeth_l2_sys.c    |  8 ++++++++
 drivers/s390/net/qeth_l3_main.c   |  8 +++++++-
 7 files changed, 69 insertions(+), 24 deletions(-)

-- 
2.10.2
