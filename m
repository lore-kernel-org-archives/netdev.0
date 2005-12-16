From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Subject: [PATCH 2/2] orinoco_nortel: Add Symbol LA-4123 ID
Date: Fri, 16 Dec 2005 18:57:10 -0500
Message-ID: <1134777430.2228.15.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tomas Novak <tap-SgvXgqTD8kc@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: NetDev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	orinoco-devel <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
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

Add ID for Symbol LA-4123.  Reported by Tomas Novak <tap-SgvXgqTD8kc@public.gmane.org>

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

---
I mentioned LA-4113 so that potential users can find this driver and
tell me the ID.  This patch has a great user_impact/code_impact ratio,
should be OK for 2.6.15 or 2.6.15.x.

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
index d8afd51..d1a670b 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -1,6 +1,8 @@
 /* orinoco_nortel.c
  * 
  * Driver for Prism II devices which would usually be driven by orinoco_cs,
+ * but are connected to the PCI bus by a PCI-to-PCMCIA adapter used in
+ * Nortel emobility, Symbol LA-4113 and Symbol LA-4123.
  * but are connected to the PCI bus by a Nortel PCI-PCMCIA-Adapter. 
  *
  * Copyright (C) 2002 Tobias Hoffmann
@@ -265,6 +267,8 @@ static void __devexit nortel_pci_remove_
 static struct pci_device_id nortel_pci_id_table[] = {
 	/* Nortel emobility PCI */
 	{0x126c, 0x8030, PCI_ANY_ID, PCI_ANY_ID,},
+	/* Symbol LA-4123 PCI */
+	{0x1562, 0x0001, PCI_ANY_ID, PCI_ANY_ID,},
 	{0,},
 };
 

-- 
Regards,
Pavel Roskin



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
