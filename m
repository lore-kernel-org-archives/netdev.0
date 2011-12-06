From: Rick Jones <rick.jones2@hp.com>
Subject: [PATCH net-next] remove an outdated reference to T/TCP
Date: Tue,  6 Dec 2011 12:00:05 -0800 (PST)
Message-ID: <20111206200005.836D529006DD@tardy>
Reply-To: Rick Jones <rick.jones2@hp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:36041 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752946Ab1LFUAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 15:00:07 -0500
Received: from g1t0038.austin.hp.com (g1t0038.austin.hp.com [16.236.32.44])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 2C28B38354
	for <netdev@vger.kernel.org>; Tue,  6 Dec 2011 20:00:06 +0000 (UTC)
Received: from tardy (tardy.cup.hp.com [16.89.64.213])
	by g1t0038.austin.hp.com (Postfix) with ESMTP id ED5303005A
	for <netdev@vger.kernel.org>; Tue,  6 Dec 2011 20:00:05 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove a particularly out of date bit of comment referring to T/TCP.

Signed-off-by: Rick Jones <rick.jones2@hp.com>

---


diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 0cbb440..123e1be 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5824,14 +5824,6 @@ int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 			 * we just ignore it, that fits the spec precisely
 			 * and avoids incompatibilities. It would be nice in
 			 * future to drop through and process the data.
-			 *
-			 * Now that TTCP is starting to be used we ought to
-			 * queue this data.
-			 * But, this leaves one open to an easy denial of
-			 * service attack, and SYN cookies can't defend
-			 * against this problem. So, we drop the data
-			 * in the interest of security over speed unless
-			 * it's still in use.
 			 */
 			kfree_skb(skb);
 			return 0;
