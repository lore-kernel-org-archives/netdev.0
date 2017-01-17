From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/1] s390/qeth: remove legacy SNA-support
Date: Tue, 17 Jan 2017 13:39:50 +0100
Message-ID: <20170117123951.88480-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50867 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751203AbdAQMkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2017 07:40:02 -0500
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0HCcSJ5128732
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 07:40:01 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 281eu7uvqn-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 17 Jan 2017 07:40:00 -0500
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Tue, 17 Jan 2017 12:39:58 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

this is the qeth patch provided last week, you have not been happy with,
because you do not want to unilaterally remove support for a chipset.
I understand that, but I am not sure, if the stopped chip support of
vendors is considered to be something equivalent to the removal of
OSN support for s390. At least your arguments tell me that my original
patch description has been misleading.

OSN mode deals with the legacy IBM Systems Network Architecture
(SNA) protocol. Since s390 mainframes ceased to use the SNA protocol
and OSN mode reached its end of life, we do not want to keep code
just needed for legacy IBM SNA traffic in the kernel. Isn't such a
decision comparable for instance to the removal of Token Ring support
in 2012?

Thus am resending the qeth-patch one more time with a different
patch description.

Kind regards, Ursula

Ursula Braun (1):
  s390/qeth: remove legacy SNA-support

 drivers/s390/net/qeth_core.h      |  28 ----
 drivers/s390/net/qeth_core_main.c |  53 ++------
 drivers/s390/net/qeth_core_mpc.c  |   3 -
 drivers/s390/net/qeth_core_mpc.h  |  10 +-
 drivers/s390/net/qeth_core_sys.c  |  17 ---
 drivers/s390/net/qeth_l2_main.c   | 267 +++++++-------------------------------
 6 files changed, 56 insertions(+), 322 deletions(-)

-- 
2.8.4
