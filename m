From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [ PATCH ] 2.6 eepro100: replace and delete duplicate ids
Date: Tue, 01 Feb 2005 21:17:47 +0100
Message-ID: <41FFE3EB.5050603@wanadoo.es>
References: <3FBA97E4.1060004@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040809020605060701090308"
Cc: jgarzik@pobox.com
To: netdev@oss.sgi.com
In-Reply-To: <3FBA97E4.1060004@wanadoo.es>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040809020605060701090308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

hi,


- replace PCI_DEVICE_ID_INTEL_82557 and PCI_DEVICE_ID_INTEL_82559ER
   with theirs hex numbers
- PCI_DEVICE_ID_INTEL_82801BA_7 is a duplicate of 0x2449.

-thanks-



--------------040809020605060701090308
Content-Type: text/plain;
 name="eepro100_ids.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eepro100_ids.diff"

--- linux2/drivers/net/eepro100.c	2005-01-22 19:22:54.000000000 +0100
+++ n/drivers/net/eepro100.c	2005-02-01 21:10:15.000000000 +0100
@@ -2355,12 +2355,8 @@
 }
 
 static struct pci_device_id eepro100_pci_tbl[] = {
-	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82557,
-		PCI_ANY_ID, PCI_ANY_ID, },
-	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82559ER,
-		PCI_ANY_ID, PCI_ANY_ID, },
-	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801BA_7,
-		PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1229, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1209, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1029, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1030, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1031, PCI_ANY_ID, PCI_ANY_ID, },


--------------040809020605060701090308--
