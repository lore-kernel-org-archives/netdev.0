From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/2] af_iucv updates
Date: Fri, 23 Jun 2017 19:32:26 +0200
Message-ID: <20170623173228.70128-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:49295 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1754209AbdFWRcw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:32:52 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5NHTINc106039
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:41 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2b8yuhxg8a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Jun 2017 13:32:41 -0400
Received: from localhost
        by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Fri, 23 Jun 2017 18:32:39 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,
please apply two af_iucv patches for net-next.

Thanks,
Julian


Hans Wippel (1):
  net/iucv: improve endianness handling

Mateusz Jurczyk (1):
  af_iucv: Move sockaddr length checks to before accessing sa_family in
    bind and connect handlers

 net/iucv/af_iucv.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

-- 
2.11.2
