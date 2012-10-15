From: David Miller <davem@davemloft.net>
Subject: IPSEC maintainership...
Date: Mon, 15 Oct 2012 13:38:33 -0400 (EDT)
Message-ID: <20121015.133833.2211899390966002142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751603Ab2JORih (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 13:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Steffen, after some discussions with Herbert we'd like to formally
recognize your outstanding contributions to the IPSEC stack over
the past few years by listing you explicitly as a maintainer as
per the patch below.

Let us know if you are OK with this.

Thanks!

--------------------
MAINTAINERS: Add explicit section for IPSEC networking.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/MAINTAINERS b/MAINTAINERS
index e73060f..6d6632f 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5019,6 +5019,20 @@ F:	net/ipv6/
 F:	include/net/ip*
 F:	arch/x86/net/*
 
+NETWORKING [IPSEC]
+M:	Steffen Klassert <steffen.klassert@secunet.com>
+M:	Herbert Xu <herbert@gondor.apana.org.au>
+M:	"David S. Miller" <davem@davemloft.net>
+L:	netdev@vger.kernel.org
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+S:	Maintained
+F:	net/xfrm/
+F:	net/key/
+F:	net/ipv4/xfrm*
+F:	net/ipv6/xfrm*
+F:	include/uapi/linux/xfrm.h
+F:	include/net/xfrm.h
+
 NETWORKING [LABELED] (NetLabel, CIPSO, Labeled IPsec, SECMARK)
 M:	Paul Moore <paul@paul-moore.com>
 L:	netdev@vger.kernel.org
