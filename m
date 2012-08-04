From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Subject: [PATCH] tcp_output: fix sparse warning for tcp_wfree
Date: Sat,  4 Aug 2012 22:31:29 +0300
Message-ID: <1344108689-17896-1-git-send-email-silviupopescu1990@gmail.com>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	linux-kernel@vger.kernel.org,
	Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:59700 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753901Ab2HDTbd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Aug 2012 15:31:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix sparse warning:
	* symbol 'tcp_wfree' was not declared. Should it be static?

Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
---
 net/ipv4/tcp_output.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3f1bcff..18475e0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -940,7 +940,7 @@ void __init tcp_tasklet_init(void)
  * We cant xmit new skbs from this context, as we might already
  * hold qdisc lock.
  */
-void tcp_wfree(struct sk_buff *skb)
+static void tcp_wfree(struct sk_buff *skb)
 {
 	struct sock *sk = skb->sk;
 	struct tcp_sock *tp = tcp_sk(sk);
-- 
1.7.9.5
