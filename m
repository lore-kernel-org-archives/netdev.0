From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/2] net: fix AF_SMC related typo
Date: Thu, 12 Jan 2017 14:57:14 +0100
Message-ID: <20170112135715.64242-2-ubraun@linux.vnet.ibm.com>
References: <20170112135715.64242-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:48697 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750791AbdALN6E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:58:04 -0500
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CDtHQw108560
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:27 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27x8a5f09h-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 08:57:27 -0500
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 13:57:24 -0000
In-Reply-To: <20170112135715.64242-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When introducing the new socket family AF_SMC in
commit ac7138746e14 ("smc: establish new socket family"),
a typo in af_family_clock_key_strings has slipped in.
This patch repairs it.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Fixes: ac7138746e14 ("smc: establish new socket family")
Reported-by: Andrew Morton <akpm@linux-foundation.org>
---
 net/core/sock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/sock.c b/net/core/sock.c
index dbbdc4f..8b35debf 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -256,7 +256,7 @@ static const char *const af_family_clock_key_strings[AF_MAX+1] = {
   "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
   "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
   "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_KCM"      ,
-  "clock-AF_QIPCRTR", "closck-AF_smc"    , "clock-AF_MAX"
+  "clock-AF_QIPCRTR", "clock-AF_SMC"     , "clock-AF_MAX"
 };
 
 /*
-- 
2.8.4
