From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: remove a stale comment for dl_next
Date: Fri, 19 Apr 2013 14:29:25 -0700
Message-ID: <1366406965.16391.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:47479 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932576Ab3DSV32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 17:29:28 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb10so2476112pad.39
        for <netdev@vger.kernel.org>; Fri, 19 Apr 2013 14:29:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

dl_next member in struct request_sock doesn't need to be first.

We expect to insert a "struct common_sock" or a subset of it,
so this claim had to be verified.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/request_sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index 9069e65..59795e4 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -48,7 +48,7 @@ extern int inet_rtx_syn_ack(struct sock *parent, struct request_sock *req);
 /* struct request_sock - mini sock to represent a connection request
  */
 struct request_sock {
-	struct request_sock		*dl_next; /* Must be first member! */
+	struct request_sock		*dl_next;
 	u16				mss;
 	u8				num_retrans; /* number of retransmits */
 	u8				cookie_ts:1; /* syncookie: encode tcpopts in timestamp */
