From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next] MAINTAINERS: Update the IPsec maintainer entry
Date: Fri, 13 Dec 2013 12:56:05 +0100
Message-ID: <20131213115605.GP31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49305 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752244Ab3LML4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Dec 2013 06:56:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the IPsec git trees and some pure IPsec modules
to the IPsec section in the MAINTAINERS file.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---

This is the IPsec maintainers update we discussed here:
http://marc.info/?l=linux-netdev&m=138393272032536&w=2

I've also added the ipsec trees to get the patches based
on these trees.

 MAINTAINERS |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 63ae896..568cea1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5895,12 +5895,21 @@ M:	Steffen Klassert <steffen.klassert@secunet.com>
 M:	Herbert Xu <herbert@gondor.apana.org.au>
 M:	"David S. Miller" <davem@davemloft.net>
 L:	netdev@vger.kernel.org
-T:	git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git
+T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git
 S:	Maintained
 F:	net/xfrm/
 F:	net/key/
 F:	net/ipv4/xfrm*
+F:	net/ipv4/esp4.c
+F:	net/ipv4/ah4.c
+F:	net/ipv4/ipcomp.c
+F:	net/ipv4/ip_vti.c
 F:	net/ipv6/xfrm*
+F:	net/ipv6/esp6.c
+F:	net/ipv6/ah6.c
+F:	net/ipv6/ipcomp6.c
+F:	net/ipv6/ip6_vti.c
 F:	include/uapi/linux/xfrm.h
 F:	include/net/xfrm.h
 
-- 
1.7.9.5
