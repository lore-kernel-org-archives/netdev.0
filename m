From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.13-rc1 16/17] bonding: version, date and log update
Date: Fri, 1 Jul 2005 14:10:17 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0507011409060.17459@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch updates the bonding version number and adds a few entries to
the change log in bond_main. The major version number is changed to 3
because of the sysfs interface.

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bonding.h linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h
--- linux-2.6.12post/drivers/net/bonding/bonding.h	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bonding.h	2005-06-30 13:58:27.000000000 -0700
@@ -29,6 +29,10 @@
   * 2005/05/05 - Jason Gabler <jygabler at lbl dot gov>
   *      - added "xmit_policy" kernel parameter for alternate hashing policy
   *	  support for mode 2
+ *
+ * 2005/06/21 - Mitch Williams <mitch.a.williams at intel dot com>
+ *		Radheka Godse <radheka.godse at intel dot com>
+ *      - Added bonding sysfs interface
   */

  #ifndef _LINUX_BONDING_H
@@ -41,8 +37,8 @@
  #include "bond_3ad.h"
  #include "bond_alb.h"

-#define DRV_VERSION	"2.6.3"
-#define DRV_RELDATE	"June 8, 2005"
+#define DRV_VERSION	"3.0.0"
+#define DRV_RELDATE	"June 28, 2005"
  #define DRV_NAME	"bonding"
  #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"

diff -urN -X dontdiff linux-2.6.12post/drivers/net/bonding/bond_main.c linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c
--- linux-2.6.12post/drivers/net/bonding/bond_main.c	2005-06-28 18:18:03.000000000 -0700
+++ linux-2.6.12post-sysfs/drivers/net/bonding/bond_main.c	2005-06-30 13:53:55.000000000 -0700
@@ -487,7 +487,36 @@
   *	  * Added xmit_hash_policy_layer34()
   *	- Modified by Jay Vosburgh <fubar@us.ibm.com> to also support mode 4.
   *	  Set version to 2.6.3.
- */
+ * 2005/06/24 - Mitch Williams <mitch.a.williams at intel dot com>
+ *	- Radheka Godse <radheka.godse at intel dot com>
+ *	- Added bonding sysfs interface
+ * 
+ *	- pre-work:
+ *	- Split out bond creation code to allow for future addition of
+ *	  sysfs interface.
+ *	- Added extra optional parameter to bond_enslave to return a
+ *	  a pointer to the new slave.  This will be used by future
+ *	  sysfs functionality.
+ *	- Removed static declaration on some functions and data items.
+ * 
+ *	- Added sysfs support, including capability to add/remove/change
+ *	   any bond at runtime.
+ *
+ *	- Miscellaneous:
+ *	- Added bonding: <bondname>: prefix to sysfs log messages
+ *	- added arp_ip_targets to /proc entry
+ *	- trivial fix: added missing modes description to modinfo
+ *	- Corrected bug in ALB init where kmalloc is called inside
+ *	  a held lock
+ *	- Corrected behavior to maintain bond link when changing
+ *	  from arp monitor to miimon and vice versa 
+ *	- Added missing bonding: <bondname>: prefix to alb, ad log messages 
+ *	- Fixed stack dump warnings seen if changing between miimon 
+ *	  and arp monitoring when the bond interface is down.
+ *	- Fixed stack dump warnings seen when enslaving an e100 
+ *	  driver
+ *	  Set version to 3.0.0
+*/

  //#define BONDING_DEBUG 1
