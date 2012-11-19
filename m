From: frank.blaschka@de.ibm.com
Subject: [patch 1/6] [PATCH] qeth: Remove unused variable
Date: Mon, 19 Nov 2012 13:46:45 +0100
Message-ID: <20121119124659.406423144@de.ibm.com>
References: <20121119124644.679089322@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:49158 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751776Ab2KSMrF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 07:47:05 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 19 Nov 2012 12:47:02 -0000
Content-Disposition: inline; filename=601-qeth-unused-variable.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Eliminate a variable that is never modified.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2280,7 +2280,6 @@ static int qeth_ulp_setup_cb(struct qeth
 		unsigned long data)
 {
 	struct qeth_cmd_buffer *iob;
-	int rc = 0;
 
 	QETH_DBF_TEXT(SETUP, 2, "ulpstpcb");
 
@@ -2296,7 +2295,7 @@ static int qeth_ulp_setup_cb(struct qeth
 		iob->rc = -EMLINK;
 	}
 	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
-	return rc;
+	return 0;
 }
 
 static int qeth_ulp_setup(struct qeth_card *card)
