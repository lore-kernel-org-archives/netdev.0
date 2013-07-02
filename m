From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCH v6 5/7] ARM: kirkwood: remove redundant DT board files
Date: Wed, 03 Jul 2013 01:09:50 +0200
Message-ID: <87k3l8v9s1.fsf@natisbad.org>
References: <1372762824-12202-1-git-send-email-sebastian.hesselbarth@gmail.com>
	<1372762824-12202-6-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Russell King <linux@arm.linux.org.uk>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1372762824-12202-6-git-send-email-sebastian.hesselbarth@gmail.com>
	(Sebastian Hesselbarth's message of "Tue, 2 Jul 2013 13:00:22 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sebastian,

Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com> writes:

> With DT support for mv643xx_eth board specific init for some boards now
> is unneccessary. Remove those board files, Kconfig entries, and
> corresponding entries in kirkwood_defconfig.

Applying above your set an old quilt cleaning patch Jason asked at some
point, it became empty except for arch/arm/mach_kirkwood/common.h in
which some declarations were left behind. If this is correct, can you
just merge the hunks below in your 5/7 in next round?

AFAICT, only dnskw_init() remains, which matches the list of board-*.c
files in arch/arm/mach_kirkwood/ (i.e. board-dt.c and board-dnskw.c).

Cheers,

a+

Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
---
 arch/arm/mach-kirkwood/common.h | 108 ----------------------------------------
 1 file changed, 108 deletions(-)

diff --git a/arch/arm/mach-kirkwood/common.h b/arch/arm/mach-kirkwood/common.h
index 1c09f3f..1cbdd2b 100644
--- a/arch/arm/mach-kirkwood/common.h
+++ b/arch/arm/mach-kirkwood/common.h
@@ -57,26 +57,6 @@ void kirkwood_restart(char, const char *);
 void kirkwood_clk_init(void);
 
 /* board init functions for boards not fully converted to fdt */
-#ifdef CONFIG_MACH_DREAMPLUG_DT
-void dreamplug_init(void);
-#else
-static inline void dreamplug_init(void) {};
-#endif
-#ifdef CONFIG_MACH_GURUPLUG_DT
-void guruplug_dt_init(void);
-#else
-static inline void guruplug_dt_init(void) {};
-#endif
-#ifdef CONFIG_MACH_SHEEVAPLUG_DT
-void sheevaplug_dt_init(void);
-#else
-static inline void sheevaplug_dt_init(void) {};
-#endif
-#ifdef CONFIG_MACH_TS219_DT
-void qnap_dt_ts219_init(void);
-#else
-static inline void qnap_dt_ts219_init(void) {};
-#endif
 
 #ifdef CONFIG_MACH_DLINK_KIRKWOOD_DT
 void dnskw_init(void);
@@ -84,94 +64,6 @@ void dnskw_init(void);
 static inline void dnskw_init(void) {};
 #endif
 
-#ifdef CONFIG_MACH_ICONNECT_DT
-void iconnect_init(void);
-#else
-static inline void iconnect_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_IB62X0_DT
-void ib62x0_init(void);
-#else
-static inline void ib62x0_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_DOCKSTAR_DT
-void dockstar_dt_init(void);
-#else
-static inline void dockstar_dt_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_GOFLEXNET_DT
-void goflexnet_init(void);
-#else
-static inline void goflexnet_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_LSXL_DT
-void lsxl_init(void);
-#else
-static inline void lsxl_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_IOMEGA_IX2_200_DT
-void iomega_ix2_200_init(void);
-#else
-static inline void iomega_ix2_200_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_KM_KIRKWOOD_DT
-void km_kirkwood_init(void);
-#else
-static inline void km_kirkwood_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_DB88F628X_BP_DT
-void db88f628x_init(void);
-#else
-static inline void db88f628x_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_MPLCEC4_DT
-void mplcec4_init(void);
-#else
-static inline void mplcec4_init(void) {};
-#endif
-
-#if defined(CONFIG_MACH_INETSPACE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_MAX_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_LITE_V2_DT) || \
-	defined(CONFIG_MACH_NETSPACE_MINI_V2_DT)
-void ns2_init(void);
-#else
-static inline void ns2_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_OPENBLOCKS_A6_DT
-void openblocks_a6_init(void);
-#else
-static inline void openblocks_a6_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_READYNAS_DT
-void netgear_readynas_init(void);
-#else
-static inline void netgear_readynas_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_TOPKICK_DT
-void usi_topkick_init(void);
-#else
-static inline void usi_topkick_init(void) {};
-#endif
-
-#ifdef CONFIG_MACH_CLOUDBOX_DT
-void cloudbox_init(void);
-#else
-static inline void cloudbox_init(void) {};
-#endif
-
 /* early init functions not converted to fdt yet */
 char *kirkwood_id(void);
 void kirkwood_l2_init(void);
-- 
1.8.3.1
