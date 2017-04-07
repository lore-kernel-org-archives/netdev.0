From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 0/7] s390 patches for net-next
Date: Fri,  7 Apr 2017 09:15:31 +0200
Message-ID: <20170407071538.63253-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:50674 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753038AbdDGHPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 03:15:47 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3778gFu025548
        for <netdev@vger.kernel.org>; Fri, 7 Apr 2017 03:15:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29nsrar6c4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 03:15:46 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Apr 2017 08:15:44 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some cleanup patches for drivers/s390/net.
V2: respin, now patch "s390/qeth: improve endianness handling"
    is supposed to apply cleanly to net-next

Thanks, Ursula

Hans Wippel (3):
  s390/qeth: improve endianness handling
  s390/ctcm: improve endianness handling
  s390/netiucv: improve endianness handling

Julian Wiedmann (4):
  s390/qeth: use QDIO_*_QFMT defines
  s390/qeth: fix up ssqd tracing
  s390/qeth: remove unused return value
  s390/qeth: Remove unused code

 drivers/s390/net/ctcm_fsms.c      |  2 +-
 drivers/s390/net/ctcm_main.c      | 12 +++++-----
 drivers/s390/net/netiucv.c        |  2 +-
 drivers/s390/net/qeth_core.h      | 16 ++-----------
 drivers/s390/net/qeth_core_main.c | 35 +++++++++++++---------------
 drivers/s390/net/qeth_core_mpc.h  | 17 --------------
 drivers/s390/net/qeth_l2_main.c   |  1 -
 drivers/s390/net/qeth_l2_sys.c    |  3 ---
 drivers/s390/net/qeth_l3_main.c   | 48 ++++++++++++++++++---------------------
 drivers/s390/net/qeth_l3_sys.c    |  4 ++--
 10 files changed, 50 insertions(+), 90 deletions(-)

-- 
2.10.2
