From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.4.28-pre3] 3c59x: remove EEPROM_RESET for 3c905B
Date: Sun, 17 Oct 2004 11:20:26 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041017152026.GD13491@tuxdriver.com>
References: <20040928145455.C12480@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcelo.tosatti@cyclades.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20040928145455.C12480@tuxdriver.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Remove the EEPROM_RESET flag for the 3c905B cards.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
Looks like I over-reached.  Apparently only the 3c905 cards actually
need the EEPROM reset, and the 3c905B cards don't like it...

(Virtually identical to the 2.6 patch posted previously...)

 drivers/net/3c59x.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

--- linux-2.4/drivers/net/3c59x.c.orig	2004-10-17 11:11:01.023739152 -0400
+++ linux-2.4/drivers/net/3c59x.c	2004-10-17 11:11:24.834119424 -0400
@@ -506,12 +506,12 @@ static struct vortex_chip_info {
 	{"3c905 Boomerang 100baseT4",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_BOOMERANG|HAS_MII|EEPROM_RESET, 64, },
 	{"3c905B Cyclone 100baseTx",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE|EEPROM_RESET, 128, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 
 	{"3c905B Cyclone 10/100/BNC",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EEPROM_RESET, 128, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
 	{"3c905B-FX Cyclone 100baseFx",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM|EEPROM_RESET, 128, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c905C Tornado",
 	PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 	{"3c920B-EMB-WNM (ATI Radeon 9100 IGP)",
@@ -562,7 +562,7 @@ static struct vortex_chip_info {
 	{"3c982 Hydra Dual Port B",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_HWCKSM|HAS_NWAY, 128, },
 	{"3c905B-T4",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE|EEPROM_RESET, 128, },
+	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM|EXTRA_PREAMBLE, 128, },
 	{"3c920B-EMB-WNM Tornado",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },
 
-- 
John W. Linville
linville@tuxdriver.com
