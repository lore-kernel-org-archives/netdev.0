From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] octeon: depends on NETDEVICES
Date: Tue, 24 Aug 2010 14:09:40 -0700
Message-ID: <20100824140940.57369e83.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, support@caviumnetworks.com,
	Arnaud Lacombe <lacombar@gmail.com>
To: devel@driverdev.osuosl.org, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:28781 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755328Ab0HXVKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 17:10:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

OCTEON_ETHERNET should depend on NETDEVICES.

Fixes this kconfig warning:

warning: (NET_DSA && NET && EXPERIMENTAL && NETDEVICES && !S390 || ...
|| OCTEON_ETHERNET && STAGING && !STAGING_EXCLUDE_BUILD && CPU_CAVIUM_OCTEON) selects PHYLIB which has unmet direct dependencies (!S390 && NETDEVICES)

Reported-by: Arnaud Lacombe <lacombar@gmail.com>
Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: support@caviumnetworks.com
---
 drivers/staging/octeon/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20100823.orig/drivers/staging/octeon/Kconfig
+++ linux-next-20100823/drivers/staging/octeon/Kconfig
@@ -1,6 +1,6 @@
 config OCTEON_ETHERNET
 	tristate "Cavium Networks Octeon Ethernet support"
-	depends on CPU_CAVIUM_OCTEON
+	depends on CPU_CAVIUM_OCTEON && NETDEVICES
 	select PHYLIB
 	select MDIO_OCTEON
 	help
