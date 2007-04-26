From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 06/12] r8169: small 8101 comment
Date: Thu, 26 Apr 2007 23:48:37 +0200
Message-ID: <20070426214837.GG7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58574 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755173AbXDZVwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:52:06 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Extracted from version 1.001.00 of Realtek's r8101.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 1111ca4..adc4d3d 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1175,6 +1175,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp, void __iomem *io
 	 * if needed:
 	 *
 	 * (RTL_R32(TxConfig) & 0x700000) == 0x500000 ? 8168Bf : 8168Be
+	 *
+	 * Same thing for the 8101Eb and the 8101Ec:
+	 *
+	 * (RTL_R32(TxConfig) & 0x700000) == 0x200000 ? 8101Eb : 8101Ec
 	 */
 	const struct {
 		u32 mask;
-- 
1.4.4.2
