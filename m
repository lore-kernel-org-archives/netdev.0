From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6] 3c59x: Add EEPROM_RESET for 3c900 Boomerang
Date: Wed, 24 Nov 2004 14:39:57 -0500
Message-ID: <20041124143956.A24342@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add 3c900 Boomerang to list of devices needing EEPROM_RESET

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/3c59x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

===== drivers/net/3c59x.c 1.66 vs edited =====
--- 1.66/drivers/net/3c59x.c	2004-10-30 10:22:13 -04:00
+++ edited/drivers/net/3c59x.c	2004-11-24 14:31:49 -05:00
@@ -492,9 +492,9 @@
 	{"3c595 Vortex 100base-MII",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_VORTEX, 32, },
 	{"3c900 Boomerang 10baseT",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_BOOMERANG, 64, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_BOOMERANG|EEPROM_RESET, 64, },
 	{"3c900 Boomerang 10Mbps Combo",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_BOOMERANG, 64, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_BOOMERANG|EEPROM_RESET, 64, },
 	{"3c900 Cyclone 10Mbps TPO",						/* AKPM: from Don's 0.99M */
 	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c900 Cyclone 10Mbps Combo",
