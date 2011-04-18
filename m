From: David Miller <davem@davemloft.net>
Subject: [PATCH 33/42] irda: irlap_event: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:34:09 -0700 (PDT)
Message-ID: <20110417.173409.98891407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754072Ab1DRAeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6566624C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:34:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'ret' is set but unused in irlap_state_sclose().

Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/irda/irlap_event.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/irda/irlap_event.c b/net/irda/irlap_event.c
index bb47021..ccd214f 100644
--- a/net/irda/irlap_event.c
+++ b/net/irda/irlap_event.c
@@ -2227,8 +2227,6 @@ static int irlap_state_nrm_s(struct irlap_cb *self, IRLAP_EVENT event,
 static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 			      struct sk_buff *skb, struct irlap_info *info)
 {
-	int ret = 0;
-
 	IRDA_DEBUG(1, "%s()\n", __func__);
 
 	IRDA_ASSERT(self != NULL, return -ENODEV;);
@@ -2289,7 +2287,6 @@ static int irlap_state_sclose(struct irlap_cb *self, IRLAP_EVENT event,
 		IRDA_DEBUG(1, "%s(), Unknown event %d, (%s)\n", __func__,
 			   event, irlap_event[event]);
 
-		ret = -EINVAL;
 		break;
 	}
 
-- 
1.7.4.3

