From: Andrew Hendry <andrew.hendry@gmail.com>
Subject: [PATCH 1/2] X.25 remove bkl in getsockname
Date: Wed, 22 Sep 2010 11:24:25 +1000
Message-ID: <1285118665.28503.44.camel@jaunty>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:33015 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755547Ab0IVBYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 21:24:35 -0400
Received: by qwh6 with SMTP id 6so4818232qwh.19
        for <netdev@vger.kernel.org>; Tue, 21 Sep 2010 18:24:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Andrew Hendry <andrew.hendry@gmail.com>

---
 net/x25/af_x25.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index b371a47..a87f792 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -905,7 +905,6 @@ static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
 	struct x25_sock *x25 = x25_sk(sk);
 	int rc = 0;
 
-	lock_kernel();
 	if (peer) {
 		if (sk->sk_state != TCP_ESTABLISHED) {
 			rc = -ENOTCONN;
@@ -919,7 +918,6 @@ static int x25_getname(struct socket *sock, struct sockaddr *uaddr,
 	*uaddr_len = sizeof(*sx25);
 
 out:
-	unlock_kernel();
 	return rc;
 }
 
-- 
1.7.0.4



