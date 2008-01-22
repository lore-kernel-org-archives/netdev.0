From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [IPV4 5/9] fib_trie: dump message multiple part flag
Date: Tue, 22 Jan 2008 15:37:38 -0800
Message-ID: <20080122233926.991793509@linux-foundation.org>
References: <20080122233733.404145234@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:33103 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757294AbYAWAJw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2008 19:09:52 -0500
Content-Disposition: inline; filename=fib-multi.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Match fib_hash, and set NLM_F_MULTI to handle multiple part messages.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/ipv4/fib_trie.c	2008-01-21 17:52:10.000000000 -0800
+++ b/net/ipv4/fib_trie.c	2008-01-21 17:52:11.000000000 -0800
@@ -1895,7 +1895,7 @@ static int fn_trie_dump_fa(t_key key, in
 				  xkey,
 				  plen,
 				  fa->fa_tos,
-				  fa->fa_info, 0) < 0) {
+				  fa->fa_info, NLM_F_MULTI) < 0) {
 			cb->args[4] = i;
 			return -1;
 		}

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

