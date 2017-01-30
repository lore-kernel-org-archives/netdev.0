From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/1] smc: fix potential use after free
Date: Mon, 30 Jan 2017 10:55:03 +0100
Message-ID: <20170130095504.7940-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com, dan.carpenter@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:42138 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750898AbdA3J4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 04:56:41 -0500
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U9rho2058596
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 04:55:14 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
        by mx0a-001b2d01.pphosted.com with ESMTP id 288rb7jm8k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 04:55:14 -0500
Received: from localhost
        by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Mon, 30 Jan 2017 09:55:11 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

Hi Dave,

please add Dan's fix for the smc-code. Thanks, Dan and Dave!

Regards, Ursula Braun

Dan Carpenter (1):
  smc: Reset rx/tx buffer descriptor in case of errors

 net/smc/smc_core.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
2.8.4
