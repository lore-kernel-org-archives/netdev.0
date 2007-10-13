From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/5] [IPV6]: Add skb_is_gso_v6
Date: Sat, 13 Oct 2007 12:33:32 +0200
Message-ID: <47109EFC.3020601@myri.com>
References: <47109E8A.8080205@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1801 "EHLO myri.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753636AbXJMKfR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Oct 2007 06:35:17 -0400
In-Reply-To: <47109E8A.8080205@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add skb_is_gso_v6().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 include/linux/skbuff.h |    5 +++++
 1 file changed, 5 insertions(+)

Index: linux-git/include/linux/skbuff.h
===================================================================
--- linux-git.orig/include/linux/skbuff.h	2007-10-13 12:24:37.000000000 +0200
+++ linux-git/include/linux/skbuff.h	2007-10-13 12:25:04.000000000 +0200
@@ -1781,6 +1781,11 @@
 	return skb_shinfo(skb)->gso_size;
 }
 
+static inline int skb_is_gso_v6(const struct sk_buff *skb)
+{
+	return skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6;
+}
+
 static inline void skb_forward_csum(struct sk_buff *skb)
 {
 	/* Unfortunately we don't support this one.  Any brave souls? */


