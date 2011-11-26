From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH net-next 7/8] net: Revert ARCNET and PHYLIB to tristate
 options
Date: Sat, 26 Nov 2011 00:40:02 +0000
Message-ID: <1322268002.2839.390.camel@deadeye>
References: <1322267572.2839.381.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34315 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753937Ab1KZAkI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 19:40:08 -0500
In-Reply-To: <1322267572.2839.381.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 88491d8103498a6166f70d5999902fec70924314 ("drivers/net: Kconfig
& Makefile cleanup") changed the type of these options to bool, but
they select code that could (and still can) be built as modules.

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
Yes David, they do still build this way.  Even in an allmodconfig
configuration, now.  And I still really want this in net.

Ben.

 drivers/net/arcnet/Kconfig |    2 +-
 drivers/net/phy/Kconfig    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arcnet/Kconfig b/drivers/net/arcnet/Kconfig
index a73d9dc..84fb634 100644
--- a/drivers/net/arcnet/Kconfig
+++ b/drivers/net/arcnet/Kconfig
@@ -4,7 +4,7 @@
 
 menuconfig ARCNET
 	depends on NETDEVICES && (ISA || PCI || PCMCIA)
-	bool "ARCnet support"
+	tristate "ARCnet support"
 	---help---
 	  If you have a network card of this type, say Y and check out the
 	  (arguably) beautiful poetry in
diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
index bb88e12..a702443 100644
--- a/drivers/net/phy/Kconfig
+++ b/drivers/net/phy/Kconfig
@@ -3,7 +3,7 @@
 #
 
 menuconfig PHYLIB
-	bool "PHY Device support and infrastructure"
+	tristate "PHY Device support and infrastructure"
 	depends on !S390
 	depends on NETDEVICES
 	help
-- 
1.7.7.3
