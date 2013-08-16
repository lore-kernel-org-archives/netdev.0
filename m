From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 7/7] r8152: add comments
Date: Fri, 16 Aug 2013 16:09:38 +0800
Message-ID: <1376640578-4258-7-git-send-email-hayeswang@realtek.com>
References: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376640578-4258-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add comments.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 825edfe..f3fce41 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -790,6 +790,9 @@ static void read_bulk_callback(struct urb *urb)
 		return;
 
 	netdev = tp->netdev;
+
+	/* When link down, the driver would cancel all bulks. */
+	/* This avoid the re-submitting bulk */
 	if (!netif_carrier_ok(netdev))
 		return;
 
@@ -1296,6 +1299,8 @@ static void bottom_half(unsigned long data)
 	if (!test_bit(WORK_ENABLE, &tp->flags))
 		return;
 
+	/* When link down, the driver would cancel all bulks. */
+	/* This avoid the re-submitting bulk */
 	if (!netif_carrier_ok(tp->netdev))
 		return;
 
-- 
1.8.3.1
