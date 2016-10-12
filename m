From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/3] s390 network driver patches
Date: Wed, 12 Oct 2016 12:38:48 +0200
Message-ID: <cover.1476263985.git.ursula.braun@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40838 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753494AbcJLKjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 06:39:39 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CAd0Aj011789
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:01 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 261djyh37d-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 06:39:00 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 12 Oct 2016 11:38:58 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are 3 small patches for the s390 network drivers netiucv and lcs.
They are built for the net-tree.

Thanks, Ursula

Ursula Braun (2):
  s390/netiucv: get rid of one memcpy in netiucv_printuser
  s390/netiucv: improve checking of sysfs attribute buffer

Colin Ian King (1):
  s390/lcs: remove trailing space at end of dev_err message

 drivers/s390/net/lcs.c     |  2 +-
 drivers/s390/net/netiucv.c | 17 ++++++++---------
 2 files changed, 9 insertions(+), 10 deletions(-)

-- 
2.8.4
