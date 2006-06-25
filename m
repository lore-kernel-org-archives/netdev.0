From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] make net/core/dev.c:netdev_nit static
Date: Mon, 26 Jun 2006 01:13:27 +0200
Message-ID: <20060625231327.GL23314@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:16915 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S932443AbWFYXN2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jun 2006 19:13:28 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev_nit can now become static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 include/linux/netdevice.h |    1 -
 net/core/dev.c            |    2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

--- linux-2.6.17-mm2-full/include/linux/netdevice.h.old	2006-06-25 23:30:55.000000000 +0200
+++ linux-2.6.17-mm2-full/include/linux/netdevice.h	2006-06-25 23:31:02.000000000 +0200
@@ -699,7 +699,6 @@
 
 extern void		dev_init(void);
 
-extern int		netdev_nit;
 extern int		netdev_budget;
 
 /* Called by rtnetlink.c:rtnl_unlock() */
--- linux-2.6.17-mm2-full/net/core/dev.c.old	2006-06-25 23:31:08.000000000 +0200
+++ linux-2.6.17-mm2-full/net/core/dev.c	2006-06-25 23:31:19.000000000 +0200
@@ -230,7 +230,7 @@
  *	For efficiency
  */
 
-int netdev_nit;
+static int netdev_nit;
 
 /*
  *	Add a protocol ID to the list. Now that the input handler is

