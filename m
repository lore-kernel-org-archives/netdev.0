From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 12/13] r8169: update the phy init for the 8168C
Date: Thu, 18 Oct 2007 23:02:14 +0200
Message-ID: <20071018210214.GM31724@electric-eye.fr.zoreil.com>
References: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36950 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753698AbXJRVHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 17:07:32 -0400
Content-Disposition: inline
In-Reply-To: <20071018204846.GC8594@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The values have been updated between version 8.002.00 and version
8.003.00 of Realtek's r8168 driver. This modification syncs the
8168C with version 8.003.00.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3680ee7..8ffd573 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1260,6 +1260,8 @@ static void rtl8168cp_hw_phy_config(void __iomem *ioaddr)
 static void rtl8168c_hw_phy_config(void __iomem *ioaddr)
 {
 	struct phy_reg phy_reg_init[] = {
+		{ 0x1f, 0x0001 },
+		{ 0x12, 0x2300 },
 		{ 0x1f, 0x0002 },
 		{ 0x00, 0x88d4 },
 		{ 0x01, 0x82b1 },
-- 
1.5.2.4

