From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/2] net/smc: fix typo and clc-bug
Date: Thu, 12 Jan 2017 14:57:13 +0100
Message-ID: <20170112135715.64242-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:36885 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750768AbdALN6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:58:04 -0500
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CDsCCi119850
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:23 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27x9h8c506-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:22 -0500
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 13:57:19 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

I received 2 bug reports for my new AF_SMC-code. Here are the fixes for them.

Thanks,
Ursula

Ursula Braun (2):
  smc-typo-in-core-sock
  smc-macaddr-len

 net/core/sock.c   |  2 +-
 net/smc/smc_clc.c | 10 ++++------
 net/smc/smc_ib.h  |  4 +++-
 3 files changed, 8 insertions(+), 8 deletions(-)

-- 
2.8.4
