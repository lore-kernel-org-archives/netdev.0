From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/12] s390/qeth: fix trace-messages for deleting rxip addresses
Date: Tue, 15 Aug 2017 17:02:49 +0200
Message-ID: <20170815150250.67158-12-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:37276 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752696AbdHOPDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:18 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExL40092703
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:18 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2cbwxtf05j-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:18 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:16 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>

change trace-messages:
- from addrxip4 to delrxip4
- from addrxip6 to delrxip6

Signed-off-by: Kittipon Meesompop <kmeesomp@linux.vnet.ibm.com>
Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 140ed124d2f0..41bd00454d0f 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -784,11 +784,11 @@ void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions proto,
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_CARD_TEXT(card, 2, "addrxip4");
+			QETH_CARD_TEXT(card, 2, "delrxip4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_CARD_TEXT(card, 2, "addrxip6");
+			QETH_CARD_TEXT(card, 2, "delrxip6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
-- 
2.11.2
