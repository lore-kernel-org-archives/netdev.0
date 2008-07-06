From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/3] netdev: remove unused S2IO_NAPI
Date: Sun, 6 Jul 2008 23:41:09 +0200
Message-ID: <20080706214109.GA13120@electric-eye.fr.zoreil.com>
References: <20080704125446.GA30300@havoc.gtf.org> <20080705.211029.199316974.davem@davemloft.net> <20080705.212051.82650078.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43554 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209AbYGFVlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Jul 2008 17:41:22 -0400
Content-Disposition: inline
In-Reply-To: <20080705.212051.82650078.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 Documentation/networking/s2io.txt      |    7 ++-----
 arch/ia64/configs/sn2_defconfig        |    1 -
 arch/mips/configs/mtx1_defconfig       |    1 -
 arch/powerpc/configs/pseries_defconfig |    1 -
 arch/x86/configs/x86_64_defconfig      |    1 -
 drivers/net/Kconfig                    |   14 --------------
 6 files changed, 2 insertions(+), 23 deletions(-)

diff --git a/Documentation/networking/s2io.txt b/Documentation/networking/s2io.txt
index 1e28e2d..5dcd939 100644
--- a/Documentation/networking/s2io.txt
+++ b/Documentation/networking/s2io.txt
@@ -52,13 +52,10 @@ d. MSI/MSI-X. Can be enabled on platforms which support this feature
 (IA64, Xeon) resulting in noticeable performance improvement(upto 7%
 on certain platforms).
 
-e. NAPI. Compile-time option(CONFIG_S2IO_NAPI) for better Rx interrupt 
-moderation.
-
-f. Statistics. Comprehensive MAC-level and software statistics displayed
+e. Statistics. Comprehensive MAC-level and software statistics displayed
 using "ethtool -S" option.
 
-g. Multi-FIFO/Ring. Supports up to 8 transmit queues and receive rings, 
+f. Multi-FIFO/Ring. Supports up to 8 transmit queues and receive rings,
 with multiple steering options.
 
 4.  Command line parameters
diff --git a/arch/ia64/configs/sn2_defconfig b/arch/ia64/configs/sn2_defconfig
index 7f6b237..e4cb115 100644
--- a/arch/ia64/configs/sn2_defconfig
+++ b/arch/ia64/configs/sn2_defconfig
@@ -649,7 +649,6 @@ CONFIG_CHELSIO_T3=m
 CONFIG_IXGBE=m
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
-# CONFIG_S2IO_NAPI is not set
 # CONFIG_MYRI10GE is not set
 # CONFIG_NETXEN_NIC is not set
 # CONFIG_NIU is not set
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index fa3aa39..de523b3 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -1322,7 +1322,6 @@ CONFIG_CHELSIO_T1_NAPI=y
 CONFIG_IXGB=m
 # CONFIG_IXGB_NAPI is not set
 CONFIG_S2IO=m
-# CONFIG_S2IO_NAPI is not set
 CONFIG_MYRI10GE=m
 # CONFIG_NETXEN_NIC is not set
 # CONFIG_MLX4_CORE is not set
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index adaa05f..da9cec4 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -792,7 +792,6 @@ CONFIG_NETDEV_10000=y
 CONFIG_IXGB=m
 # CONFIG_IXGB_NAPI is not set
 CONFIG_S2IO=m
-# CONFIG_S2IO_NAPI is not set
 # CONFIG_MYRI10GE is not set
 # CONFIG_NETXEN_NIC is not set
 # CONFIG_NIU is not set
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index 2d6f5b2..c88a85a 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -757,7 +757,6 @@ CONFIG_NETDEV_10000=y
 # CONFIG_CHELSIO_T3 is not set
 # CONFIG_IXGB is not set
 CONFIG_S2IO=m
-# CONFIG_S2IO_NAPI is not set
 # CONFIG_MYRI10GE is not set
 # CONFIG_NETXEN_NIC is not set
 # CONFIG_MLX4_CORE is not set
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4182cf..e34a3e7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2496,20 +2496,6 @@ config S2IO
 	  More specific information on configuring the driver is in 
 	  <file:Documentation/networking/s2io.txt>.
 
-config S2IO_NAPI
-	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
-	depends on S2IO && EXPERIMENTAL
-	help
-	  NAPI is a new driver API designed to reduce CPU and interrupt load
-	  when the driver is receiving lots of packets from the card. It is
-	  still somewhat experimental and thus not yet enabled by default.
-
-	  If your estimated Rx load is 10kpps or more, or if the card will be
-	  deployed on potentially unfriendly networks (e.g. in a firewall),
-	  then say Y here.
-
-	  If in doubt, say N.
-
 config MYRI10GE
 	tristate "Myricom Myri-10G Ethernet support"
 	depends on PCI && INET
-- 
1.5.3.3

