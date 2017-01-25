From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: fix the wrong spelling
Date: Wed, 25 Jan 2017 13:41:45 +0800
Message-ID: <1394712342-15778-241-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace rumtime with runtime.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f3b48ad..d59d773 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3576,7 +3576,7 @@ static bool delay_autosuspend(struct r8152 *tp)
 		return false;
 }
 
-static int rtl8152_rumtime_suspend(struct r8152 *tp)
+static int rtl8152_runtime_suspend(struct r8152 *tp)
 {
 	struct net_device *netdev = tp->netdev;
 	int ret = 0;
@@ -3653,7 +3653,7 @@ static int rtl8152_suspend(struct usb_interface *intf, pm_message_t message)
 	mutex_lock(&tp->control);
 
 	if (PMSG_IS_AUTO(message))
-		ret = rtl8152_rumtime_suspend(tp);
+		ret = rtl8152_runtime_suspend(tp);
 	else
 		ret = rtl8152_system_suspend(tp);
 
-- 
2.7.4
