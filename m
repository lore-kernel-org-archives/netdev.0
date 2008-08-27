From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH] e1000: remove unused Kconfig option for disabling
	packet split
Date: Wed, 27 Aug 2008 01:19:56 -0700
Message-ID: <20080827081956.11114.152.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, akpm@linux-foundation.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:65424 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752876AbYH0IUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 04:20:01 -0400
Received: by py-out-1112.google.com with SMTP id p76so1656435pyb.10
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 01:19:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

Since the e1000/e1000e split, no hardware supported by e1000
supports packet split, just remove the Kconfig option and associated
code from arch/* and the driver.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 arch/arm/configs/iop13xx_defconfig              |    1 
 arch/arm/configs/iop32x_defconfig               |    1 
 arch/arm/configs/iop33x_defconfig               |    1 
 arch/arm/configs/ixp23xx_defconfig              |    1 
 arch/arm/configs/kirkwood_defconfig             |    1 
 arch/ia64/configs/generic_defconfig             |    1 
 arch/ia64/configs/gensparse_defconfig           |    1 
 arch/ia64/configs/tiger_defconfig               |    1 
 arch/ia64/configs/zx1_defconfig                 |    1 
 arch/mips/configs/mtx1_defconfig                |    1 
 arch/parisc/configs/a500_defconfig              |    1 
 arch/parisc/configs/c3000_defconfig             |    1 
 arch/powerpc/configs/83xx/mpc832x_rdb_defconfig |    1 
 arch/powerpc/configs/85xx/mpc8560_ads_defconfig |    1 
 arch/powerpc/configs/85xx/mpc85xx_cds_defconfig |    1 
 arch/powerpc/configs/85xx/tqm8548_defconfig     |    1 
 arch/powerpc/configs/cell_defconfig             |    1 
 arch/powerpc/configs/g5_defconfig               |    1 
 arch/powerpc/configs/iseries_defconfig          |    1 
 arch/powerpc/configs/maple_defconfig            |    1 
 arch/powerpc/configs/pasemi_defconfig           |    1 
 arch/powerpc/configs/ppc64_defconfig            |    1 
 arch/powerpc/configs/ppc6xx_defconfig           |    1 
 arch/powerpc/configs/prpmc2800_defconfig        |    1 
 arch/powerpc/configs/pseries_defconfig          |    1 
 arch/sh/configs/r7780mp_defconfig               |    1 
 arch/sparc64/defconfig                          |    1 
 arch/x86/configs/i386_defconfig                 |    1 
 arch/x86/configs/x86_64_defconfig               |    1 
 drivers/net/Kconfig                             |    9 
 drivers/net/e1000/e1000.h                       |   17 -
 drivers/net/e1000/e1000_main.c                  |  416 -----------------------
 32 files changed, 9 insertions(+), 462 deletions(-)

diff --git a/arch/arm/configs/iop13xx_defconfig b/arch/arm/configs/iop13xx_defconfig
index 482e570..d97bd72 100644
--- a/arch/arm/configs/iop13xx_defconfig
+++ b/arch/arm/configs/iop13xx_defconfig
@@ -585,7 +585,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/arm/configs/iop32x_defconfig b/arch/arm/configs/iop32x_defconfig
index 8612f58..f02f504 100644
--- a/arch/arm/configs/iop32x_defconfig
+++ b/arch/arm/configs/iop32x_defconfig
@@ -677,7 +677,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/arm/configs/iop33x_defconfig b/arch/arm/configs/iop33x_defconfig
index 8b0098d..2855d87 100644
--- a/arch/arm/configs/iop33x_defconfig
+++ b/arch/arm/configs/iop33x_defconfig
@@ -587,7 +587,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/arm/configs/ixp23xx_defconfig b/arch/arm/configs/ixp23xx_defconfig
index 4a2f7b2..e367554 100644
--- a/arch/arm/configs/ixp23xx_defconfig
+++ b/arch/arm/configs/ixp23xx_defconfig
@@ -688,7 +688,6 @@ CONFIG_E100=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
diff --git a/arch/arm/configs/kirkwood_defconfig b/arch/arm/configs/kirkwood_defconfig
index e3357ba..2a7fa26 100644
--- a/arch/arm/configs/kirkwood_defconfig
+++ b/arch/arm/configs/kirkwood_defconfig
@@ -681,7 +681,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/ia64/configs/generic_defconfig b/arch/ia64/configs/generic_defconfig
index 9f48397..f961b66 100644
--- a/arch/ia64/configs/generic_defconfig
+++ b/arch/ia64/configs/generic_defconfig
@@ -727,7 +727,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_IP1000 is not set
 CONFIG_IGB=y
diff --git a/arch/ia64/configs/gensparse_defconfig b/arch/ia64/configs/gensparse_defconfig
index e86fbd3..32183df 100644
--- a/arch/ia64/configs/gensparse_defconfig
+++ b/arch/ia64/configs/gensparse_defconfig
@@ -595,7 +595,6 @@ CONFIG_E100=m
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
diff --git a/arch/ia64/configs/tiger_defconfig b/arch/ia64/configs/tiger_defconfig
index 797acf9..2bf0150 100644
--- a/arch/ia64/configs/tiger_defconfig
+++ b/arch/ia64/configs/tiger_defconfig
@@ -575,7 +575,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
diff --git a/arch/ia64/configs/zx1_defconfig b/arch/ia64/configs/zx1_defconfig
index 0a06b13..9c15db3 100644
--- a/arch/ia64/configs/zx1_defconfig
+++ b/arch/ia64/configs/zx1_defconfig
@@ -635,7 +635,6 @@ CONFIG_E100=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
 # CONFIG_YELLOWFIN is not set
diff --git a/arch/mips/configs/mtx1_defconfig b/arch/mips/configs/mtx1_defconfig
index db92726..7912768 100644
--- a/arch/mips/configs/mtx1_defconfig
+++ b/arch/mips/configs/mtx1_defconfig
@@ -1296,7 +1296,6 @@ CONFIG_ACENIC=m
 CONFIG_DL2K=m
 CONFIG_E1000=m
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_NS83820=m
 CONFIG_HAMACHI=m
 CONFIG_YELLOWFIN=m
diff --git a/arch/parisc/configs/a500_defconfig b/arch/parisc/configs/a500_defconfig
index ddacc72..95bbaff 100644
--- a/arch/parisc/configs/a500_defconfig
+++ b/arch/parisc/configs/a500_defconfig
@@ -592,7 +592,6 @@ CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/parisc/configs/c3000_defconfig b/arch/parisc/configs/c3000_defconfig
index c6def3c..aa5db3a 100644
--- a/arch/parisc/configs/c3000_defconfig
+++ b/arch/parisc/configs/c3000_defconfig
@@ -553,7 +553,6 @@ CONFIG_ACENIC=m
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
index de95d32..660137d 100644
--- a/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
+++ b/arch/powerpc/configs/83xx/mpc832x_rdb_defconfig
@@ -521,7 +521,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
index e19592b..9ae8480 100644
--- a/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
+++ b/arch/powerpc/configs/85xx/mpc8560_ads_defconfig
@@ -457,7 +457,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
index b09f003..79dd42c 100644
--- a/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
+++ b/arch/powerpc/configs/85xx/mpc85xx_cds_defconfig
@@ -510,7 +510,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/85xx/tqm8548_defconfig b/arch/powerpc/configs/85xx/tqm8548_defconfig
index b3b770b..34dac06 100644
--- a/arch/powerpc/configs/85xx/tqm8548_defconfig
+++ b/arch/powerpc/configs/85xx/tqm8548_defconfig
@@ -621,7 +621,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/cell_defconfig b/arch/powerpc/configs/cell_defconfig
index c420e47..53e5c76 100644
--- a/arch/powerpc/configs/cell_defconfig
+++ b/arch/powerpc/configs/cell_defconfig
@@ -801,7 +801,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/g5_defconfig b/arch/powerpc/configs/g5_defconfig
index 0ccc6e4..e60347c 100644
--- a/arch/powerpc/configs/g5_defconfig
+++ b/arch/powerpc/configs/g5_defconfig
@@ -741,7 +741,6 @@ CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/iseries_defconfig b/arch/powerpc/configs/iseries_defconfig
index 63f0bdb..b27b91b 100644
--- a/arch/powerpc/configs/iseries_defconfig
+++ b/arch/powerpc/configs/iseries_defconfig
@@ -663,7 +663,6 @@ CONFIG_ACENIC=m
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/maple_defconfig b/arch/powerpc/configs/maple_defconfig
index 7a166a3..bbea044 100644
--- a/arch/powerpc/configs/maple_defconfig
+++ b/arch/powerpc/configs/maple_defconfig
@@ -608,7 +608,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_NS83820 is not set
 # CONFIG_HAMACHI is not set
diff --git a/arch/powerpc/configs/pasemi_defconfig b/arch/powerpc/configs/pasemi_defconfig
index 199e5f5..b247740 100644
--- a/arch/powerpc/configs/pasemi_defconfig
+++ b/arch/powerpc/configs/pasemi_defconfig
@@ -791,7 +791,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index ce250bc..dd36ef0 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -950,7 +950,6 @@ CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index e6e91c8..e6b236c 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -1373,7 +1373,6 @@ CONFIG_ACENIC=m
 CONFIG_DL2K=m
 CONFIG_E1000=m
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_E1000E=m
 CONFIG_E1000E_ENABLED=y
 CONFIG_IP1000=m
diff --git a/arch/powerpc/configs/prpmc2800_defconfig b/arch/powerpc/configs/prpmc2800_defconfig
index c6b8357..c5872b3 100644
--- a/arch/powerpc/configs/prpmc2800_defconfig
+++ b/arch/powerpc/configs/prpmc2800_defconfig
@@ -742,7 +742,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/powerpc/configs/pseries_defconfig b/arch/powerpc/configs/pseries_defconfig
index fe6ffa6..77ad1cc 100644
--- a/arch/powerpc/configs/pseries_defconfig
+++ b/arch/powerpc/configs/pseries_defconfig
@@ -768,7 +768,6 @@ CONFIG_ACENIC_OMIT_TIGON_I=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/sh/configs/r7780mp_defconfig b/arch/sh/configs/r7780mp_defconfig
index 57a3007..960b194 100644
--- a/arch/sh/configs/r7780mp_defconfig
+++ b/arch/sh/configs/r7780mp_defconfig
@@ -645,7 +645,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_ACENIC is not set
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_IP1000 is not set
 # CONFIG_IGB is not set
diff --git a/arch/sparc64/defconfig b/arch/sparc64/defconfig
index 82cab5c..8c106d1 100644
--- a/arch/sparc64/defconfig
+++ b/arch/sparc64/defconfig
@@ -589,7 +589,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=m
 CONFIG_E1000_NAPI=y
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/x86/configs/i386_defconfig b/arch/x86/configs/i386_defconfig
index 4d73f53..f5d4056 100644
--- a/arch/x86/configs/i386_defconfig
+++ b/arch/x86/configs/i386_defconfig
@@ -962,7 +962,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/arch/x86/configs/x86_64_defconfig b/arch/x86/configs/x86_64_defconfig
index a404524..a5bad7c 100644
--- a/arch/x86/configs/x86_64_defconfig
+++ b/arch/x86/configs/x86_64_defconfig
@@ -947,7 +947,6 @@ CONFIG_NETDEV_1000=y
 # CONFIG_DL2K is not set
 CONFIG_E1000=y
 # CONFIG_E1000_NAPI is not set
-# CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 # CONFIG_E1000E is not set
 # CONFIG_E1000E_ENABLED is not set
 # CONFIG_IP1000 is not set
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index a5c141c..cded492 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1927,15 +1927,6 @@ config E1000
 	  To compile this driver as a module, choose M here. The module
 	  will be called e1000.
 
-config E1000_DISABLE_PACKET_SPLIT
-	bool "Disable Packet Split for PCI express adapters"
-	depends on E1000
-	help
-	  Say Y here if you want to use the legacy receive path for PCI express
-	  hardware.
-
-	  If in doubt, say N.
-
 config E1000E
 	tristate "Intel(R) PRO/1000 PCI-Express Gigabit Ethernet support"
 	depends on PCI && (!SPARC32 || BROKEN)
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 19e317e..62f6297 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -155,8 +155,6 @@ do {									\
 #endif
 
 #define E1000_MNG_VLAN_NONE (-1)
-/* Number of packet split data buffers (not including the header buffer) */
-#define PS_PAGE_BUFFERS (MAX_PS_BUFFERS - 1)
 
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
@@ -168,14 +166,6 @@ struct e1000_buffer {
 	u16 next_to_watch;
 };
 
