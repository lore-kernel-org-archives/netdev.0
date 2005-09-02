From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 6/8] orinoco: Remove EXPERIMENTAL mark from PLX_HERMES,
 TMD_HERMES and PCI_HERMES.
Date: Thu, 01 Sep 2005 20:07:52 -0400
Message-ID: <1125619672.29016.7.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

diff-tree ceb6695092be8dcdfe2dec6ee5097d613011489d (from 6b39374a27eb4be7e9d82145ae270ba02ea90dc8)
Author: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Date:   Thu Sep 1 14:50:10 2005 -0400

    Remove EXPERIMENTAL mark from PLX_HERMES, TMD_HERMES and PCI_HERMES.
    
    Those drivers have been used for a long time, and there have been very
    few problem reports.

diff --git a/drivers/net/wireless/Kconfig b/drivers/net/wireless/Kconfig
--- a/drivers/net/wireless/Kconfig
+++ b/drivers/net/wireless/Kconfig
@@ -183,39 +183,33 @@ config APPLE_AIRPORT
 	  built into the Macintosh iBook and other recent PowerPC-based
 	  Macintosh machines. This is essentially a Lucent Orinoco card with 
 	  a non-standard interface
 
 config PLX_HERMES
-	tristate "Hermes in PLX9052 based PCI adaptor support (Netgear MA301 etc.) (EXPERIMENTAL)"
-	depends on PCI && HERMES && EXPERIMENTAL
+	tristate "Hermes in PLX9052 based PCI adaptor support (Netgear MA301 etc.)"
+	depends on PCI && HERMES
 	help
 	  Enable support for PCMCIA cards supported by the "Hermes" (aka
 	  orinoco) driver when used in PLX9052 based PCI adaptors.  These
 	  adaptors are not a full PCMCIA controller but act as a more limited
 	  PCI <-> PCMCIA bridge.  Several vendors sell such adaptors so that
 	  802.11b PCMCIA cards can be used in desktop machines.  The Netgear
 	  MA301 is such an adaptor.
 
-	  Support for these adaptors is so far still incomplete and buggy.
-	  You have been warned.
-
 config TMD_HERMES
-	tristate "Hermes in TMD7160 based PCI adaptor support (EXPERIMENTAL)"
-	depends on PCI && HERMES && EXPERIMENTAL
+	tristate "Hermes in TMD7160 based PCI adaptor support"
+	depends on PCI && HERMES
 	help
 	  Enable support for PCMCIA cards supported by the "Hermes" (aka
 	  orinoco) driver when used in TMD7160 based PCI adaptors.  These
 	  adaptors are not a full PCMCIA controller but act as a more limited
 	  PCI <-> PCMCIA bridge.  Several vendors sell such adaptors so that
 	  802.11b PCMCIA cards can be used in desktop machines.
 
-	  Support for these adaptors is so far still incomplete and buggy.
-	  You have been warned.
-
 config PCI_HERMES
-	tristate "Prism 2.5 PCI 802.11b adaptor support (EXPERIMENTAL)"
-	depends on PCI && HERMES && EXPERIMENTAL
+	tristate "Prism 2.5 PCI 802.11b adaptor support"
+	depends on PCI && HERMES
 	help
 	  Enable support for PCI and mini-PCI 802.11b wireless NICs based on
 	  the Prism 2.5 chipset.  These are true PCI cards, not the 802.11b
 	  PCMCIA cards bundled with PCI<->PCMCIA adaptors which are also
 	  common.  Some of the built-in wireless adaptors in laptops are of


-- 
Regards,
Pavel Roskin



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
