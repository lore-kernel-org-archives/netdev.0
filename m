From: Art Haas <ahaas@neosoft.com>
Subject: [PATCH] C99 designated initializer for net/atm/lec.c
Date: Mon, 7 Oct 2002 17:41:10 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021007224110.GM9856@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@transmeta.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, carnil@cs.tut.fi
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi.

Here's a trivial patch for net/atm/lec.c to switch it to use C99
designated initializers. The patch is against 2.5.41.

Art Haas

--- linux-2.5.41/net/atm/lec.c.old	2002-07-05 18:42:03.000000000 -0500
+++ linux-2.5.41/net/atm/lec.c	2002-10-07 15:52:02.000000000 -0500
@@ -553,8 +553,8 @@
 }
 
 static struct atmdev_ops lecdev_ops = {
-        close:	lec_atm_close,
-        send:	lec_atm_send
+        .close	= lec_atm_close,
+        .send	= lec_atm_send
 };
 
 static struct atm_dev lecatm_dev = {
-- 
They that can give up essential liberty to obtain a little temporary safety
deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