-struct e1000_ps_page {
-	struct page *ps_page[PS_PAGE_BUFFERS];
-};
-
-struct e1000_ps_page_dma {
-	u64 ps_page_dma[PS_PAGE_BUFFERS];
-};
-
 struct e1000_tx_ring {
 	/* pointer to the descriptor ring memory */
 	void *desc;
@@ -213,9 +203,6 @@ struct e1000_rx_ring {
 	unsigned int next_to_clean;
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
-	/* arrays of page information for packet split */
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
 
 	/* cpu for rx queue */
 	int cpu;
@@ -228,8 +215,6 @@ struct e1000_rx_ring {
 	((((R)->next_to_clean > (R)->next_to_use)			\
 	  ? 0 : (R)->count) + (R)->next_to_clean - (R)->next_to_use - 1)
 
-#define E1000_RX_DESC_PS(R, i)						\
-	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
 #define E1000_RX_DESC_EXT(R, i)						\
 	(&(((union e1000_rx_desc_extended *)((R).desc))[i]))
 #define E1000_GET_DESC(R, i, type)	(&(((struct type *)((R).desc))[i]))
@@ -311,10 +296,8 @@ struct e1000_adapter {
 	u32 rx_int_delay;
 	u32 rx_abs_int_delay;
 	bool rx_csum;
-	unsigned int rx_ps_pages;
 	u32 gorcl;
 	u64 gorcl_old;
-	u16 rx_ps_bsize0;
 
 	/* OS defined structs */
 	struct net_device *netdev;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index ad6da7b..2ab44db 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -137,15 +137,9 @@ static int e1000_clean(struct napi_struct *napi, int budget);
 static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			       struct e1000_rx_ring *rx_ring,
 			       int *work_done, int work_to_do);
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring,
-				  int *work_done, int work_to_do);
 static void e1000_alloc_rx_buffers(struct e1000_adapter *adapter,
                                    struct e1000_rx_ring *rx_ring,
 				   int cleaned_count);
-static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-                                      struct e1000_rx_ring *rx_ring,
-				      int cleaned_count);
 static int e1000_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd);
 static int e1000_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 			   int cmd);
