From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 10/12] r8152: reduce the numbers of the bulks
Date: Tue, 4 Mar 2014 20:01:02 +0800
Message-ID: <1393934464-23675-11-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:36563 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757270AbaCDMB7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2014 07:01:59 -0500
In-Reply-To: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce the numbers of tx and rx aggregation buffers.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 72cbab1..b60b3bc 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -416,8 +416,8 @@ enum rtl_register_content {
 	FULL_DUP	= 0x01,
 };
 
-#define RTL8152_MAX_TX		10
-#define RTL8152_MAX_RX		10
+#define RTL8152_MAX_TX		4
+#define RTL8152_MAX_RX		4
 #define INTBUFSIZE		2
 #define CRC_SIZE		4
 #define TX_ALIGN		4
-- 
1.8.4.2
