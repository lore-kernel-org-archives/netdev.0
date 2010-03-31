From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: [PATCH] sctp: eliminate useless code
Date: Wed, 31 Mar 2010 02:24:57 +0200
Message-ID: <1269995097-11206-1-git-send-email-hagen@jauu.net>
Cc: vladislav.yasevich@hp.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:60995 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757796Ab0CaAev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 20:34:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicate declaration of symbol: struct hlist_node *node was
already declared, the seconds declaration shadows the first one.

CC: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Hagen Paul Pfeifer <hagen@jauu.net>
---
 net/sctp/socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index dfc5c12..d80ee3a 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -5481,7 +5481,6 @@ pp_found:
 		 */
 		int reuse = sk->sk_reuse;
 		struct sock *sk2;
-		struct hlist_node *node;
 
 		SCTP_DEBUG_PRINTK("sctp_get_port() found a possible match\n");
 		if (pp->fastreuse && sk->sk_reuse &&
-- 
1.6.6.196.g1f735.dirty

