From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/5] qeth: remove extraneous length from %pM format
Date: Tue, 15 Sep 2015 12:32:14 +0200
Message-ID: <1442313138-64526-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1442313138-64526-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:59453 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751955AbbIOKc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 06:32:27 -0400
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Tue, 15 Sep 2015 11:32:26 +0100
In-Reply-To: <1442313138-64526-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Length specifier in the %pM format is not supported (at least, not
documented). Remove it, and also an extraneous '&' for the array.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Suggested-by: Joe Perches <joe@perches.com>
---
 drivers/s390/net/qeth_l2_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index a855669..693c6dbd 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1452,8 +1452,8 @@ static void qeth_bridge_emit_host_event(struct qeth_card *card,
 			env[i] = str[i]; i++;
 		}
 		if (code & IPA_ADDR_CHANGE_CODE_MACADDR) {
-			snprintf(str[i], sizeof(str[i]), "MAC=%pM6",
-				&addr_lnid->mac);
+			snprintf(str[i], sizeof(str[i]), "MAC=%pM",
+				addr_lnid->mac);
 			env[i] = str[i]; i++;
 		}
 		snprintf(str[i], sizeof(str[i]), "NTOK_BUSID=%x.%x.%04x",
-- 
2.3.8
