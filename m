From: Dave Jones <davej@redhat.com>
Subject: remove unnecessary config.h includes from drivers/net/
Date: Thu, 10 Aug 2006 21:37:13 -0400
Message-ID: <20060811013713.GA17746@redhat.com>
References: <20060810022116.GB23634@redhat.com> <20060809.210438.110013064.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:12417 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750810AbWHKBoL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 21:44:11 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060809.210438.110013064.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 09:04:38PM -0700, David Miller wrote:
 > From: Dave Jones <davej@redhat.com>
 > Date: Wed, 9 Aug 2006 22:21:16 -0400
 > 
 > > config.h is automatically included by kbuild these days.
 > > 
 > > Signed-off-by: Dave Jones <davej@redhat.com>
 > 
 > Applied to net-2.6.19, thanks Dave.

Here's a similar patch that does the same removals for drivers/net/

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.17.noarch/drivers/net/irda/mcs7780.c~	2006-08-10 21:35:23.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/irda/mcs7780.c	2006-08-10 21:35:25.000000000 -0400
@@ -45,7 +45,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/errno.h>
--- linux-2.6.17.noarch/drivers/net/irda/w83977af_ir.c~	2006-08-10 21:35:28.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/irda/w83977af_ir.c	2006-08-10 21:35:30.000000000 -0400
@@ -40,7 +40,6 @@
  ********************************************************************/
 
 #include <linux/module.h>
-#include <linux/config.h> 
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/skbuff.h>
--- linux-2.6.17.noarch/drivers/net/smc911x.c~	2006-08-10 21:35:34.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/smc911x.c	2006-08-10 21:35:37.000000000 -0400
@@ -55,8 +55,6 @@ static const char version[] =
 			 )
 #endif
 
-
-#include <linux/config.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
--- linux-2.6.17.noarch/drivers/net/netx-eth.c~	2006-08-10 21:35:41.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/netx-eth.c	2006-08-10 21:35:42.000000000 -0400
@@ -17,7 +17,6 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-#include <linux/config.h>
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
--- linux-2.6.17.noarch/drivers/net/wan/cycx_main.c~	2006-08-10 21:35:45.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/wan/cycx_main.c	2006-08-10 21:35:48.000000000 -0400
@@ -40,7 +40,6 @@
 * 1998/08/08	acme		Initial version.
 */
 
-#include <linux/config.h>	/* OS configuration options */
 #include <linux/stddef.h>	/* offsetof(), etc. */
 #include <linux/errno.h>	/* return codes */
 #include <linux/string.h>	/* inline memset(), etc. */
--- linux-2.6.17.noarch/drivers/net/wan/sdla.c~	2006-08-10 21:35:51.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/wan/sdla.c	2006-08-10 21:35:53.000000000 -0400
@@ -32,7 +32,6 @@
  *		2 of the License, or (at your option) any later version.
  */
 
-#include <linux/config.h> /* for CONFIG_DLCI_MAX */
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
--- linux-2.6.17.noarch/drivers/net/wan/dlci.c~	2006-08-10 21:35:57.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/wan/dlci.c	2006-08-10 21:35:59.000000000 -0400
@@ -28,7 +28,6 @@
  *		2 of the License, or (at your option) any later version.
  */
 
-#include <linux/config.h> /* for CONFIG_DLCI_COUNT */
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
--- linux-2.6.17.noarch/drivers/net/phy/vitesse.c~	2006-08-10 21:36:02.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/phy/vitesse.c	2006-08-10 21:36:04.000000000 -0400
@@ -12,7 +12,6 @@
  *
  */
 
-#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mii.h>
--- linux-2.6.17.noarch/drivers/net/phy/smsc.c~	2006-08-10 21:36:07.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/phy/smsc.c	2006-08-10 21:36:08.000000000 -0400
@@ -14,7 +14,6 @@
  *
  */
 
-#include <linux/config.h>
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mii.h>
--- linux-2.6.17.noarch/drivers/net/hp100.c~	2006-08-10 21:36:12.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/hp100.c	2006-08-10 21:36:14.000000000 -0400
@@ -111,7 +111,6 @@
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <linux/types.h>
-#include <linux/config.h>	/* for CONFIG_PCI */
 #include <linux/delay.h>
 #include <linux/init.h>
 #include <linux/bitops.h>
--- linux-2.6.17.noarch/drivers/net/3c501.c~	2006-08-10 21:36:18.000000000 -0400
+++ linux-2.6.17.noarch/drivers/net/3c501.c	2006-08-10 21:36:20.000000000 -0400
@@ -120,7 +120,6 @@ static const char version[] =
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/errno.h>
-#include <linux/config.h>	/* for CONFIG_IP_MULTICAST */
 #include <linux/spinlock.h>
 #include <linux/ethtool.h>
 #include <linux/delay.h>

-- 
http://www.codemonkey.org.uk
