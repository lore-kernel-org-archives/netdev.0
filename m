From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/13] s390/net: updates 2017-10-18
Date: Wed, 18 Oct 2017 17:40:12 +0200
Message-ID: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36214 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751619AbdJRPkj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:39 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdbQ6023638
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:39 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp5h61pdk-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:38 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:36 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please apply some additional robustness fixes and cleanups for 4.15.

Thanks,
Julian

Allen Pais (1):
  s390/drivers: use setup_timer

Andy Shevchenko (1):
  s390/qeth: use kstrtobool() in
    qeth_bridgeport_hostnotification_store()

Julian Wiedmann (11):
  s390/qeth: rely on kernel for feature recovery
  s390/qeth: remove duplicated device matching
  s390/qeth: fix early exit from error path
  s390/qeth: clean up initial MTU determination
  s390/qeth: don't verify device when setting MAC address
  s390/qeth: no VLAN support on OSM
  s390/qeth: clean up page frag creation
  s390/qeth: consolidate skb allocation
  s390/qeth: try harder to get packets from RX buffer
  s390/qeth: support GRO flush timer
  s390/qeth: don't dump control cmd twice

 drivers/s390/net/fsm.c            |   8 +-
 drivers/s390/net/qeth_core.h      |  16 +---
 drivers/s390/net/qeth_core_main.c | 187 ++++++++++++++------------------------
 drivers/s390/net/qeth_core_mpc.h  |   1 -
 drivers/s390/net/qeth_core_sys.c  |   4 +-
 drivers/s390/net/qeth_l2_main.c   |  40 ++------
 drivers/s390/net/qeth_l2_sys.c    |  13 +--
 drivers/s390/net/qeth_l3_main.c   |   6 +-
 8 files changed, 85 insertions(+), 190 deletions(-)

-- 
2.13.5
