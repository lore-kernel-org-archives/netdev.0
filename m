From: Rohit Chavan <roheetchavan@gmail.com>
Subject: [PATCH 4750/4750] net: ipv4: tcp: fixed comment coding style issue
Date: Mon, 22 May 2017 11:59:15 +0530
Message-ID: <20170522062915.GA40825@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Rohit Chavan <roheetchavan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36331 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751641AbdEVG3j (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 02:29:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed a coding style issue

Signed-off-by: Rohit Chavan <roheetchavan@gmail.com>
---
 net/ipv4/tcp.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1e4c76d..87b0296 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2183,7 +2183,7 @@ void tcp_close(struct sock *sk, long timeout)
 
 
 	/* Now socket is owned by kernel and we acquire BH lock
-	   to finish close. No need to check for user refs.
+	 *  to finish close. No need to check for user refs.
 	 */
 	local_bh_disable();
 	bh_lock_sock(sk);
@@ -2471,7 +2471,8 @@ static int do_tcp_setsockopt(struct sock *sk, int level,
 	case TCP_MAXSEG:
 		/* Values greater than interface MTU won't take effect. However
 		 * at the point when this call is done we typically don't yet
-		 * know which interface is going to be used */
+		 * know which interface is going to be used
+		 */
 		if (val && (val < TCP_MIN_MSS || val > MAX_TCP_WINDOW)) {
 			err = -EINVAL;
 			break;
-- 
2.7.4
