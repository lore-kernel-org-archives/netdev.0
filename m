From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] phonet: remove the unused variable pn
Date: Wed, 20 Oct 2010 15:51:03 +0800
Message-ID: <1287561063-24548-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:49437 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab0JTHv0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Oct 2010 03:51:26 -0400
Received: by qyk9 with SMTP id 9so1289086qyk.19
        for <netdev@vger.kernel.org>; Wed, 20 Oct 2010 00:51:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/phonet/pep.c |    1 -
 1 file changed, 1 deletion(-)
diff --git a/net/phonet/pep.c b/net/phonet/pep.c
index 9c903f9..3e60f2e 100644
--- a/net/phonet/pep.c
+++ b/net/phonet/pep.c
@@ -300,7 +300,6 @@ static int pipe_handler_send_ind(struct sock *sk, u8 utid, u8 msg_id)
 
 static int pipe_handler_enable_pipe(struct sock *sk, int enable)
 {
-	struct pep_sock *pn = pep_sk(sk);
 	int utid, req;
 
 	if (enable) {
