From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next] r8152: fix the wrong return value
Date: Fri, 3 Jan 2014 11:21:56 +0800
Message-ID: <1388719316-5702-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The return value should be the boolean value, not the error code.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
Spotted-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 drivers/net/usb/r8152.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e3d878c..13fabbb 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2708,7 +2708,7 @@ static bool rtl_ops_init(struct r8152 *tp, const struct usb_device_id *id)
 			ops->unload		= rtl8153_unload;
 			break;
 		default:
-			ret = -EFAULT;
+			ret = false;
 			break;
 		}
 		break;
-- 
1.8.4.2
