From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH] rxrpc: remove unused static variables
Date: Fri, 21 Oct 2016 10:59:39 +0200
Message-ID: <20161021085939.1655-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        tglx@linutronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Galois.linutronix.de ([146.0.238.70]:51072 "EHLO
        Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932403AbcJUI7w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 04:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rxrpc_security_methods and rxrpc_security_sem user has been removed
in 648af7fca159 ("rxrpc: Absorb the rxkad security module"). This was
noticed by kbuild test robot for the -RT tree but is also true for !RT.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 net/rxrpc/security.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 814d285ff802..d4d088e9be85 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -19,9 +19,6 @@
 #include <keys/rxrpc-type.h>
 #include "ar-internal.h"
=20
-static LIST_HEAD(rxrpc_security_methods);
-static DECLARE_RWSEM(rxrpc_security_sem);
-
 static const struct rxrpc_security *rxrpc_security_types[] =3D {
 	[RXRPC_SECURITY_NONE]	=3D &rxrpc_no_security,
 #ifdef CONFIG_RXKAD
--=20
2.9.3
