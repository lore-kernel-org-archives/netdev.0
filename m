From: akpm@osdl.org
Subject: [patch 09/13] bonding needs inet
Date: Tue, 15 Mar 2005 14:22:46 -0800
Message-ID: <200503152222.j2FMMfU6016817@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



The bonding driver needs CONFIG_INET, for arp_create(), arp_send(), arp_xmit().

Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/Kconfig |    1 +
 1 files changed, 1 insertion(+)

diff -puN drivers/net/Kconfig~bonding-needs-inet drivers/net/Kconfig
--- 25/drivers/net/Kconfig~bonding-needs-inet	Tue Mar 15 14:19:54 2005
+++ 25-akpm/drivers/net/Kconfig	Tue Mar 15 14:19:54 2005
@@ -44,6 +44,7 @@ config DUMMY
 config BONDING
 	tristate "Bonding driver support"
 	depends on NETDEVICES
+	depends on INET
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
_