@@ -1331,7 +1325,6 @@ static int __devinit e1000_sw_init(struct e1000_adapter *adapter)
 	pci_read_config_word(pdev, PCI_COMMAND, &hw->pci_cmd_word);
 
 	adapter->rx_buffer_len = MAXIMUM_ETHERNET_VLAN_SIZE;
-	adapter->rx_ps_bsize0 = E1000_RXBUFFER_128;
 	hw->max_frame_size = netdev->mtu +
 			     ENET_HEADER_SIZE + ETHERNET_FCS_SIZE;
 	hw->min_frame_size = MINIMUM_ETHERNET_FRAME_SIZE;
@@ -1815,26 +1808,6 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 	}
 	memset(rxdr->buffer_info, 0, size);
 
-	rxdr->ps_page = kcalloc(rxdr->count, sizeof(struct e1000_ps_page),
-	                        GFP_KERNEL);
-	if (!rxdr->ps_page) {
-		vfree(rxdr->buffer_info);
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
-		return -ENOMEM;
-	}
-
-	rxdr->ps_page_dma = kcalloc(rxdr->count,
-	                            sizeof(struct e1000_ps_page_dma),
-	                            GFP_KERNEL);
-	if (!rxdr->ps_page_dma) {
-		vfree(rxdr->buffer_info);
-		kfree(rxdr->ps_page);
-		DPRINTK(PROBE, ERR,
-		"Unable to allocate memory for the receive descriptor ring\n");
-		return -ENOMEM;
-	}
-
 	if (hw->mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
 	else
@@ -1852,8 +1825,6 @@ static int e1000_setup_rx_resources(struct e1000_adapter *adapter,
 		"Unable to allocate memory for the receive descriptor ring\n");
 setup_rx_desc_die:
 		vfree(rxdr->buffer_info);
-		kfree(rxdr->ps_page);
-		kfree(rxdr->ps_page_dma);
 		return -ENOMEM;
 	}
 
