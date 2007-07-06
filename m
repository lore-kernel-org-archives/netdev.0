From: "Robert P. J. Day" <rpjday@mindspring.com>
Subject: [PATCH] RPC: Remove Makefile reference to obsolete RXRPC config
 variable.
Date: Fri, 6 Jul 2007 05:22:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0707060519320.28491@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nic.NetDirect.CA ([216.16.235.2]:53875 "EHLO
	rubicon.netdirect.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210AbXGFJYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 05:24:45 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Since there is no Kconfig variable RXRPC anywhere in the tree, and the
variable AF_RXRPC performs exactly the same function, remove the
reference to CONFIG_RXRPC from net/Makefile.

Signed-off-by: Robert P. J. Day <rpjday@mindspring.com>

---

diff --git a/net/Makefile b/net/Makefile
index 34e5b2d..a87a889 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -37,7 +37,6 @@ obj-$(CONFIG_AX25)		+= ax25/
 obj-$(CONFIG_IRDA)		+= irda/
 obj-$(CONFIG_BT)		+= bluetooth/
 obj-$(CONFIG_SUNRPC)		+= sunrpc/
-obj-$(CONFIG_RXRPC)		+= rxrpc/
 obj-$(CONFIG_AF_RXRPC)		+= rxrpc/
 obj-$(CONFIG_ATM)		+= atm/
 obj-$(CONFIG_DECNET)		+= decnet/

-- 
========================================================================
Robert P. J. Day
Linux Consulting, Training and Annoying Kernel Pedantry
Waterloo, Ontario, CANADA

http://fsdev.net/wiki/index.php?title=Main_Page
========================================================================
