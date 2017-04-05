From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/7] s390 patches for net-next
Date: Wed,  5 Apr 2017 10:40:08 +0200
Message-ID: <20170405084015.35772-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53725 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754557AbdDEIk2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 04:40:28 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v358d9XM031528
        for <netdev@vger.kernel.org>; Wed, 5 Apr 2017 04:40:28 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29muvdbjt3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 04:40:27 -0400
Received: from localhost
        by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 5 Apr 2017 09:40:25 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some cleanup patches for drivers/s390/net.

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
 drivers/s390/net/qeth_core_main.c | 35 +++++++++++++--------------
 drivers/s390/net/qeth_core_mpc.h  | 17 -------------
 drivers/s390/net/qeth_l2_main.c   |  1 -
 drivers/s390/net/qeth_l2_sys.c    |  3 ---
 drivers/s390/net/qeth_l3_main.c   | 50 ++++++++++++++++++---------------------
 drivers/s390/net/qeth_l3_sys.c    |  4 ++--
 10 files changed, 51 insertions(+), 91 deletions(-)

-- 
2.10.2
