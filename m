From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.5.72] Eliminate bogus function in Red Creek VPN
Date: Tue, 17 Jun 2003 16:32:28 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030617163228.34d3daa4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The following function is defined but never used.

diff -Nru a/drivers/net/rcpci45.c b/drivers/net/rcpci45.c
--- a/drivers/net/rcpci45.c	Tue Jun 17 15:25:28 2003
+++ b/drivers/net/rcpci45.c	Tue Jun 17 15:25:28 2003
@@ -537,17 +537,6 @@
 			(PFNCALLBACK) RCreset_callback);
 }
 
-int
-broadcast_packet (unsigned char *address)
-{
-	int i;
-	for (i = 0; i < 6; i++)
-		if (address[i] != 0xff)
-			return 0;
-
-	return 1;
-}
-
 /*
  * RCrecv_callback()
  * 
