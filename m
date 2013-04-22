From: frank.blaschka@de.ibm.com
Subject: [patch 1/3] qeth: remove cast for kzalloc return value
Date: Mon, 22 Apr 2013 13:12:27 +0200
Message-ID: <20130422111238.267302846@de.ibm.com>
References: <20130422111226.882214164@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Zhang Yanfei <zhangyanfei@cn.fujitsu.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:53561 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524Ab3DVLMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 07:12:44 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 22 Apr 2013 12:09:52 +0100
Content-Disposition: inline; filename=600-qeth-kzalloc-cast.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

remove cast for kzalloc return value.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -316,7 +316,7 @@ static inline int qeth_alloc_cq(struct q
 
 		card->qdio.no_in_queues = 2;
 
-		card->qdio.out_bufstates = (struct qdio_outbuf_state *)
+		card->qdio.out_bufstates =
 			kzalloc(card->qdio.no_out_queues *
 				QDIO_MAX_BUFFERS_PER_Q *
 				sizeof(struct qdio_outbuf_state), GFP_KERNEL);
