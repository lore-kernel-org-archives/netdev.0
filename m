From: Paul Gortmaker <penguin@muskoka.com>
Subject: [PATCH 2.6.10]  smc-ultra.c verbose driver
Date: Sun, 09 Jan 2005 20:39:00 -0500
Message-ID: <41E1DCB4.1090902@muskoka.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090906020400050704050108"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090906020400050704050108
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

In keeping with the idea of a quiet boot time with less dmesg clutter,
the smc-ultra driver should not be printing about the absence of PnP
cards every time it goes probing -- e.g. if you have a non-PnP card
installed, you get the message twice...

Signed-off-by: Paul Gortmaker <p_gortmaker@yahoo.com>



--------------090906020400050704050108
Content-Type: text/plain;
 name="2.6.10-smc-ultra_diff0"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2.6.10-smc-ultra_diff0"

--- linux-200/drivers/net/smc-ultra.c~	Sat Aug 14 01:38:37 2004
+++ linux-200/drivers/net/smc-ultra.c	Sun Jan  9 20:33:06 2005
@@ -156,8 +156,6 @@
 	/* Look for any installed ISAPnP cards */
 	if (isapnp_present() && (ultra_probe_isapnp(dev) == 0))
 		return 0;
-
-	printk(KERN_NOTICE "smc-ultra.c: No ISAPnP cards found, trying standard ones...\n");
 #endif
 
 	for (i = 0; ultra_portlist[i]; i++) {

--------------090906020400050704050108--
