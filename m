From: Olaf Kirch <okir@suse.de>
Subject: [PATCH] eliminate divert_blk message
Date: Mon, 5 Apr 2004 17:03:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405150312.GS11477@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="hHWLQfXTYDoKhP50"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

Every time a non-ethernet device is configured (e.g.  when using PPP) the
kernel logs a message saying "not allocating divert_blk for non-ethernet
device". This patch disables the message.

Cheers,
Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 

--hHWLQfXTYDoKhP50
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: attachment; filename=divert_blk-shutup

--- linux-2.6.4/net/core/dv.c.quiet	2004-02-04 04:43:45.000000000 +0100
+++ linux-2.6.4/net/core/dv.c	2004-04-05 16:50:06.000000000 +0200
@@ -67,9 +67,6 @@
 		}
 		dev_hold(dev);
 	} else {
-		printk(KERN_DEBUG "divert: not allocating divert_blk for non-ethernet device %s\n",
-		       dev->name);
-
 		dev->divert = NULL;
 	}
 	return 0;

--hHWLQfXTYDoKhP50--
