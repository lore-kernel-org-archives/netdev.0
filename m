From: akpm@linux-foundation.org
Subject: [patch 8/8] RPC: Remove Makefile reference to obsolete RXRPC config variable
Date: Mon, 09 Jul 2007 11:51:14 -0700
Message-ID: <200707091851.l69IpEIo001746@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	rpjday@mindspring.com, bfields@fieldses.org,
	trond.myklebust@fys.uio.no
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57655 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759910AbXGISwL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 14:52:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Robert P. J. Day" <rpjday@mindspring.com>

Since there is no Kconfig variable RXRPC anywhere in the tree, and the
variable AF_RXRPC performs exactly the same function, remove the reference
to CONFIG_RXRPC from net/Makefile.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/Makefile |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/Makefile~rpc-remove-makefile-reference-to-obsolete-rxrpc-config net/Makefile
--- a/net/Makefile~rpc-remove-makefile-reference-to-obsolete-rxrpc-config
+++ a/net/Makefile
@@ -37,7 +37,6 @@ obj-$(CONFIG_AX25)		+= ax25/
 obj-$(CONFIG_IRDA)		+= irda/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
-obj-$(CONFIG_RXRPC)		+= rxrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_DECNET)		+= decnet/
_