@@ -1932,11 +1903,7 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
 static void e1000_setup_rctl(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
-	u32 rctl, rfctl;
-	u32 psrctl = 0;
-#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
-	u32 pages = 0;
-#endif
+	u32 rctl;
 
 	rctl = er32(RCTL);
 
@@ -1988,55 +1955,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 			break;
 	}
 
-#ifndef CONFIG_E1000_DISABLE_PACKET_SPLIT
-	/* 82571 and greater support packet-split where the protocol
-	 * header is placed in skb->data and the packet data is
-	 * placed in pages hanging off of skb_shinfo(skb)->nr_frags.
-	 * In the case of a non-split, skb->data is linearly filled,
-	 * followed by the page buffers.  Therefore, skb->data is
-	 * sized to hold the largest protocol header.
-	 */
-	/* allocations using alloc_page take too long for regular MTU
-	 * so only enable packet split for jumbo frames */
-	pages = PAGE_USE_COUNT(adapter->netdev->mtu);
-	if ((hw->mac_type >= e1000_82571) && (pages <= 3) &&
-	    PAGE_SIZE <= 16384 && (rctl & E1000_RCTL_LPE))
-		adapter->rx_ps_pages = pages;
-	else
-		adapter->rx_ps_pages = 0;
-#endif
-	if (adapter->rx_ps_pages) {
-		/* Configure extra packet-split registers */
-		rfctl = er32(RFCTL);
-		rfctl |= E1000_RFCTL_EXTEN;
-		/* disable packet split support for IPv6 extension headers,
-		 * because some malformed IPv6 headers can hang the RX */
-		rfctl |= (E1000_RFCTL_IPV6_EX_DIS |
-		          E1000_RFCTL_NEW_IPV6_EXT_DIS);
-
-		ew32(RFCTL, rfctl);
-
-		rctl |= E1000_RCTL_DTYP_PS;
-
-		psrctl |= adapter->rx_ps_bsize0 >>
-			E1000_PSRCTL_BSIZE0_SHIFT;
-
-		switch (adapter->rx_ps_pages) {
-		case 3:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE3_SHIFT;
-		case 2:
-			psrctl |= PAGE_SIZE <<
-				E1000_PSRCTL_BSIZE2_SHIFT;
-		case 1:
-			psrctl |= PAGE_SIZE >>
-				E1000_PSRCTL_BSIZE1_SHIFT;
-			break;
-		}
-
-		ew32(PSRCTL, psrctl);
-	}
-
 	ew32(RCTL, rctl);
 }
 
