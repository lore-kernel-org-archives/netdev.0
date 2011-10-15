From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: [PATCH net-next] net: ipv6: inet6_connection_sock.h needs flowi
Date: Sat, 15 Oct 2011 12:34:24 +0300
Message-ID: <1318671264-19684-1-git-send-email-christoph.paasch@uclouvain.be>
Cc: netdev@vger.kernel.org,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:43429 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751784Ab1JOJe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Oct 2011 05:34:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Otherwise we have a compiler-warning in c-files not including net/flow.h
before inet6_connection_sock.h .

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
---
 include/net/inet6_connection_sock.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index 3207e58..2a86a84 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -21,6 +21,7 @@ struct request_sock;
 struct sk_buff;
 struct sock;
 struct sockaddr;
+struct flowi;
 
 extern int inet6_csk_bind_conflict(const struct sock *sk,
 				   const struct inet_bind_bucket *tb);
-- 
1.7.5.4
