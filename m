From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/9] net/smc: bug fixes 2017-09-20
Date: Thu, 21 Sep 2017 09:16:25 +0200
Message-ID: <20170921071634.16883-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57020 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751484AbdIUHQm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:16:42 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8L7F1dJ072798
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:42 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d462f6x53-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 03:16:41 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 21 Sep 2017 08:16:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is a collection of small smc-patches built for net fixing
smc problems in different areas.

Thanks,
Ursula
*** BLURB HERE ***

Hans Wippel (2):
  net/smc: add missing dev_put
  net/smc: add receive timeout check

Ursula Braun (7):
  net/smc: take RCU read lock for routing cache lookup
  net/smc: adjust net_device refcount
  net/smc: adapt send request completion notification
  net/smc: longer delay for client link group removal
  net/smc: terminate link group if out-of-sync is received
  net/smc: introduce a delay
  net/smc: no close wait in case of process shut down

 net/smc/af_smc.c    | 16 +++++++++-------
 net/smc/smc.h       |  2 +-
 net/smc/smc_clc.c   | 10 +++++-----
 net/smc/smc_clc.h   |  3 +--
 net/smc/smc_close.c | 27 +++++++++++++++------------
 net/smc/smc_core.c  | 16 ++++++++++++----
 net/smc/smc_ib.c    |  1 +
 net/smc/smc_pnet.c  |  4 +++-
 net/smc/smc_rx.c    |  2 ++
 net/smc/smc_tx.c    | 12 ++++++++----
 net/smc/smc_wr.c    |  2 +-
 11 files changed, 58 insertions(+), 37 deletions(-)

-- 
2.13.5
