From: "Satoru SATOH" <satoru.satoh@gmail.com>
Subject: [PATCH] Trivial fix to correct function name in a comment in net/ipv4/tcp.c
Date: Mon, 21 Apr 2008 18:23:30 +0900
Message-ID: <d72b7ace0804210223w68bda930g9506f417c41aadc1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.236]:14663 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751593AbYDUJXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 05:23:32 -0400
Received: by wr-out-0506.google.com with SMTP id c48so712883wra.1
        for <netdev@vger.kernel.org>; Mon, 21 Apr 2008 02:23:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a trivial fix to correct function name in a comment in net/ipv4/tcp.c.


Signed-off-by: Satoru SATOH <satoru.satoh@gmail.com>

 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 58ac838..f886531 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1722,7 +1722,7 @@ static int tcp_close_state(struct sock *sk)

 /*
  *     Shutdown the sending side of a connection. Much like close except
- *     that we don't receive shut down or set_sock_flag(sk, SOCK_DEAD).
+ *     that we don't receive shut down or sock_set_flag(sk, SOCK_DEAD).
  */

 void tcp_shutdown(struct sock *sk, int how)
