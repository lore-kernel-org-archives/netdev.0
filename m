From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 0/1] qeth: important fix to avoid panic on oops
Date: Mon,  4 Jul 2016 14:07:15 +0200
Message-ID: <1467634036-49548-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	stable@vger.kernel.org, schwidefsky@de.ibm.com,
	heiko.carstens@de.ibm.com, utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54885 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753158AbcGDMHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 08:07:24 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u64C4DXr131215
	for <netdev@vger.kernel.org>; Mon, 4 Jul 2016 08:07:23 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
	by mx0b-001b2d01.pphosted.com with ESMTP id 23x77wwspu-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 08:07:23 -0400
Received: from localhost
	by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 4 Jul 2016 13:07:22 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

here is an important qeth patch built for the net-tree fixing a qeth crash.

Thanks, Ursula

Ursula Braun (1):
  Subject: [PATCH] qeth: delete napi struct when removing a qeth device

 drivers/s390/net/qeth_l2_main.c | 1 +
 drivers/s390/net/qeth_l3_main.c | 1 +
 2 files changed, 2 insertions(+)

-- 
2.6.6
