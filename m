From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: inet_diag_handler structs can be const
Date: Mon, 17 Nov 2008 18:10:18 +0100
Message-ID: <4921A57A.4070505@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010900050204070903040800"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54500 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751773AbYKQRK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 12:10:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010900050204070903040800
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 net/dccp/diag.c     |    2 +-
 net/ipv4/tcp_diag.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

--------------010900050204070903040800
Content-Type: text/plain;
 name="const_inet_diag_handler.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="const_inet_diag_handler.patch"

diff --git a/net/dccp/diag.c b/net/dccp/diag.c
index d8a3509..d1e1003 100644
--- a/net/dccp/diag.c
+++ b/net/dccp/diag.c
@@ -45,7 +45,7 @@ static void dccp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		dccp_get_info(sk, _info);
 }
 
-static struct inet_diag_handler dccp_diag_handler = {
+static const struct inet_diag_handler dccp_diag_handler = {
 	.idiag_hashinfo	 = &dccp_hashinfo,
 	.idiag_get_info	 = dccp_diag_get_info,
 	.idiag_type	 = DCCPDIAG_GETSOCK,
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp_diag.c
index 838d491..fcbcd4f 100644
--- a/net/ipv4/tcp_diag.c
+++ b/net/ipv4/tcp_diag.c
@@ -34,7 +34,7 @@ static void tcp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
 		tcp_get_info(sk, info);
 }
 
-static struct inet_diag_handler tcp_diag_handler = {
+static const struct inet_diag_handler tcp_diag_handler = {
 	.idiag_hashinfo	 = &tcp_hashinfo,
 	.idiag_get_info	 = tcp_diag_get_info,
 	.idiag_type	 = TCPDIAG_GETSOCK,

--------------010900050204070903040800--
