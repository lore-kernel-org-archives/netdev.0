From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] bluetooth/hci_bcsp: fix bitrev Kconfig
Date: Wed, 18 Jun 2008 14:06:12 -0700
Message-ID: <20080618140612.5384f97c.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm <akpm@linux-foundation.org>, marcel@holtmann.org,
	maxk@qualcomm.com, davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:55001 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751709AbYFRVJB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 17:09:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix bluetooth hci_bcsp Kconfig to avoid build errors:

drivers/built-in.o: In function `bcsp_prepare_pkt':
hci_bcsp.c:(.text+0x7e9ac): undefined reference to `bitrev16'
drivers/built-in.o: In function `bcsp_recv':
hci_bcsp.c:(.text+0x7f276): undefined reference to `bitrev16'
hci_bcsp.c:(.text+0x7f293): undefined reference to `bitrev16'
make[1]: *** [.tmp_vmlinux1] Error 1

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/bluetooth/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20080618.orig/drivers/bluetooth/Kconfig
+++ linux-next-20080618/drivers/bluetooth/Kconfig
@@ -71,7 +71,7 @@ config BT_HCIUART_H4
 config BT_HCIUART_BCSP
 	bool "BCSP protocol support"
 	depends on BT_HCIUART
-	select CONFIG_BITREVERSE
+	select BITREVERSE
 	help
 	  BCSP (BlueCore Serial Protocol) is serial protocol for communication 
 	  between Bluetooth device and host. This protocol is required for non


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
