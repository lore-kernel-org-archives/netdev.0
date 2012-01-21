From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH 9/14] kernel-doc: fix new warning in net/phy/mdio_bus.c
Date: Sat, 21 Jan 2012 11:03:04 -0800
Message-ID: <4F1B0BE8.9050403@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>

Fix new kernel-doc warning:

Warning(drivers/net/phy/mdio_bus.c:49): No description found for parameter 'size'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/phy/mdio_bus.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- lnx-33-rc1.orig/drivers/net/phy/mdio_bus.c
+++ lnx-33-rc1/drivers/net/phy/mdio_bus.c
@@ -38,12 +38,11 @@
 
 /**
  * mdiobus_alloc_size - allocate a mii_bus structure
+ * @size: extra amount of memory to allocate for private storage.
+ * If non-zero, then bus->priv is points to that memory.
  *
  * Description: called by a bus driver to allocate an mii_bus
  * structure to fill in.
- *
- * 'size' is an an extra amount of memory to allocate for private storage.
- * If non-zero, then bus->priv is points to that memory.
  */
 struct mii_bus *mdiobus_alloc_size(size_t size)
 {
