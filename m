From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 02/08] ipg: use NULL, not zero, for pointers
Date: Mon, 23 Jun 2008 14:34:50 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806231434300.23716@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sorbica@icplus.com.tw, jesse@icplus.com.tw, Bircoph@list.ru,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:41699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752397AbYFWLev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 07:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka Enberg <penberg@cs.helsinki.fi>

Fixes a sparse warning in a code block that's hidden under JUMBO_FRAME #ifdef.

Tested-by: Andrew Savchenko <Bircoph@list.ru>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -1808,7 +1808,7 @@ static int ipg_nic_open(struct net_devic
 	/* initialize JUMBO Frame control variable */
 	sp->jumbo.found_start = 0;
 	sp->jumbo.current_size = 0;
-	sp->jumbo.skb = 0;
+	sp->jumbo.skb = NULL;
 	dev->mtu = IPG_TXFRAG_SIZE;
 #endif
 
