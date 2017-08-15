From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 00/12] s390/net: updates for 4.14
Date: Tue, 15 Aug 2017 17:02:38 +0200
Message-ID: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:56511 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752026AbdHOPDC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:02 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExqU2087339
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:01 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbsqvtmvy-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:01 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:02:59 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

a mixed bag of minor fixes, cleanups and refactors for net-next. Please apply.

Thanks,
Julian

Julian Wiedmann (9):
  s390/qeth: don't access skb after transmission
  s390/qeth: remove extra L2 adapterparms query
  s390/qeth: remove extra L3 adapterparms query
  s390/qeth: simplify fragment type selection
  s390/qeth: straighten out fill_buffer() interface
  s390/qeth: clean up fill_buffer() offset logic
  s390/qeth: make more use of skb API
  s390/net: reduce inlining
  s390/qeth: extract bridgeport cmd builder

Kittipon Meesompop (3):
  s390/qeth: reject multicast rxip addresses
  s390/qeth: fix trace-messages for deleting rxip addresses
  s390/qeth: fix using of ref counter for rxip addresses

 drivers/s390/net/ctcm_main.c      |   2 +-
 drivers/s390/net/lcs.c            |  28 ++++----
 drivers/s390/net/netiucv.c        |   4 +-
 drivers/s390/net/qeth_core.h      |  11 ++-
 drivers/s390/net/qeth_core_main.c | 147 ++++++++++++++++++--------------------
 drivers/s390/net/qeth_core_sys.c  |   2 +-
 drivers/s390/net/qeth_l2_main.c   | 116 +++++++++++-------------------
 drivers/s390/net/qeth_l3_main.c   |  49 +++++--------
 drivers/s390/net/qeth_l3_sys.c    |  17 +++++
 9 files changed, 169 insertions(+), 207 deletions(-)

-- 
2.11.2
