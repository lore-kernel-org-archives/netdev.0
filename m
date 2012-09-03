From: pablo@netfilter.org
Subject: [PATCH 22/25] netfilter: remove xt_NOTRACK
Date: Tue,  4 Sep 2012 01:54:09 +0200
Message-ID: <1346716452-3080-23-git-send-email-pablo@netfilter.org>
References: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:37180 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756616Ab2ICX4J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Sep 2012 19:56:09 -0400
In-Reply-To: <1346716452-3080-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

It was scheduled to be removed for a long time.

Cc: Pablo Neira Ayuso <pablo@netfilter.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netfilter@vger.kernel.org
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/feature-removal-schedule.txt |    8 -----
 arch/m68k/configs/amiga_defconfig          |    1 -
 arch/m68k/configs/apollo_defconfig         |    1 -
 arch/m68k/configs/atari_defconfig          |    1 -
 arch/m68k/configs/bvme6000_defconfig       |    1 -
 arch/m68k/configs/hp300_defconfig          |    1 -
 arch/m68k/configs/mac_defconfig            |    1 -
 arch/m68k/configs/multi_defconfig          |    1 -
 arch/m68k/configs/mvme147_defconfig        |    1 -
 arch/m68k/configs/mvme16x_defconfig        |    1 -
 arch/m68k/configs/q40_defconfig            |    1 -
 arch/m68k/configs/sun3_defconfig           |    1 -
 arch/m68k/configs/sun3x_defconfig          |    1 -
 arch/mips/configs/ar7_defconfig            |    1 -
 arch/mips/configs/bcm47xx_defconfig        |    1 -
 arch/mips/configs/ip22_defconfig           |    1 -
 arch/mips/configs/jazz_defconfig           |    1 -
 arch/mips/configs/malta_defconfig          |    1 -
 arch/mips/configs/markeins_defconfig       |    1 -
 arch/mips/configs/nlm_xlp_defconfig        |    1 -
 arch/mips/configs/nlm_xlr_defconfig        |    1 -
 arch/mips/configs/rm200_defconfig          |    1 -
 arch/powerpc/configs/pmac32_defconfig      |    1 -
 arch/powerpc/configs/ppc64_defconfig       |    1 -
 arch/powerpc/configs/ppc64e_defconfig      |    1 -
 arch/powerpc/configs/ppc6xx_defconfig      |    1 -
 arch/tile/configs/tilegx_defconfig         |    1 -
 arch/tile/configs/tilepro_defconfig        |    1 -
 net/netfilter/Kconfig                      |   13 -------
 net/netfilter/Makefile                     |    1 -
 net/netfilter/xt_NOTRACK.c                 |   53 ----------------------------
 31 files changed, 102 deletions(-)
 delete mode 100644 net/netfilter/xt_NOTRACK.c

diff --git a/Documentation/feature-removal-schedule.txt b/Documentation/feature-removal-schedule.txt
index afaff31..b4aab82 100644
--- a/Documentation/feature-removal-schedule.txt
+++ b/Documentation/feature-removal-schedule.txt
@@ -353,14 +353,6 @@ Why:	Internal alias support has been present in module-init-tools for some
 
 Who:	Wey-Yi Guy <wey-yi.w.guy@intel.com>
 
----------------------------
-
-What:	xt_NOTRACK
-Files:	net/netfilter/xt_NOTRACK.c
-When:	April 2011
-Why:	Superseded by xt_CT
-Who:	Netfilter developer team <netfilter-devel@vger.kernel.org>
-
 ----------------------------
 
 What:	IRQF_DISABLED
