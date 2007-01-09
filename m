From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH] INET: style updates for the inet_sock->is_icsk assignment fix
Date: Tue, 09 Jan 2007 12:51:30 -0500
Message-ID: <20070109175144.787024589@flek.zko.hp.com>
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:35006 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932281AbXAIRyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 12:54:14 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=network-cleanup_icsk_assignment
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A quick patch to change the inet_sock->is_icsk assignment to better fit with
existing kernel coding style.

Signed-off-by: Paul Moore <paul.moore@hp.com>
Cc: Jarek Poplawski <jarkao2@o2.pl>
Cc: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
---
 net/ipv4/af_inet.c  |    2 +-
 net/ipv6/af_inet6.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

Index: net-2.6.20_bugfix_2/net/ipv4/af_inet.c
===================================================================
--- net-2.6.20_bugfix_2.orig/net/ipv4/af_inet.c
+++ net-2.6.20_bugfix_2/net/ipv4/af_inet.c
@@ -305,7 +305,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
-	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) == INET_PROTOSW_ICSK;
+	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;
Index: net-2.6.20_bugfix_2/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.20_bugfix_2.orig/net/ipv6/af_inet6.c
+++ net-2.6.20_bugfix_2/net/ipv6/af_inet6.c
@@ -171,7 +171,7 @@ lookup_protocol:
 		sk->sk_reuse = 1;
 
 	inet = inet_sk(sk);
-	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) == INET_PROTOSW_ICSK;
+	inet->is_icsk = (INET_PROTOSW_ICSK & answer_flags) != 0;
 
 	if (SOCK_RAW == sock->type) {
 		inet->num = protocol;

--
paul moore
linux security @ hp

