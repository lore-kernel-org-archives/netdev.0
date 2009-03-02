From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH net-next 2/5] sctp: remove dup code in net/sctp/socket.c
Date: Mon,  2 Mar 2009 14:46:11 -0500
Message-ID: <1236023174-18314-3-git-send-email-vladislav.yasevich@hp.com>
References: <>
 <1236023174-18314-1-git-send-email-vladislav.yasevich@hp.com>
 <1236023174-18314-2-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:16198 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754058AbZCBTqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 14:46:22 -0500
In-Reply-To: <1236023174-18314-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>

Remove dup check of "if (optlen < sizeof(int))".

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/socket.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index dea864f..4bc558c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3069,9 +3069,6 @@ static int sctp_setsockopt_maxburst(struct sock *sk,
 	int val;
 	int assoc_id = 0;
 
-	if (optlen < sizeof(int))
-		return -EINVAL;
-
 	if (optlen == sizeof(int)) {
 		printk(KERN_WARNING
 		   "SCTP: Use of int in max_burst socket option deprecated\n");
@@ -5283,9 +5280,6 @@ static int sctp_getsockopt_maxburst(struct sock *sk, int len,
 	struct sctp_sock *sp;
 	struct sctp_association *asoc;
 
-	if (len < sizeof(int))
-		return -EINVAL;
-
 	if (len == sizeof(int)) {
 		printk(KERN_WARNING
 		   "SCTP: Use of int in max_burst socket option deprecated\n");
-- 
1.5.4.3