diff --git a/arch/m68k/configs/amiga_defconfig b/arch/m68k/configs/amiga_defconfig
index e93fdae..90d3109 100644
--- a/arch/m68k/configs/amiga_defconfig
+++ b/arch/m68k/configs/amiga_defconfig
@@ -67,7 +67,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/apollo_defconfig b/arch/m68k/configs/apollo_defconfig
index 66b26c1..8f4f657 100644
--- a/arch/m68k/configs/apollo_defconfig
+++ b/arch/m68k/configs/apollo_defconfig
@@ -67,7 +67,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/atari_defconfig b/arch/m68k/configs/atari_defconfig
index 1513325..4571d33 100644
--- a/arch/m68k/configs/atari_defconfig
+++ b/arch/m68k/configs/atari_defconfig
@@ -65,7 +65,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/bvme6000_defconfig b/arch/m68k/configs/bvme6000_defconfig
index 67bb6fc..12f2117 100644
--- a/arch/m68k/configs/bvme6000_defconfig
+++ b/arch/m68k/configs/bvme6000_defconfig
@@ -65,7 +65,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/hp300_defconfig b/arch/m68k/configs/hp300_defconfig
index 3e35ce5..215389a 100644
--- a/arch/m68k/configs/hp300_defconfig
+++ b/arch/m68k/configs/hp300_defconfig
@@ -66,7 +66,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/mac_defconfig b/arch/m68k/configs/mac_defconfig
index ae81e2d..cb9dfb3 100644
--- a/arch/m68k/configs/mac_defconfig
+++ b/arch/m68k/configs/mac_defconfig
@@ -61,7 +61,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/multi_defconfig b/arch/m68k/configs/multi_defconfig
index 55d394e..8d5def4 100644
--- a/arch/m68k/configs/multi_defconfig
+++ b/arch/m68k/configs/multi_defconfig
@@ -80,7 +80,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/mvme147_defconfig b/arch/m68k/configs/mvme147_defconfig
index af77374..e2af46f 100644
--- a/arch/m68k/configs/mvme147_defconfig
+++ b/arch/m68k/configs/mvme147_defconfig
@@ -64,7 +64,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/mvme16x_defconfig b/arch/m68k/configs/mvme16x_defconfig
index cdb70d6..7c9402b 100644
--- a/arch/m68k/configs/mvme16x_defconfig
+++ b/arch/m68k/configs/mvme16x_defconfig
@@ -65,7 +65,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/q40_defconfig b/arch/m68k/configs/q40_defconfig
index 46bed78..19d23db 100644
--- a/arch/m68k/configs/q40_defconfig
+++ b/arch/m68k/configs/q40_defconfig
@@ -61,7 +61,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/sun3_defconfig b/arch/m68k/configs/sun3_defconfig
index 86f7772..ca6c0b4 100644
--- a/arch/m68k/configs/sun3_defconfig
+++ b/arch/m68k/configs/sun3_defconfig
@@ -62,7 +62,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/m68k/configs/sun3x_defconfig b/arch/m68k/configs/sun3x_defconfig
index 2882614..c80941c 100644
--- a/arch/m68k/configs/sun3x_defconfig
+++ b/arch/m68k/configs/sun3x_defconfig
@@ -62,7 +62,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/mips/configs/ar7_defconfig b/arch/mips/configs/ar7_defconfig
index 6cd5a51..80e012f 100644
--- a/arch/mips/configs/ar7_defconfig
+++ b/arch/mips/configs/ar7_defconfig
@@ -56,7 +56,6 @@ CONFIG_NF_CONNTRACK_MARK=y
 CONFIG_NF_CONNTRACK_FTP=m
 CONFIG_NF_CONNTRACK_IRC=m
 CONFIG_NF_CONNTRACK_TFTP=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_MATCH_LIMIT=m
 CONFIG_NETFILTER_XT_MATCH_MAC=m