@@ -2053,18 +1971,10 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	u32 rdlen, rctl, rxcsum, ctrl_ext;
 
-	if (adapter->rx_ps_pages) {
-		/* this is a 32 byte descriptor */
-		rdlen = adapter->rx_ring[0].count *
-			sizeof(union e1000_rx_desc_packet_split);
-		adapter->clean_rx = e1000_clean_rx_irq_ps;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers_ps;
-	} else {
-		rdlen = adapter->rx_ring[0].count *
-			sizeof(struct e1000_rx_desc);
-		adapter->clean_rx = e1000_clean_rx_irq;
-		adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
-	}
+	rdlen = adapter->rx_ring[0].count *
+		sizeof(struct e1000_rx_desc);
+	adapter->clean_rx = e1000_clean_rx_irq;
+	adapter->alloc_rx_buf = e1000_alloc_rx_buffers;
 
 	/* disable receives while setting up the descriptors */
 	rctl = er32(RCTL);
@@ -2109,28 +2019,14 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
 		rxcsum = er32(RXCSUM);
-		if (adapter->rx_csum) {
+		if (adapter->rx_csum)
 			rxcsum |= E1000_RXCSUM_TUOFL;
-
-			/* Enable 82571 IPv4 payload checksum for UDP fragments
-			 * Must be used in conjunction with packet-split. */
-			if ((hw->mac_type >= e1000_82571) &&
-			    (adapter->rx_ps_pages)) {
-				rxcsum |= E1000_RXCSUM_IPPCSE;
-			}
-		} else {
-			rxcsum &= ~E1000_RXCSUM_TUOFL;
+		else
 			/* don't need to clear IPPCSE as it defaults to 0 */
-		}
+			rxcsum &= ~E1000_RXCSUM_TUOFL;
 		ew32(RXCSUM, rxcsum);
 	}
 
