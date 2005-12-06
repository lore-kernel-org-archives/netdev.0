From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 11/14] spidernet: fix Kconfig after BPA->CELL rename
Date: Mon, 05 Dec 2005 22:52:31 -0500
Message-ID: <20051206040645.065973000@localhost>
References: <20051206035220.097737000@localhost>
Cc: linuxppc64-dev@ozlabs.org, netdev@vger.kernel.org,
	Arnd Bergmann <arndb@de.ibm.com>, Jens.Osterkamp@de.ibm.com
Return-path: <linuxppc64-dev-bounces@ozlabs.org>
To: paulus@samba.org
Content-Disposition: inline; filename=spidernet-with-pci-and-cell.diff
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc64-dev>
List-Post: <mailto:linuxppc64-dev@ozlabs.org>
List-Help: <mailto:linuxppc64-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc64-dev>,
	<mailto:linuxppc64-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc64-dev-bounces@ozlabs.org
Errors-To: linuxppc64-dev-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

We changed the name of the Kconfig symbols along with
the move to arch/powerpc. This one hunk got lost during
the conversion.

From: Jens.Osterkamp@de.ibm.com
Cc: netdev@vger.kernel.org
Signed-off-by: Arnd Bergmann <arndb@de.ibm.com>

Index: linux-2.6.15-rc1/drivers/net/Kconfig
===================================================================
--- linux-2.6.15-rc1.orig/drivers/net/Kconfig
+++ linux-2.6.15-rc1/drivers/net/Kconfig
@@ -2120,7 +2120,7 @@ config BNX2
 
 config SPIDER_NET
 	tristate "Spider Gigabit Ethernet driver"
-	depends on PCI && PPC_BPA
+	depends on PCI && PPC_CELL
 	help
 	  This driver supports the Gigabit Ethernet chips present on the
 	  Cell Processor-Based Blades from IBM.

--
