From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/4] s390/net updates, part 2
Date: Mon, 19 Jun 2017 13:22:21 +0200
Message-ID: <20170619112225.30471-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37656 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753711AbdFSLWk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 07:22:40 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5JBK28N151523
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 07:22:39 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b64sd6nnt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 19 Jun 2017 07:22:39 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 19 Jun 2017 12:22:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

some additional qeth patches for net-next, please apply.

Note: there's one out-of-topic modification to arch/s390 that
adds a new hypervisor call, for use in qeth. Heiko acked to upstream
this via your tree.

Thanks,
Julian


Julian Wiedmann (3):
  s390/qeth: fix packing buffer statistics
  s390/diag: add diag26c support
  s390/qeth: use diag26c to get MAC address on L2

Kittipon Meesompop (1):
  s390/qeth: add ipa return codes for bridgeport

 arch/s390/include/asm/diag.h      | 26 +++++++++++++
 arch/s390/kernel/diag.c           | 29 +++++++++++++++
 drivers/s390/net/qeth_core.h      |  1 +
 drivers/s390/net/qeth_core_main.c | 78 +++++++++++++++++++++++++++++++++++----
 drivers/s390/net/qeth_core_mpc.c  | 14 +++++++
 drivers/s390/net/qeth_core_mpc.h  | 18 +++++++++
 drivers/s390/net/qeth_l2_main.c   | 50 +++++++++++++++----------
 7 files changed, 190 insertions(+), 26 deletions(-)

-- 
2.11.2
