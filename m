From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 1/2] bonding: create its own Kconfig
Date: Tue, 15 Jul 2014 12:15:40 +0200
Message-ID: <1405419341-31510-2-git-send-email-vfalico@gmail.com>
References: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758104AbaGOKUH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 06:20:07 -0400
In-Reply-To: <1405419341-31510-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/Kconfig         | 18 +-----------------
 drivers/net/bonding/Kconfig | 17 +++++++++++++++++
 2 files changed, 18 insertions(+), 17 deletions(-)
 create mode 100644 drivers/net/bonding/Kconfig

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index c6f6f69..16b6b9c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -37,23 +37,7 @@ config NET_CORE
 
 if NET_CORE
 
-config BONDING
-	tristate "Bonding driver support"
-	depends on INET
-	depends on IPV6 || IPV6=n
-	---help---
-	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
-	  Channels together. This is called 'Etherchannel' by Cisco,
-	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.
-
-	  The driver supports multiple bonding modes to allow for both high
-	  performance and high availability operation.
-
-	  Refer to <file:Documentation/networking/bonding.txt> for more
-	  information.
-
-	  To compile this driver as a module, choose M here: the module
-	  will be called bonding.
+source "drivers/net/bonding/Kconfig"
 
 config DUMMY
 	tristate "Dummy net driver support"
diff --git a/drivers/net/bonding/Kconfig b/drivers/net/bonding/Kconfig
new file mode 100644
index 0000000..7b1a0fa
--- /dev/null
+++ b/drivers/net/bonding/Kconfig
@@ -0,0 +1,17 @@
+menuconfig BONDING
+	tristate "Bonding driver support"
+	depends on INET
+	depends on IPV6 || IPV6=n
+	---help---
+	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
+	  Channels together. This is called 'Etherchannel' by Cisco,
+	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.
+
+	  The driver supports multiple bonding modes to allow for both high
+	  performance and high availability operation.
+
+	  Refer to <file:Documentation/networking/bonding.txt> for more
+	  information.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called bonding.
-- 
1.8.4
