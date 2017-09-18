From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 0/9] s390/qeth: updates 2017-09-18
Date: Mon, 18 Sep 2017 21:18:13 +0200
Message-ID: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37394 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750964AbdIRTT1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:19:27 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJJNE3046170
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:27 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2d2kdkawx4-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:19:26 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:20 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

first batch of patches for 4.15. One larger item in there is Hans'
addition of new configuration options for flexible packet processing
('VNIC characteristics'). The patch descriptions have all the details.
Please apply.

Thanks,
Julian

Hans Wippel (3):
  s390/qeth: add basic VNICC support
  s390/qeth: add VNICC enable/disable support
  s390/qeth: add VNICC get/set timeout support

Jens Remus (1):
  s390/qeth: tidy up parameter naming for qeth_do_send_packet()

Julian Wiedmann (5):
  s390/qeth: remove unused code in qdio_establish_cq()
  s390/qeth: don't take queue lock in send_packet_fast()
  s390/qeth: simplify L3 sysfs group management
  s390/qeth: translate SETVLAN/DELVLAN errors
  s390/qeth: fold VLAN handling into l3_rebuild_skb()

 drivers/s390/net/qeth_core.h      |  22 +-
 drivers/s390/net/qeth_core_main.c |  23 +-
 drivers/s390/net/qeth_core_mpc.c  |   4 +-
 drivers/s390/net/qeth_core_mpc.h  |  72 ++++++
 drivers/s390/net/qeth_l2.h        |   6 +
 drivers/s390/net/qeth_l2_main.c   | 517 ++++++++++++++++++++++++++++++++++++--
 drivers/s390/net/qeth_l2_sys.c    | 202 +++++++++++++--
 drivers/s390/net/qeth_l3_main.c   |  31 +--
 drivers/s390/net/qeth_l3_sys.c    |  45 +---
 9 files changed, 819 insertions(+), 103 deletions(-)

-- 
2.13.5
