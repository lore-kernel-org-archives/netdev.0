From: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>
Subject: [PATCH net-next] Removed unused inet6 address state
Date: Thu, 2 Oct 2014 21:15:22 +0200
Message-ID: <1412277322-27823-1-git-send-email-sebastien.barre@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?S=C3=A9bastien=20Barr=C3=A9?=
	<sebastien.barre@uclouvain.be>, <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:56422 "EHLO
	smtp6.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751494AbaJBTPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2014 15:15:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the inet6 state INET6_IFADDR_STATE_UP only appeared in its definition.

Cc: Christoph Paasch <christoph.paasch@uclouvain.be>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: S=C3=A9bastien Barr=C3=A9 <sebastien.barre@uclouvain.be>

---
 include/net/if_inet6.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index d07b1a6..55a8d40 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -35,7 +35,6 @@ enum {
 	INET6_IFADDR_STATE_DAD,
 	INET6_IFADDR_STATE_POSTDAD,
 	INET6_IFADDR_STATE_ERRDAD,
-	INET6_IFADDR_STATE_UP,
 	INET6_IFADDR_STATE_DEAD,
 };
=20
--=20
tg: (739e4a7..) net-next/remove_unused_inet6_state (depends on: net-nex=
t/master)
