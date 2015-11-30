From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next] alx: remove pointless assignment
Date: Mon, 30 Nov 2015 17:33:36 -0500
Message-ID: <1448922816-13960-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59153 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752821AbbK3Wdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Nov 2015 17:33:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reasonably sure this doesn't serve any purpose.

CC: Jay Cliburn <jcliburn@gmail.com>
CC: Chris Snook <chris.snook@gmail.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index 4f07cbf..549a8ce 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -577,7 +577,6 @@ static int alx_alloc_rings(struct alx_priv *alx)
 
 	alx->int_mask &= ~ALX_ISR_ALL_QUEUES;
 	alx->int_mask |= ALX_ISR_TX_Q0 | ALX_ISR_RX_Q0;
-	alx->tx_ringsz = alx->tx_ringsz;
 
 	netif_napi_add(alx->dev, &alx->napi, alx_poll, 64);
 
-- 
1.8.3.1
