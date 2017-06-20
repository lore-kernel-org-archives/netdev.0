From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/4] s390/net updates, part 2 (v2)
Date: Tue, 20 Jun 2017 16:00:30 +0200
Message-ID: <20170620140034.89661-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:46047 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751148AbdFTOAl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:00:41 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5KDx1g7083927
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 10:00:40 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2b734apk3q-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 20 Jun 2017 10:00:40 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 20 Jun 2017 15:00:38 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

thanks for the feedback. Here's an updated patchset that honours
the reverse christmas tree and drops the __packed attribute. Please apply.

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
