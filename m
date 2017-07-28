From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 06/10] net/smc: remove Kconfig warning
Date: Fri, 28 Jul 2017 13:56:18 +0200
Message-ID: <20170728115622.17247-7-ubraun@linux.vnet.ibm.com>
References: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Cc: hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        linux-s390@vger.kernel.org, jwi@linux.vnet.ibm.com,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53068 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751713AbdG1L4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 07:56:41 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6SBrmZ0078552
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:41 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2c01jn228a-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 07:56:40 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 28 Jul 2017 12:56:39 +0100
In-Reply-To: <20170728115622.17247-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now separate memory regions are created and registered for separate
RMBs. The unsafe_global_rkey of the protection domain is no longer
used. Thus the exposing memory warning can be removed.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 net/smc/Kconfig | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/smc/Kconfig b/net/smc/Kconfig
index 33954852f3f8..c717ef0896aa 100644
--- a/net/smc/Kconfig
+++ b/net/smc/Kconfig
@@ -8,10 +8,6 @@ config SMC
 	  The Linux implementation of the SMC-R solution is designed as
 	  a separate socket family SMC.
 
-	  Warning: SMC will expose all memory for remote reads and writes
-	  once a connection is established.  Don't enable this option except
-	  for tightly controlled lab environment.
-
 	  Select this option if you want to run SMC socket applications
 
 config SMC_DIAG
-- 
2.11.2
