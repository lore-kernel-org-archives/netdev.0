From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] bt: fix l2cap build error
Date: Mon, 24 Aug 2009 14:41:53 -0700
Message-ID: <4A930921.5050700@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-next@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Marcel Holtmann <marcel@holtmann.org>,
	akpm <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix net/bluetooth/l2cap.c build errors:

l2cap.c:(.text+0x126035): undefined reference to `crc16'
l2cap.c:(.text+0x126323): undefined reference to `crc16'
l2cap.c:(.text+0x12668e): undefined reference to `crc16'
l2cap.c:(.text+0x12683b): undefined reference to `crc16'
l2cap.c:(.text+0x126956): undefined reference to `crc16'
net/built-in.o:l2cap.c:(.text+0x129041): more undefined references to `crc16' follow

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 net/bluetooth/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- linux-next-20090824.orig/net/bluetooth/Kconfig
+++ linux-next-20090824/net/bluetooth/Kconfig
@@ -34,6 +34,7 @@ menuconfig BT
 config BT_L2CAP
 	tristate "L2CAP protocol support"
 	depends on BT
+	select CRC16
 	help
 	  L2CAP (Logical Link Control and Adaptation Protocol) provides
 	  connection oriented and connection-less data transport.  L2CAP
