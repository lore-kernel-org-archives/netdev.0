From: Johann Felix Soden <johfel@gmx.de>
Subject: [NET]: Remove further references to net-modules.txt
Date: Mon, 04 Feb 2008 08:31:40 +0100
Message-ID: <1202110300.28722.4.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:38154 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753341AbYBDHbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 02:31:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johann Felix Soden <johfel@users.sourceforge.net>

The Kconfig of igb and enc28j60 contains references to
obsolet Documentation/networking/net-modules.txt.

Signed-off-by: Johann Felix Soden <johfel@users.sourceforge.net>
---
 drivers/net/Kconfig |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 389980f..87f503b 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -919,8 +919,7 @@ config ENC28J60
 	---help---
 	  Support for the Microchip EN28J60 ethernet chip.
 
-	  To compile this driver as a module, choose M here and read
-	  <file:Documentation/networking/net-modules.txt>.  The module will be
+	  To compile this driver as a module, choose M here. The module will be
 	  called enc28j60.
 
 config ENC28J60_WRITEVERIFY
@@ -2040,8 +2039,7 @@ config IGB
          More specific information on configuring the driver is in
          <file:Documentation/networking/e1000.txt>.
 
-         To compile this driver as a module, choose M here and read
-         <file:Documentation/networking/net-modules.txt>.  The module
+         To compile this driver as a module, choose M here. The module
          will be called igb.
 
 source "drivers/net/ixp2000/Kconfig"
-- 
1.5.4



