From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] phylib help text fixes
Date: Sun, 3 Dec 2006 10:55:46 -0800
Message-ID: <20061203105546.5ed1b71b.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jgarzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:47511 "EHLO
	agminet01.oracle.com") by vger.kernel.org with ESMTP
	id S1759987AbWLCSzK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:55:10 -0500
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix help text typos.
Fix help text width to be < 80 columns:  better for editors and for
  menuconfig in 80-column terms.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/net/phy/Kconfig |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

--- linux-2.6.19-rc6-mm2.orig/drivers/net/phy/Kconfig
+++ linux-2.6.19-rc6-mm2/drivers/net/phy/Kconfig
@@ -56,9 +56,10 @@ config BROADCOM_PHY
 config FIXED_PHY
 	tristate "Drivers for PHY emulation on fixed speed/link"
 	---help---
-	  Adds the driver to PHY layer to cover the boards that do not have any PHY bound,
-	  but with the ability to manipulate with speed/link in software. The relavant MII
-	  speed/duplex parameters could be effectively handled in user-specified  fuction.
+	  Adds the driver to PHY layer to cover the boards that do not have
+	  any PHY bound, but with the ability to manipulate the speed/link
+	  in software. The relevant MII speed/duplex parameters could be
+	  effectively handled in user-specified functions.
 	  Currently tested with mpc866ads.
 
 config FIXED_MII_10_FDX


---
