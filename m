From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 1/1] r8169: add missing MODULE_FIRMWARE.
Date: Tue, 26 Aug 2014 22:40:38 +0200
Message-ID: <20140826204038.GA15087@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Chun-Hao Lin <hau@realtek.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:39031 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbaHZUkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 16:40:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Leftover from 6e1d0b8988188956dac091441c1492a79a342666 ("r8169:add
support for RTL8168H and RTL8107E").

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Chun-Hao Lin <hau@realtek.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index c8375f6..02dd92a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -852,6 +852,8 @@ MODULE_FIRMWARE(FIRMWARE_8168G_2);
 MODULE_FIRMWARE(FIRMWARE_8168G_3);
 MODULE_FIRMWARE(FIRMWARE_8168H_1);
 MODULE_FIRMWARE(FIRMWARE_8168H_2);
+MODULE_FIRMWARE(FIRMWARE_8107E_1);
+MODULE_FIRMWARE(FIRMWARE_8107E_2);
 
 static void rtl_lock_work(struct rtl8169_private *tp)
 {
-- 
1.9.3
