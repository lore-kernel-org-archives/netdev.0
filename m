From: akpm@osdl.org
Subject: [patch 7/8] sk98lin debug build fix
Date: Mon, 04 Dec 2006 15:04:56 -0800
Message-ID: <200612042306.kB4N65Vx008017@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, m.kozlowski@tuxland.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:53672 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S967745AbWLDXGQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 18:06:16 -0500
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>

Fix parenthesis mismatch.


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/sk98lin/skgesirq.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/sk98lin/skgesirq.c~sk98lin-debug-build-fix drivers/net/sk98lin/skgesirq.c
--- a/drivers/net/sk98lin/skgesirq.c~sk98lin-debug-build-fix
+++ a/drivers/net/sk98lin/skgesirq.c
@@ -1319,7 +1319,7 @@ SK_BOOL	AutoNeg)	/* Is Auto-negotiation 
 	SkXmPhyRead(pAC, IoC, Port, PHY_BCOM_INT_STAT, &Isrc);
 
 #ifdef xDEBUG
-	if ((Isrc & ~(PHY_B_IS_HCT | PHY_B_IS_LCT) ==
+	if ((Isrc & ~(PHY_B_IS_HCT | PHY_B_IS_LCT)) ==
 		(PHY_B_IS_SCR_S_ER | PHY_B_IS_RRS_CHANGE | PHY_B_IS_LRS_CHANGE)) {
 
 		SK_U32	Stat1, Stat2, Stat3;
_
