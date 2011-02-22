From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH] ax88796: depend on HAS_IOMEM not on individual ARCHs
Date: Tue, 22 Feb 2011 21:19:58 +0100
Message-ID: <1298405998-6214-1-git-send-email-mkl@pengutronix.de>
References: <20110222.111856.102538007.davem@davemloft.net>
Cc: davem@davemloft.net, Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46124 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752158Ab1BVUUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 15:20:01 -0500
In-Reply-To: <20110222.111856.102538007.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: David Miller <davem@davemloft.net>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---

Hello David,

this patch is available in the git repository at:
  git://git.pengutronix.de/git/mkl/linux-2.6.git net/ax88796

based on the patches already merged into net-next.

regards, Marc

 drivers/net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f4b3927..5d7d9e7 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -237,7 +237,7 @@ source "drivers/net/arm/Kconfig"
 
 config AX88796
 	tristate "ASIX AX88796 NE2000 clone support"
-	depends on ARM || MIPS || SUPERH
+	depends on HAS_IOMEM
 	select PHYLIB
 	select MDIO_BITBANG
 	help
-- 
1.7.2.3

