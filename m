From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] sdla non-module build fix.
Date: Mon, 8 Sep 2003 09:57:08 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030908095708.107b98c4.shemminger@osdl.org>
References: <Pine.LNX.4.44.0309071117290.21192-200000@home.osdl.org>
	<3F5B7ED7.2070908@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F5B7ED7.2070908@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Last round of changes broke sdla build if not a module.

diff -Nru a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
--- a/drivers/net/wan/sdla.c	Mon Sep  8 09:49:56 2003
+++ b/drivers/net/wan/sdla.c	Mon Sep  8 09:49:56 2003
@@ -1719,9 +1719,9 @@
 	
 	unregister_frad(devname);
 }
-#endif
 
 MODULE_LICENSE("GPL");
 
 module_init(init_sdla);
 module_exit(exit_sdla);
+#endif
