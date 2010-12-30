From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [PATCH 02/15]drivers:spi:dw_spi.c Typo change diable to disable.
Date: Thu, 30 Dec 2010 15:07:51 -0800
Message-ID: <1293750484-1161-2-git-send-email-justinmattock@gmail.com>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
Cc: linux-m68k@lists.linux-m68k.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, ivtv-devel@ivtvdriver.org,
	linux-media@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-scsi@vger.kernel.org,
	spi-devel-general@lists.sourceforge.net,
	devel@driverdev.osuosl.org, linux-usb@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>
To: trivial@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:59254 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967Ab0L3XIJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 18:08:09 -0500
In-Reply-To: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The below patch fixes a typo "diable" to "disable". Please let me know if this 
is correct or not.

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>

---
 drivers/spi/dw_spi.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/spi/dw_spi.c b/drivers/spi/dw_spi.c
index 0838c79..7c3cf21 100644
--- a/drivers/spi/dw_spi.c
+++ b/drivers/spi/dw_spi.c
@@ -592,7 +592,7 @@ static void pump_transfers(unsigned long data)
 		spi_set_clk(dws, clk_div ? clk_div : chip->clk_div);
 		spi_chip_sel(dws, spi->chip_select);
 
-		/* Set the interrupt mask, for poll mode just diable all int */
+		/* Set the interrupt mask, for poll mode just disable all int */
 		spi_mask_intr(dws, 0xff);
 		if (imask)
 			spi_umask_intr(dws, imask);
-- 
1.6.5.2.180.gc5b3e

