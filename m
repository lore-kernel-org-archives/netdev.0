From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] tcp: make tcp_clear_md5_list static
Date: Fri, 12 Oct 2012 13:22:06 -0700
Message-ID: <20121012132206.0f6bde61@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:54121 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab2JLUWv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2012 16:22:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only used in one file.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/tcp_ipv4.c	2012-10-12 13:08:19.497799654 -0700
+++ b/net/ipv4/tcp_ipv4.c	2012-10-12 13:11:20.616030173 -0700
@@ -1070,7 +1070,7 @@ int tcp_md5_do_del(struct sock *sk, cons
 }
 EXPORT_SYMBOL(tcp_md5_do_del);
 
-void tcp_clear_md5_list(struct sock *sk)
+static void tcp_clear_md5_list(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
