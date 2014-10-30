From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: [PATCH net-next] tcp: Correction to RFC number in comment
Date: Thu, 30 Oct 2014 12:48:08 -0400
Message-ID: <20141030164808.GH650@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:40493 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758431AbaJ3QsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 12:48:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Challenge ACK is described in RFC 5961, fix typo.

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455..d285962 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5028,7 +5028,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 	/* step 3: check security and precedence [ignored] */
 
 	/* step 4: Check for a SYN
-	 * RFC 5691 4.2 : Send a challenge ack
+	 * RFC 5961 4.2 : Send a challenge ack
 	 */
 	if (th->syn) {
 syn_challenge:
-- 
1.8.4.2
