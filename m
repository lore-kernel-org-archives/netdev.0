From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/3] qeth: remove extraneous length from %pM format
Date: Wed, 19 Aug 2015 10:20:52 +0200
Message-ID: <1439972454-64347-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>,
	Ursula Braun <ursula.braun@de.ibmn.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:45575 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139AbbHSIVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 04:21:08 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 19 Aug 2015 09:21:06 +0100
In-Reply-To: <1439972454-64347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

Length specifier in the %pM format is not supported (at least, not
documented). Remove it, and also an extraneous '&' for the array.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibmn.com>
Suggested-by: Joe Perches <joe@perches.com>
---
 drivers/s390/net/qeth_l2_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 2e65b98..e0f0188 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1455,8 +1455,8 @@ static void qeth_bridge_emit_host_event(struct qeth_card *card,
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
