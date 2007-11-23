From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPv6] Correct the comment concerning inetsw6 table
Date: Fri, 23 Nov 2007 11:57:54 +0300
Message-ID: <47469612.2020900@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:59597 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbXKWI6i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 03:58:38 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It seems that net/ipv6/af_inet6.c was copied from net/ipv4/af_inet.c,
but one comment was not fixed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 85178f7..64135e2 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -68,7 +68,7 @@ MODULE_LICENSE("GPL");
 
 int sysctl_ipv6_bindv6only __read_mostly;
 
-/* The inetsw table contains everything that inet_create needs to
+/* The inetsw6 table contains everything that inet6_create needs to
  * build a new socket.
  */
 static struct list_head inetsw6[SOCK_MAX];