diff --git a/arch/mips/configs/bcm47xx_defconfig b/arch/mips/configs/bcm47xx_defconfig
index ad15fb1..b6fde2b 100644
--- a/arch/mips/configs/bcm47xx_defconfig
+++ b/arch/mips/configs/bcm47xx_defconfig
@@ -96,7 +96,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
diff --git a/arch/mips/configs/ip22_defconfig b/arch/mips/configs/ip22_defconfig
index d160656..936ec5a 100644
--- a/arch/mips/configs/ip22_defconfig
+++ b/arch/mips/configs/ip22_defconfig
@@ -87,7 +87,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
diff --git a/arch/mips/configs/jazz_defconfig b/arch/mips/configs/jazz_defconfig
index 92a60ae..0315ee3 100644
--- a/arch/mips/configs/jazz_defconfig
+++ b/arch/mips/configs/jazz_defconfig
@@ -60,7 +60,6 @@ CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_MATCH_COMMENT=m
diff --git a/arch/mips/configs/malta_defconfig b/arch/mips/configs/malta_defconfig
index 5527abb..cd732e5 100644
--- a/arch/mips/configs/malta_defconfig
+++ b/arch/mips/configs/malta_defconfig
@@ -86,7 +86,6 @@ CONFIG_NETFILTER_XT_TARGET_CONNMARK=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
diff --git a/arch/mips/configs/markeins_defconfig b/arch/mips/configs/markeins_defconfig
index 9c9a123..636f82b 100644
--- a/arch/mips/configs/markeins_defconfig
+++ b/arch/mips/configs/markeins_defconfig
@@ -59,7 +59,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_MATCH_COMMENT=m
diff --git a/arch/mips/configs/nlm_xlp_defconfig b/arch/mips/configs/nlm_xlp_defconfig
index 28c6b27..84624b1 100644
--- a/arch/mips/configs/nlm_xlp_defconfig
+++ b/arch/mips/configs/nlm_xlp_defconfig
@@ -108,7 +108,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
diff --git a/arch/mips/configs/nlm_xlr_defconfig b/arch/mips/configs/nlm_xlr_defconfig
index 138f698..44b4734 100644
--- a/arch/mips/configs/nlm_xlr_defconfig
+++ b/arch/mips/configs/nlm_xlr_defconfig
@@ -109,7 +109,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
diff --git a/arch/mips/configs/rm200_defconfig b/arch/mips/configs/rm200_defconfig
index 2c0230e..59d9d2f 100644
--- a/arch/mips/configs/rm200_defconfig
+++ b/arch/mips/configs/rm200_defconfig
@@ -68,7 +68,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_MATCH_COMMENT=m
diff --git a/arch/powerpc/configs/pmac32_defconfig b/arch/powerpc/configs/pmac32_defconfig
index f8b394a..29767a8 100644
--- a/arch/powerpc/configs/pmac32_defconfig
+++ b/arch/powerpc/configs/pmac32_defconfig
@@ -55,7 +55,6 @@ CONFIG_NETFILTER_XT_TARGET_CLASSIFY=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
 CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP=m
diff --git a/arch/powerpc/configs/ppc64_defconfig b/arch/powerpc/configs/ppc64_defconfig
index db27c82..06b5624 100644
--- a/arch/powerpc/configs/ppc64_defconfig
+++ b/arch/powerpc/configs/ppc64_defconfig
@@ -92,7 +92,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
diff --git a/arch/powerpc/configs/ppc64e_defconfig b/arch/powerpc/configs/ppc64e_defconfig
index 7bd1763..f55c276 100644
--- a/arch/powerpc/configs/ppc64e_defconfig
+++ b/arch/powerpc/configs/ppc64e_defconfig
@@ -66,7 +66,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_TCPMSS=m
diff --git a/arch/powerpc/configs/ppc6xx_defconfig b/arch/powerpc/configs/ppc6xx_defconfig
index c47f2be..be1cb6e 100644
--- a/arch/powerpc/configs/ppc6xx_defconfig
+++ b/arch/powerpc/configs/ppc6xx_defconfig
@@ -167,7 +167,6 @@ CONFIG_NETFILTER_XT_TARGET_DSCP=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
 CONFIG_NETFILTER_XT_TARGET_SECMARK=m
