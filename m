From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] qeth: use default napi weight
Date: Mon, 24 Jun 2013 13:21:52 +0200
Message-ID: <20130624112226.861904661@de.ibm.com>
References: <20130624112147.347247916@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Sebastian Ott <sebott@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:34330 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab3FXLWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 07:22:32 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Jun 2013 12:15:07 +0100
Content-Disposition: inline; filename=604-qeth-default-napi-weight.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Ott <sebott@linux.vnet.ibm.com>

Since commit 82dc3c63c692b1e1d59378ecee948ac88e034aad
"net: introduce NAPI_POLL_WEIGHT" network drivers receive a warning
when they use napi weight higher than NAPI_POLL_WEIGHT. This patch
reduces QETH_NAPI_WEIGHT from 128 to 64 (NAPI_POLL_WEIGHT).

Signed-off-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -738,7 +738,7 @@ struct qeth_rx {
 	int qdio_err;
 };
 
-#define QETH_NAPI_WEIGHT 128
+#define QETH_NAPI_WEIGHT NAPI_POLL_WEIGHT
 
 struct qeth_card {
 	struct list_head list;
