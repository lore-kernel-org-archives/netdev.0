From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 5/6] Allow 1000/Full setting for Autoneg param
Date: Mon, 2 Feb 2004 14:02:06 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021357230.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Allow 1000/Full setting for AutoNeg param for Fiber connections.
  Jon D Mason [jonmason@us.ibm.com].

------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_param.c netdev-2.6/drivers/net/e1000.mod/e1000_param.c
--- netdev-2.6/drivers/net/e1000/e1000_param.c	2004-02-02 12:10:53.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_param.c	2004-02-02 12:11:26.000000000 -0800
@@ -489,9 +489,9 @@ e1000_check_fiber_options(struct e1000_a
 		printk(KERN_INFO "Duplex not valid for fiber adapters, "
 		       "parameter ignored\n");
 	}
-	if((AutoNeg[bd] != OPTION_UNSET)) {
-		printk(KERN_INFO "AutoNeg not valid for fiber adapters, "
-		       "parameter ignored\n");
+	if((AutoNeg[bd] != OPTION_UNSET) && (AutoNeg[bd] != 0x20)) {
+		printk(KERN_INFO "AutoNeg other than Full/1000 is "
+		       "not valid for fiber adapters, parameter ignored\n");
 	}
 }
 
