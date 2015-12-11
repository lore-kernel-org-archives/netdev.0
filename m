From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH 7/7] qeth: get rid of redundant 0-termination
Date: Fri, 11 Dec 2015 11:38:57 +0100
Message-ID: <1449830337-26091-8-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: ubraunu@linux.vnet.ibm.com
To: davem@davemloft.net, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:53897 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754822AbbLKKjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Dec 2015 05:39:17 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 11 Dec 2015 10:39:15 -0000
In-Reply-To: <1449830337-26091-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasmus Villemoes <linux@rasmusvillemoes.dk>

0-termination is redundant, since sprintf has done that.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 31ac53f..7b6ba07 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2684,8 +2684,6 @@ void qeth_print_status_message(struct qeth_card *card)
 			sprintf(card->info.mcl_level, "%02x%02x",
 				card->info.mcl_level[2],
 				card->info.mcl_level[3]);
-
-			card->info.mcl_level[QETH_MCL_LENGTH] = 0;
 			break;
 		}
 		/* fallthrough */
-- 
2.3.9
