From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH v5 1/8] sh_eth: remove #ifdef around EDSR and GECMR bit definitions
Date: Thu, 6 Jun 2013 23:43:16 +0400
Message-ID: <201306062343.16875.sergei.shtylyov@cogentembedded.com>
References: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: nobuhiro.iwamatsu.yj@renesas.com, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201306062339.21353.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

Remove #ifdef around 'enum EDSR_BIT' and 'enum GECMR_BIT', replacing it with the
comments on which SoCs these registers exist.

SH7757 also has EDSR, so add a comment about it to 'enum EDSR_BIT'. 

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
[Sergei: folded in the former patch #2, updated the changelog, reworded the
subject, changing the prefix.]
Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
Changes in version 5:
- expanded the changelog.

Changes in version 4:
- folded in the former patch #2, updated the changelog accordingly;
- reworded the subject, changing the prefix.

Changes in version 3:
- fix comment.

 drivers/net/ethernet/renesas/sh_eth.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.h
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.h
+++ net-next/drivers/net/ethernet/renesas/sh_eth.h
@@ -166,19 +166,16 @@ enum {
 /*
  * Register's bits
  */
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) ||\
-    defined(CONFIG_ARCH_R8A7740)
-/* EDSR */
+/* EDSR : sh7734, sh7757, sh7763, and r8a7740 only */
 enum EDSR_BIT {
 	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
 };
 #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
 
-/* GECMR */
+/* GECMR : sh7734, sh7763 and r8a7740 only */
 enum GECMR_BIT {
 	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
 };
-#endif
 
 /* EDMR */
 enum DMAC_M_BIT {

