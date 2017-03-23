From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/3] s390/qeth patches for net
Date: Thu, 23 Mar 2017 14:55:07 +0100
Message-ID: <20170323135510.98972-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        jwi@linux.vnet.ibm.com, schwidefsky@de.ibm.com,
        heiko.carstens@de.ibm.com, raspl@linux.vnet.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42351 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755859AbdCWNzX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:55:23 -0400
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2NDrvM0026523
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0a-001b2d01.pphosted.com with ESMTP id 29c4yw7j8s-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 09:55:22 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 23 Mar 2017 13:55:18 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 2 s390/qeth patches built for net fixing a problem with AF_IUCV
traffic through HiperSockets.
And we come up with an update for the MAINTAINERS file to establish
Julian as Co-Maintainer for drivers/s390/net and net/iucv.

Thanks, Ursula

Julian Wiedmann (2):
  s390/qeth: size calculation outbound buffers
  s390/qeth: no ETH header for outbound AF_IUCV

Ursula Braun (1):
  MAINTAINERS: add Julian Wiedmann

 MAINTAINERS                       |  2 ++
 drivers/s390/net/qeth_core.h      |  3 ++-
 drivers/s390/net/qeth_core_main.c |  5 +++--
 drivers/s390/net/qeth_l2_main.c   |  5 +++--
 drivers/s390/net/qeth_l3_main.c   | 20 +++++++-------------
 5 files changed, 17 insertions(+), 18 deletions(-)
