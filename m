From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] fix compat_sock_common_getsockopt typo
Date: Tue, 06 Mar 2007 15:45:36 +0100
Message-ID: <1173192336.5415.5.camel@johannes.berg>
References: <1173137211.15891.27.camel@johannes.berg>
	 <Line.LNX.4.64.0703060942180.22674@d.namei>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: James Morris <jmorris@namei.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:37684 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965133AbXCFOqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 09:46:10 -0500
In-Reply-To: <Line.LNX.4.64.0703060942180.22674@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a typo in compat_sock_common_getsockopt.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/core/sock.c	2007-03-06 15:44:15.618565674 +0100
+++ wireless-dev/net/core/sock.c	2007-03-06 15:44:25.948565674 +0100
@@ -1597,7 +1597,7 @@ int compat_sock_common_getsockopt(struct
 {
 	struct sock *sk = sock->sk;
 
-	if (sk->sk_prot->compat_setsockopt != NULL)
+	if (sk->sk_prot->compat_getsockopt != NULL)
 		return sk->sk_prot->compat_getsockopt(sk, level, optname,
 						      optval, optlen);
 	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);


