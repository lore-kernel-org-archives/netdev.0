From: Wan ZongShun <mcuos.com@gmail.com>
Subject: [PATCH] ARM: fix bug of checking on signed return value using unsigned
 statement in w90p910 platform
Date: Wed, 11 Nov 2009 22:35:22 +0800
Message-ID: <4AFACBAA.1030503@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	linux-netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, roel.kluin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f221.google.com ([209.85.220.221]:46149 "EHLO
	mail-fx0-f221.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755837AbZKKOf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 09:35:27 -0500
Received: by fxm21 with SMTP id 21so1076113fxm.21
        for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 06:35:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear sir,

To fix the bug of checking on signed return value using unsigned statement.
Thanks Roel Kluin for digging out it. 

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
Signed-off-by: Wan ZongShun <mcuos.com@gmail.com>

---
 drivers/net/arm/w90p910_ether.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/arm/w90p910_ether.c b/drivers/net/arm/w90p910_ether.c
index 25e2627..b7f3866 100644
--- a/drivers/net/arm/w90p910_ether.c
+++ b/drivers/net/arm/w90p910_ether.c
@@ -160,8 +160,8 @@ struct  w90p910_ether {
 	struct mii_if_info mii;
 	struct timer_list check_timer;
 	void __iomem *reg;
-	unsigned int rxirq;
-	unsigned int txirq;
+	int rxirq;
+	int txirq;
 	unsigned int cur_tx;
 	unsigned int cur_rx;
 	unsigned int finish_tx;
-- 
1.5.6.3
