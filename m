From: frank.blaschka@de.ibm.com
Subject: [patch 2/4] qeth: make qeth_query_card_info_cb() static
Date: Wed, 19 Mar 2014 07:58:00 +0100
Message-ID: <20140319065813.402896940@de.ibm.com>
References: <20140319065758.841490297@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp11.uk.ibm.com ([195.75.94.107]:41134 "EHLO
	e06smtp11.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbaCSG6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 02:58:17 -0400
Received: from /spool/local
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 19 Mar 2014 06:58:16 -0000
Content-Disposition: inline; filename=601-qeth-static-fns.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Heiko Carstens <heiko.carstens@de.ibm.com>

Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index a0aff2e..22470a3 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4610,8 +4610,8 @@ out:
 }
 EXPORT_SYMBOL_GPL(qeth_query_oat_command);
 
-int qeth_query_card_info_cb(struct qeth_card *card,
-			struct qeth_reply *reply, unsigned long data)
+static int qeth_query_card_info_cb(struct qeth_card *card,
+				   struct qeth_reply *reply, unsigned long data)
 {
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_query_card_info *card_info;
