From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 00/12] s390: qeth patches
Date: Thu, 12 Jan 2017 15:48:31 +0100
Message-ID: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45943 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750730AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmnHL142571
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:53 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27xaca42nd-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:53 -0500
Received: from localhost
        by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:49 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

yesterday I came up with 13 qeth patches. Since you have not been
happy with the 13th patch, I want to make sure that at least the
remaining 12 qeth patches can be applied to net-next. Here is the
resend of them.

Thanks,
Ursula

Julian Wiedmann (8):
  s390/qeth: Allow reading hsuid in state DOWN
  s390/qeth: Remove QETH_IP_HEADER_SIZE
  s390/qeth: drop qeth_l2_del_all_macs() parameter
  s390/qeth: don't convert return code twice
  s390/qeth: consolidate errno translation
  s390/qeth: extract qeth_l2_remove_mac()
  s390/qeth: shuffle MAC management functions around
  s390/qeth: issue STARTLAN as first IPA command

Thomas Richter (3):
  s390/qeth: rework RX/TX checksum offload
  s390/qeth: test RX/TX checksum offload reply
  s390/qeth: display warning for OSA3 RX/TX checksum offloading

Ursula Braun (1):
  s390/qeth: fix retrieval of vipa and proxy-arp addresses

 drivers/s390/net/qeth_core.h      |   5 -
 drivers/s390/net/qeth_core_main.c | 135 ++++++++++++++++++++-------
 drivers/s390/net/qeth_core_mpc.h  |  17 ++++
 drivers/s390/net/qeth_l2_main.c   | 189 ++++++++++++++++----------------------
 drivers/s390/net/qeth_l3_main.c   |  15 ---
 drivers/s390/net/qeth_l3_sys.c    |  33 ++++---
 6 files changed, 212 insertions(+), 182 deletions(-)

-- 
2.8.4
