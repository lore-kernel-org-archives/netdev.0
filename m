From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3 1/9] net: sh-eth: Remove ifdef from definition of bit of EDSR and GECMR
Date: Tue,  7 May 2013 14:17:47 +0900
Message-ID: <1367903875-32606-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	sergei.shtylyov@cogentembedded.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:57483 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab3EGFSL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:18:11 -0400
Received: by mail-pa0-f41.google.com with SMTP id rl6so222966pac.0
        for <netdev@vger.kernel.org>; Mon, 06 May 2013 22:18:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
V3:
  Fix comment.
V2:
  no change.
 drivers/net/ethernet/renesas/sh_eth.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 26cb8a0..7ccf58c 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -166,19 +166,16 @@ enum {
 /*
  * Register's bits
  */
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) ||\
-    defined(CONFIG_ARCH_R8A7740)
-/* EDSR */
+/* EDSR : sh7734, sh7763 and r8a7740 only */
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
-- 
1.7.10.4
