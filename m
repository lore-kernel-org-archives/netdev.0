From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: [7/8] orinoco: Replace obsolete MODULE_PARM()
Date: Wed, 12 Jan 2005 16:28:48 +1100
Message-ID: <20050112052848.GH30426@localhost.localdomain>
References: <20050112052352.GA30426@localhost.localdomain> <20050112052434.GB30426@localhost.localdomain> <20050112052543.GC30426@localhost.localdomain> <20050112052630.GD30426@localhost.localdomain> <20050112052711.GE30426@localhost.localdomain> <20050112052741.GF30426@localhost.localdomain> <20050112052814.GG30426@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, orinoco-devel@lists.sourceforge.net,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050112052814.GG30426@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Replace obsolete MODULE_PARM() with module_param() in the orinoco
driver.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-01-12 15:47:48.215477920 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-01-12 15:50:14.156291544 +1100
@@ -461,12 +461,14 @@
 /* Level of debugging. Used in the macros in orinoco.h */
 #ifdef ORINOCO_DEBUG
 int orinoco_debug = ORINOCO_DEBUG;
-MODULE_PARM(orinoco_debug, "i");
+module_param(orinoco_debug, int, 0644);
+MODULE_PARM_DESC(orinoco_debug, "Debug level");
 EXPORT_SYMBOL(orinoco_debug);
 #endif
 
 static int suppress_linkstatus; /* = 0 */
-MODULE_PARM(suppress_linkstatus, "i");
+module_param(suppress_linkstatus, int, 0644);
+MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
 
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
