From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] gre: protocol table can be static
Date: Sat, 2 Oct 2010 08:58:00 +0900
Message-ID: <20101002085800.4cd06561@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38913 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752172Ab0JAX6H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 19:58:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This table is only used in gre.c

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/ipv4/gre.c	2010-09-29 10:41:46.895895032 +0900
+++ b/net/ipv4/gre.c	2010-09-29 10:41:56.265898132 +0900
@@ -22,7 +22,7 @@
 #include <net/gre.h>
 
 
-const struct gre_protocol *gre_proto[GREPROTO_MAX] __read_mostly;
+static const struct gre_protocol *gre_proto[GREPROTO_MAX] __read_mostly;
 static DEFINE_SPINLOCK(gre_proto_lock);
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
[
