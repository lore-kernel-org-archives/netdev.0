From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/9] s390/net updates
Date: Tue,  6 Jun 2017 14:33:41 +0200
Message-ID: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:43916 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751391AbdFFMd7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:33:59 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXgXN124999
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:33:59 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2awp6bk6hc-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:33:58 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:33:56 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

please apply the following qeth updates for net-next.

Aside from some janitorial changes, this adds early setup for virtualized
HiperSockets devices - building upon the code that landed via -net earlier.

Thanks,
Julian

Julian Wiedmann (8):
  s390/qeth: remove support for IPA_IP_FRAGMENTATION
  s390/qeth: remove skb_is_nonlinear() check on IQD
  s390/qeth: query IPv6 IPA support on HiperSockets
  s390/qeth: log bridgeport capabilities
  s390/qeth: add missing strings for IPA return codes
  s390/qeth: consolidate pack buffer flushing
  s390/qeth: silence qeth_fix_features()
  s390/qeth: do early device setup for z/VM IQD NICs

Ursula Braun (1):
  s390/qeth: add support for early L3 device setup

 drivers/s390/net/qeth_core.h      |   2 +
 drivers/s390/net/qeth_core_main.c | 117 ++++++++++++++++++++------------------
 drivers/s390/net/qeth_core_mpc.c  |   2 +
 drivers/s390/net/qeth_core_mpc.h  |   2 +-
 drivers/s390/net/qeth_core_sys.c  |   2 +-
 drivers/s390/net/qeth_l2_main.c   |   8 +++
 drivers/s390/net/qeth_l3.h        |   1 +
 drivers/s390/net/qeth_l3_main.c   |  59 ++++++-------------
 drivers/s390/net/qeth_l3_sys.c    |  11 ++++
 9 files changed, 105 insertions(+), 99 deletions(-)

-- 
2.11.2
