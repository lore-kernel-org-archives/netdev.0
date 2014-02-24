From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 08/13] flowcache: Bring net/core/flow.c under IPsec maintain scope
Date: Mon, 24 Feb 2014 10:59:56 +0100
Message-ID: <1393236001-2445-9-git-send-email-steffen.klassert@secunet.com>
References: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39110 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbaBXKAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Feb 2014 05:00:12 -0500
In-Reply-To: <1393236001-2445-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fan.du@windriver.com>

As flow cache is mainly manipulated from IPsec.

Signed-off-by: Fan Du <fan.du@windriver.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 MAINTAINERS |    1 +
 1 file changed, 1 insertion(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index 091b50e..f6bc618 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5992,6 +5992,7 @@ L:	netdev@vger.kernel.org
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git
 S:	Maintained
+F:	net/core/flow.c
 F:	net/xfrm/
 F:	net/key/
 F:	net/ipv4/xfrm*
-- 
1.7.9.5
