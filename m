From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] udp: net-2.6.22 build fix
Date: Wed, 7 Mar 2007 13:47:43 -0800
Message-ID: <20070307134743.42e3b5c7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:60477 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965679AbXCGVrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 16:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Recent change broke build of UDP.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- net-2.6.22.orig/net/ipv4/udp.c	2007-03-07 13:43:59.000000000 -0800
+++ net-2.6.22/net/ipv4/udp.c	2007-03-07 13:45:43.000000000 -0800
@@ -1283,7 +1283,7 @@
 	 * the network is concerned, anyway) as per 4.1.3.4 (MUST).
 	 */
 	LIMIT_NETDEBUG(KERN_DEBUG "UDP%s: bad checksum. From %d.%d.%d.%d:%d to %d.%d.%d.%d:%d ulen %d\n",
-		       is_udplite? "-Lite" : "",
+		       proto == IPPROTO_UDPLITE ? "-Lite" : "",
 		       NIPQUAD(saddr),
 		       ntohs(uh->source),
 		       NIPQUAD(daddr),