-	/* enable early receives on 82573, only takes effect if using > 2048
-	 * byte total frame size.  for example only for jumbo frames */
-#define E1000_ERT_2048 0x100
-	if (hw->mac_type == e1000_82573)
-		ew32(ERT, E1000_ERT_2048);
-
 	/* Enable Receives */
 	ew32(RCTL, rctl);
 }
@@ -2256,10 +2152,6 @@ static void e1000_free_rx_resources(struct e1000_adapter *adapter,
 
 	vfree(rx_ring->buffer_info);
 	rx_ring->buffer_info = NULL;
-	kfree(rx_ring->ps_page);
-	rx_ring->ps_page = NULL;
-	kfree(rx_ring->ps_page_dma);
-	rx_ring->ps_page_dma = NULL;
 
 	pci_free_consistent(pdev, rx_ring->size, rx_ring->desc, rx_ring->dma);
 
@@ -2292,11 +2184,9 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 {
 	struct e1000_hw *hw = &adapter->hw;
 	struct e1000_buffer *buffer_info;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
 	struct pci_dev *pdev = adapter->pdev;
 	unsigned long size;
-	unsigned int i, j;
+	unsigned int i;
 
 	/* Free all the Rx ring sk_buffs */
 	for (i = 0; i < rx_ring->count; i++) {
@@ -2310,25 +2200,10 @@ static void e1000_clean_rx_ring(struct e1000_adapter *adapter,
 			dev_kfree_skb(buffer_info->skb);
 			buffer_info->skb = NULL;
 		}
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-		for (j = 0; j < adapter->rx_ps_pages; j++) {
-			if (!ps_page->ps_page[j]) break;
-			pci_unmap_page(pdev,
-				       ps_page_dma->ps_page_dma[j],
-				       PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			ps_page_dma->ps_page_dma[j] = 0;
-			put_page(ps_page->ps_page[j]);
-			ps_page->ps_page[j] = NULL;
-		}
 	}
 
 	size = sizeof(struct e1000_buffer) * rx_ring->count;
 	memset(rx_ring->buffer_info, 0, size);
-	size = sizeof(struct e1000_ps_page) * rx_ring->count;
-	memset(rx_ring->ps_page, 0, size);
-	size = sizeof(struct e1000_ps_page_dma) * rx_ring->count;
-	memset(rx_ring->ps_page_dma, 0, size);
 
 	/* Zero out the descriptor ring */
 
@@ -4235,181 +4110,6 @@ next_desc:
 }
 
 /**
- * e1000_clean_rx_irq_ps - Send received data up the network stack; packet split
- * @adapter: board private structure
- **/
-
-static bool e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
-				  struct e1000_rx_ring *rx_ring,
-				  int *work_done, int work_to_do)
-{
-	union e1000_rx_desc_packet_split *rx_desc, *next_rxd;
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	struct e1000_buffer *buffer_info, *next_buffer;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
-	struct sk_buff *skb;
-	unsigned int i, j;
-	u32 length, staterr;
-	int cleaned_count = 0;
-	bool cleaned = false;
-	unsigned int total_rx_bytes=0, total_rx_packets=0;
-
-	i = rx_ring->next_to_clean;
-	rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
-	staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
-	buffer_info = &rx_ring->buffer_info[i];
-
-	while (staterr & E1000_RXD_STAT_DD) {
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-
-		if (unlikely(*work_done >= work_to_do))
-			break;
-		(*work_done)++;
-
-		skb = buffer_info->skb;
-
-		/* in the packet split case this is header only */
-		prefetch(skb->data - NET_IP_ALIGN);
-
-		if (++i == rx_ring->count) i = 0;
-		next_rxd = E1000_RX_DESC_PS(*rx_ring, i);
-		prefetch(next_rxd);
-
-		next_buffer = &rx_ring->buffer_info[i];
-
-		cleaned = true;
-		cleaned_count++;
-		pci_unmap_single(pdev, buffer_info->dma,
-				 buffer_info->length,
-				 PCI_DMA_FROMDEVICE);
-
-		if (unlikely(!(staterr & E1000_RXD_STAT_EOP))) {
-			E1000_DBG("%s: Packet Split buffers didn't pick up"
-				  " the full packet\n", netdev->name);
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		if (unlikely(staterr & E1000_RXDEXT_ERR_FRAME_ERR_MASK)) {
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		length = le16_to_cpu(rx_desc->wb.middle.length0);
-
-		if (unlikely(!length)) {
-			E1000_DBG("%s: Last part of the packet spanning"
-				  " multiple descriptors\n", netdev->name);
-			dev_kfree_skb_irq(skb);
-			goto next_desc;
-		}
-
-		/* Good Receive */
-		skb_put(skb, length);
-
-		{
-		/* this looks ugly, but it seems compiler issues make it
-		   more efficient than reusing j */
-		int l1 = le16_to_cpu(rx_desc->wb.upper.length[0]);
-
-		/* page alloc/put takes too long and effects small packet
-		 * throughput, so unsplit small packets and save the alloc/put*/
-		if (l1 && (l1 <= copybreak) && ((length + l1) <= adapter->rx_ps_bsize0)) {
-			u8 *vaddr;
-			/* there is no documentation about how to call
-			 * kmap_atomic, so we can't hold the mapping
-			 * very long */
-			pci_dma_sync_single_for_cpu(pdev,
-				ps_page_dma->ps_page_dma[0],
-				PAGE_SIZE,
-				PCI_DMA_FROMDEVICE);
-			vaddr = kmap_atomic(ps_page->ps_page[0],
-			                    KM_SKB_DATA_SOFTIRQ);
-			memcpy(skb_tail_pointer(skb), vaddr, l1);
-			kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
-			pci_dma_sync_single_for_device(pdev,
-				ps_page_dma->ps_page_dma[0],
-				PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			/* remove the CRC */
-			l1 -= 4;
-			skb_put(skb, l1);
-			goto copydone;
-		} /* if */
-		}
-
-		for (j = 0; j < adapter->rx_ps_pages; j++) {
-			length = le16_to_cpu(rx_desc->wb.upper.length[j]);
-			if (!length)
-				break;
-			pci_unmap_page(pdev, ps_page_dma->ps_page_dma[j],
-					PAGE_SIZE, PCI_DMA_FROMDEVICE);
-			ps_page_dma->ps_page_dma[j] = 0;
-			skb_fill_page_desc(skb, j, ps_page->ps_page[j], 0,
-			                   length);
-			ps_page->ps_page[j] = NULL;
-			skb->len += length;
-			skb->data_len += length;
-			skb->truesize += length;
-		}
-
-		/* strip the ethernet crc, problem is we're using pages now so
-		 * this whole operation can get a little cpu intensive */
-		pskb_trim(skb, skb->len - 4);
-
-copydone:
-		total_rx_bytes += skb->len;
-		total_rx_packets++;
-
-		e1000_rx_checksum(adapter, staterr,
-				  le16_to_cpu(rx_desc->wb.lower.hi_dword.csum_ip.csum), skb);
-		skb->protocol = eth_type_trans(skb, netdev);
-
-		if (likely(rx_desc->wb.upper.header_status &
-			   cpu_to_le16(E1000_RXDPS_HDRSTAT_HDRSP)))
-			adapter->rx_hdr_split++;
-
-		if (unlikely(adapter->vlgrp && (staterr & E1000_RXD_STAT_VP))) {
-			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->wb.middle.vlan));
-		} else {
-			netif_receive_skb(skb);
-		}
-
-		netdev->last_rx = jiffies;
-
-next_desc:
-		rx_desc->wb.middle.status_error &= cpu_to_le32(~0xFF);
-		buffer_info->skb = NULL;
-
-		/* return some buffers to hardware, one at a time is too slow */
-		if (unlikely(cleaned_count >= E1000_RX_BUFFER_WRITE)) {
-			adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
-			cleaned_count = 0;
-		}
-
-		/* use prefetched values */
-		rx_desc = next_rxd;
-		buffer_info = next_buffer;
-
-		staterr = le32_to_cpu(rx_desc->wb.middle.status_error);
-	}
-	rx_ring->next_to_clean = i;
-
-	cleaned_count = E1000_DESC_UNUSED(rx_ring);
-	if (cleaned_count)
-		adapter->alloc_rx_buf(adapter, rx_ring, cleaned_count);
-
-	adapter->total_rx_packets += total_rx_packets;
-	adapter->total_rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_bytes += total_rx_bytes;
-	adapter->net_stats.rx_packets += total_rx_packets;
-	return cleaned;
-}
-
-/**
  * e1000_alloc_rx_buffers - Replace used receive buffers; legacy & extended
  * @adapter: address of board private structure
  **/
@@ -4521,104 +4221,6 @@ map_skb:
 }
 
 /**
- * e1000_alloc_rx_buffers_ps - Replace used receive buffers; packet split
- * @adapter: address of board private structure
- **/
-
-static void e1000_alloc_rx_buffers_ps(struct e1000_adapter *adapter,
-				      struct e1000_rx_ring *rx_ring,
-				      int cleaned_count)
-{
-	struct e1000_hw *hw = &adapter->hw;
-	struct net_device *netdev = adapter->netdev;
-	struct pci_dev *pdev = adapter->pdev;
-	union e1000_rx_desc_packet_split *rx_desc;
-	struct e1000_buffer *buffer_info;
-	struct e1000_ps_page *ps_page;
-	struct e1000_ps_page_dma *ps_page_dma;
-	struct sk_buff *skb;
-	unsigned int i, j;
-
-	i = rx_ring->next_to_use;
-	buffer_info = &rx_ring->buffer_info[i];
-	ps_page = &rx_ring->ps_page[i];
-	ps_page_dma = &rx_ring->ps_page_dma[i];
-
-	while (cleaned_count--) {
-		rx_desc = E1000_RX_DESC_PS(*rx_ring, i);
-
-		for (j = 0; j < PS_PAGE_BUFFERS; j++) {
-			if (j < adapter->rx_ps_pages) {
-				if (likely(!ps_page->ps_page[j])) {
-					ps_page->ps_page[j] =
-						alloc_page(GFP_ATOMIC);
-					if (unlikely(!ps_page->ps_page[j])) {
-						adapter->alloc_rx_buff_failed++;
-						goto no_buffers;
-					}
-					ps_page_dma->ps_page_dma[j] =
-						pci_map_page(pdev,
-							    ps_page->ps_page[j],
-							    0, PAGE_SIZE,
-							    PCI_DMA_FROMDEVICE);
-				}
-				/* Refresh the desc even if buffer_addrs didn't
-				 * change because each write-back erases
-				 * this info.
-				 */
-				rx_desc->read.buffer_addr[j+1] =
-				     cpu_to_le64(ps_page_dma->ps_page_dma[j]);
-			} else
-				rx_desc->read.buffer_addr[j+1] = ~cpu_to_le64(0);
-		}
-
-		skb = netdev_alloc_skb(netdev,
-		                       adapter->rx_ps_bsize0 + NET_IP_ALIGN);
-
-		if (unlikely(!skb)) {
-			adapter->alloc_rx_buff_failed++;
-			break;
-		}
-
-		/* Make buffer alignment 2 beyond a 16 byte boundary
-		 * this will result in a 16 byte aligned IP header after
-		 * the 14 byte MAC header is removed
-		 */
-		skb_reserve(skb, NET_IP_ALIGN);
-
-		buffer_info->skb = skb;
-		buffer_info->length = adapter->rx_ps_bsize0;
-		buffer_info->dma = pci_map_single(pdev, skb->data,
-						  adapter->rx_ps_bsize0,
-						  PCI_DMA_FROMDEVICE);
-
-		rx_desc->read.buffer_addr[0] = cpu_to_le64(buffer_info->dma);
-
-		if (unlikely(++i == rx_ring->count)) i = 0;
-		buffer_info = &rx_ring->buffer_info[i];
-		ps_page = &rx_ring->ps_page[i];
-		ps_page_dma = &rx_ring->ps_page_dma[i];
-	}
-
-no_buffers:
-	if (likely(rx_ring->next_to_use != i)) {
-		rx_ring->next_to_use = i;
-		if (unlikely(i-- == 0)) i = (rx_ring->count - 1);
-
-		/* Force memory writes to complete before letting h/w
-		 * know there are new descriptors to fetch.  (Only
-		 * applicable for weak-ordered memory model archs,
-		 * such as IA-64). */
-		wmb();
-		/* Hardware increments by 16 bytes, but packet split
-		 * descriptors are 32 bytes...so we increment tail
-		 * twice as much.
-		 */
-		writel(i<<1, hw->hw_addr + rx_ring->rdt);
-	}
-}
-
-/**
  * e1000_smartspeed - Workaround for SmartSpeed on 82541 and 82547 controllers.
  * @adapter:
  **/

