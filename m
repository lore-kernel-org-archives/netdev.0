From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: fix missing loop variable increment
Date: Thu, 3 Jan 2008 23:38:38 +0100
Message-ID: <20080103223838.GA19191@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Citizen Lee <citizen_lee@thecus.com>"@fr.zoreil.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49627 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752745AbYACWuK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2008 17:50:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spotted-by: Citizen Lee <citizen_lee@thecus.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5863190..6ee9db1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2002,7 +2002,7 @@ static void rtl8169_set_magic_reg(void __iomem *ioaddr, unsigned mac_version)
 	u32 clk;
 
 	clk = RTL_R8(Config2) & PCI_Clock_66MHz;
-	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++) {
+	for (i = 0; i < ARRAY_SIZE(cfg2_info); i++, p++) {
 		if ((p->mac_version == mac_version) && (p->clk == clk)) {
 			RTL_W32(0x7c, p->val);
 			break;
-- 
1.5.3.3

