From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/2] s390: af_iucv patches
Date: Fri,  7 Oct 2016 15:51:46 +0200
Message-ID: <cover.1475846599.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:60158 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756240AbcJGNv5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 09:51:57 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u97DnrAs050582
        for <netdev@vger.kernel.org>; Fri, 7 Oct 2016 09:51:56 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25xcb91nfu-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2016 09:51:56 -0400
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Fri, 7 Oct 2016 14:51:54 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 2 patches for the s390-only af_iucv socket family code.

Thanks, Ursula

Ursula Braun (2):
  Subject: [PATCH] af_iucv: enable control sends in case of
    SEND_SHUTDOWN
  Subject: [PATCH] af_iucv: drop skbs rejected by filter

 net/iucv/af_iucv.c | 34 ++++++++++++++++++++++++++--------
 1 file changed, 26 insertions(+), 8 deletions(-)

-- 
2.8.4
