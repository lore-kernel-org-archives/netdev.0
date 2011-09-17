From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2/5] r8169: add MODULE_FIRMWARE for the firmware of 8111evl
Date: Sat, 17 Sep 2011 11:57:51 +0200
Message-ID: <20110917095751.GC21630@electric-eye.fr.zoreil.com>
References: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Hayes Wang <hayeswang@realtek.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54286 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832Ab1IQJ63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2011 05:58:29 -0400
Content-Disposition: inline
In-Reply-To: <20110917095617.GA21630@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MODULE_FIRMWARE for the firmware of RTL8111E-VL

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/r8169.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a1c9070..b55fba7 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -710,6 +710,7 @@ MODULE_FIRMWARE(FIRMWARE_8168D_1);
 MODULE_FIRMWARE(FIRMWARE_8168D_2);
 MODULE_FIRMWARE(FIRMWARE_8168E_1);
 MODULE_FIRMWARE(FIRMWARE_8168E_2);
+MODULE_FIRMWARE(FIRMWARE_8168E_3);
 MODULE_FIRMWARE(FIRMWARE_8105E_1);
 
 static int rtl8169_open(struct net_device *dev);
-- 
1.7.6
