From: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>
Subject: [7/14] Orinoco driver updates - use modern module_parm()
Date: Thu, 24 Feb 2005 15:00:24 +1100
Message-ID: <20050224040024.GI32001@localhost.localdomain>
References: <20050224035355.GA32001@localhost.localdomain> <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Content-Disposition: inline
In-Reply-To: <20050224035957.GH32001-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Add descrptions to module parameters in the orinoco driver, and also
add permissions to allow them to be exported in sysfs.

Signed-off-by: David Gibson <hermes-xT8FGy+AXnRB3Ne2BGzF6laj5H9X9Tb+@public.gmane.org>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-02-10 13:19:14.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-02-10 13:24:03.000000000 +1100
@@ -461,12 +461,14 @@
 /* Level of debugging. Used in the macros in orinoco.h */
 #ifdef ORINOCO_DEBUG
 int orinoco_debug = ORINOCO_DEBUG;
-module_param(orinoco_debug, int, 0);
+module_param(orinoco_debug, int, 0644);
+MODULE_PARM_DESC(orinoco_debug, "Debug level");
 EXPORT_SYMBOL(orinoco_debug);
 #endif
 
 static int suppress_linkstatus; /* = 0 */
-module_param(suppress_linkstatus, bool, 0);
+module_param(suppress_linkstatus, bool, 0644);
+MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
 
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
