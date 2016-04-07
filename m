From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] net: intel: remove dead links
Date: Wed,  6 Apr 2016 21:37:32 -0700
Message-ID: <1460003853-133949-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5553 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752420AbcDGEhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:37 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>

The Kconfig for Intel NICs references two different URLs for the "Adapter
& Driver ID Guide". Neither of those two links works. The current URL seems
to be
http://www.intel.com/content/www/us/en/support/network-and-i-o/ethernet-products/000005584.html
but given it's apparently constantly changing, there's no point in having it
in the help text.

Just keep a generic pointer to http://support.intel.com. Hopefully, this one
will have a longer live. It still works, at least.

Furthermore, remove a link to "the latest Intel PRO/100 network driver for
Linux", this has no place in the mainline kernel and the latest Linux driver
it offers is from 2006, anyway.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 80 +++++++-------------------------------
 1 file changed, 14 insertions(+), 66 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index 3772f3a..714bd10 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -25,16 +25,13 @@ config E100
 	  on the adapter. Look for a label that has a barcode and a number
 	  in the format 123456-001 (six digits hyphen three digits).
 
-	  Use the above information and the Adapter & Driver ID Guide at:
+	  Use the above information and the Adapter & Driver ID Guide that
+	  can be located at:
 
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
+	  <http://support.intel.com>
 
 	  to identify the adapter.
 
-	  For the latest Intel PRO/100 network driver for Linux, see:
-
-	  <http://www.intel.com/p/en_US/support/highlights/network/pro100plus>
-
 	  More specific information on configuring the driver is in
 	  <file:Documentation/networking/e100.txt>.
 
@@ -47,12 +44,7 @@ config E1000
 	---help---
 	  This driver supports Intel(R) PRO/1000 gigabit ethernet family of
 	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -71,12 +63,8 @@ config E1000E
 	  This driver supports the PCI-Express Intel(R) PRO/1000 gigabit
 	  ethernet family of adapters. For PCI or PCI-X e1000 adapters,
 	  use the regular e1000 driver For more information on how to
-	  identify your adapter, go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  identify your adapter, go to the Adapter & Driver ID Guide that
+	  can be located at:
 
 	  <http://support.intel.com>
 
@@ -101,12 +89,7 @@ config IGB
 	---help---
 	  This driver supports Intel(R) 82575/82576 gigabit ethernet family of
 	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -142,12 +125,7 @@ config IGBVF
 	---help---
 	  This driver supports Intel(R) 82576 virtual functions.  For more
 	  information on how to identify your adapter, go to the Adapter &
-	  Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -164,12 +142,7 @@ config IXGB
 	  This driver supports Intel(R) PRO/10GbE family of adapters for
 	  PCI-X type cards. For PCI-E type cards, use the "ixgbe" driver
 	  instead. For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -187,12 +160,7 @@ config IXGBE
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -243,12 +211,7 @@ config IXGBEVF
 	---help---
 	  This driver supports Intel(R) PCI Express virtual functions for the
 	  Intel(R) ixgbe driver.  For more information on how to identify your
-	  adapter, go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/sb/CS-008441.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  adapter, go to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -266,12 +229,7 @@ config I40E
 	---help---
 	  This driver supports Intel(R) Ethernet Controller XL710 Family of
 	  devices.  For more information on how to identify your adapter, go
-	  to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -326,12 +284,7 @@ config I40EVF
 	---help---
 	  This driver supports Intel(R) XL710 and X710 virtual functions.
 	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/sb/CS-008441.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
@@ -347,12 +300,7 @@ config FM10K
 	---help---
 	  This driver supports Intel(R) FM10000 Ethernet Switch Host
 	  Interface.  For more information on how to identify your adapter,
-	  go to the Adapter & Driver ID Guide at:
-
-	  <http://support.intel.com/support/network/sb/CS-008441.htm>
-
-	  For general information and support, go to the Intel support
-	  website at:
+	  go to the Adapter & Driver ID Guide that can be located at:
 
 	  <http://support.intel.com>
 
-- 
2.5.5
