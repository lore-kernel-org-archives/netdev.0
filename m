From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v2 1/8] net: sh-eth: Remove ifdef from definition of bit of EDSR and GECMR
Date: Thu, 18 Apr 2013 19:11:02 +0900
Message-ID: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: yoshihiro.shimoda.uh@renesas.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:39565 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545Ab3DRKLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 06:11:20 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so1290361dad.4
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 03:11:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
 v2: no change.

 drivers/net/ethernet/renesas/sh_eth.h |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
index 6f9a997..f86ea96 100644
--- a/drivers/net/ethernet/renesas/sh_eth.h
+++ b/drivers/net/ethernet/renesas/sh_eth.h
@@ -166,19 +166,16 @@ enum {
 /*
  * Register's bits
  */
-#if defined(CONFIG_CPU_SUBTYPE_SH7734) || defined(CONFIG_CPU_SUBTYPE_SH7763) ||\
-    defined(CONFIG_ARCH_R8A7740)
-/* EDSR */
+/* EDSR : sh7734, sh7764, sh7757 and r8a7740 only */
 enum EDSR_BIT {
 	EDSR_ENT = 0x01, EDSR_ENR = 0x02,
 };
 #define EDSR_ENALL (EDSR_ENT|EDSR_ENR)
 
-/* GECMR */
+/* GECMR : sh7734, sh7764 and r8a7740 only */
 enum GECMR_BIT {
 	GECMR_10 = 0x0, GECMR_100 = 0x04, GECMR_1000 = 0x01,
 };
-#endif
 
 /* EDMR */
 enum DMAC_M_BIT {
-- 
1.7.10.4
