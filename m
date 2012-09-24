From: frank.blaschka@de.ibm.com
Subject: [patch 4/5] [PATCH] drivers/s390/net: removes unnecessary semicolon
Date: Mon, 24 Sep 2012 16:24:26 +0200
Message-ID: <20120924142501.344742310@de.ibm.com>
References: <20120924142422.001953152@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp13.uk.ibm.com ([195.75.94.109]:52029 "EHLO
	e06smtp13.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728Ab2IXOZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:25:09 -0400
Received: from /spool/local
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 24 Sep 2012 15:25:07 +0100
Content-Disposition: inline; filename=603-net-semicolon-cleanup.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

removes unnecessary semicolon

Found by Coccinelle: http://coccinelle.lip6.fr/

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/ctcm_fsms.c      | 2 +-
 drivers/s390/net/qeth_core_main.c | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/s390/net/ctcm_fsms.c b/drivers/s390/net/ctcm_fsms.c
index d4ade9e..fb92524 100644
--- a/drivers/s390/net/ctcm_fsms.c
+++ b/drivers/s390/net/ctcm_fsms.c
@@ -1523,7 +1523,7 @@ static void ctcmpc_chx_firstio(fsm_instance *fi, int event, void *arg)
 				goto done;
 	default:
 		break;
-	};
+	}
 
 	fsm_newstate(fi, (CHANNEL_DIRECTION(ch->flags) == CTCM_READ)
 		     ? CTC_STATE_RXINIT : CTC_STATE_TXINIT);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 3420abf..3e25d31 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -489,7 +489,7 @@ static struct qeth_reply *qeth_alloc_reply(struct qeth_card *card)
 		atomic_set(&reply->refcnt, 1);
 		atomic_set(&reply->received, 0);
 		reply->card = card;
-	};
+	}
 	return reply;
 }
 
@@ -2037,7 +2037,7 @@ int qeth_send_control_data(struct qeth_card *card, int len,
 			if (time_after(jiffies, timeout))
 				goto time_err;
 			cpu_relax();
-		};
+		}
 	}
 
 	if (reply->rc == -EIO)
-- 
1.7.11.7