diff --git a/arch/tile/configs/tilegx_defconfig b/arch/tile/configs/tilegx_defconfig
index 0270620..8c5eff6 100644
--- a/arch/tile/configs/tilegx_defconfig
+++ b/arch/tile/configs/tilegx_defconfig
@@ -134,7 +134,6 @@ CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TEE=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
diff --git a/arch/tile/configs/tilepro_defconfig b/arch/tile/configs/tilepro_defconfig
index c11de27..e7a3dfc 100644
--- a/arch/tile/configs/tilepro_defconfig
+++ b/arch/tile/configs/tilepro_defconfig
@@ -132,7 +132,6 @@ CONFIG_NETFILTER_XT_TARGET_IDLETIMER=m
 CONFIG_NETFILTER_XT_TARGET_MARK=m
 CONFIG_NETFILTER_XT_TARGET_NFLOG=m
 CONFIG_NETFILTER_XT_TARGET_NFQUEUE=m
-CONFIG_NETFILTER_XT_TARGET_NOTRACK=m
 CONFIG_NETFILTER_XT_TARGET_TEE=m
 CONFIG_NETFILTER_XT_TARGET_TPROXY=m
 CONFIG_NETFILTER_XT_TARGET_TRACE=m
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 052836e..3f4b3b4 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -670,19 +670,6 @@ config NETFILTER_XT_TARGET_NFQUEUE
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config NETFILTER_XT_TARGET_NOTRACK
-	tristate  '"NOTRACK" target support'
-	depends on IP_NF_RAW || IP6_NF_RAW
-	depends on NF_CONNTRACK
-	help
-	  The NOTRACK target allows a select rule to specify
-	  which packets *not* to enter the conntrack/NAT
-	  subsystem with all the consequences (no ICMP error tracking,
-	  no protocol helpers for the selected packets).
-
-	  If you want to compile it as a module, say M here and read
-	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
-
 config NETFILTER_XT_TARGET_RATEEST
 	tristate '"RATEEST" target support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 403ea812..98244d4 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -85,7 +85,6 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_LED) += xt_LED.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_LOG) += xt_LOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFLOG) += xt_NFLOG.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_NFQUEUE) += xt_NFQUEUE.o
-obj-$(CONFIG_NETFILTER_XT_TARGET_NOTRACK) += xt_NOTRACK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_RATEEST) += xt_RATEEST.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_SECMARK) += xt_SECMARK.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TPROXY) += xt_TPROXY.o
diff --git a/net/netfilter/xt_NOTRACK.c b/net/netfilter/xt_NOTRACK.c
deleted file mode 100644
index 9d78218..0000000
--- a/net/netfilter/xt_NOTRACK.c
+++ /dev/null
@@ -1,53 +0,0 @@
-/* This is a module which is used for setting up fake conntracks
- * on packets so that they are not seen by the conntrack/NAT code.
- */
-#include <linux/module.h>
-#include <linux/skbuff.h>
-
-#include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_conntrack.h>
-
-MODULE_DESCRIPTION("Xtables: Disabling connection tracking for packets");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("ipt_NOTRACK");
-MODULE_ALIAS("ip6t_NOTRACK");
-
-static unsigned int
-notrack_tg(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	/* Previously seen (loopback)? Ignore. */
-	if (skb->nfct != NULL)
-		return XT_CONTINUE;
-
-	/* Attach fake conntrack entry.
-	   If there is a real ct entry correspondig to this packet,
-	   it'll hang aroun till timing out. We don't deal with it
-	   for performance reasons. JK */
-	skb->nfct = &nf_ct_untracked_get()->ct_general;
-	skb->nfctinfo = IP_CT_NEW;
-	nf_conntrack_get(skb->nfct);
-
-	return XT_CONTINUE;
-}
-
-static struct xt_target notrack_tg_reg __read_mostly = {
-	.name     = "NOTRACK",
-	.revision = 0,
-	.family   = NFPROTO_UNSPEC,
-	.target   = notrack_tg,
-	.table    = "raw",
-	.me       = THIS_MODULE,
-};
-
-static int __init notrack_tg_init(void)
-{
-	return xt_register_target(&notrack_tg_reg);
-}
-
-static void __exit notrack_tg_exit(void)
-{
-	xt_unregister_target(&notrack_tg_reg);
-}
-
-module_init(notrack_tg_init);
-module_exit(notrack_tg_exit);
-- 
1.7.10.4
