From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 13/14] r8152: set disable_hub_initiated_lpm
Date: Tue, 18 Feb 2014 21:49:10 +0800
Message-ID: <1392731351-25502-14-git-send-email-hayeswang@realtek.com>
References: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set disable_hub_initiated_lpm = 1.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ff02d5d..db98842 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3159,6 +3159,7 @@ static struct usb_driver rtl8152_driver = {
 	.resume =	rtl8152_resume,
 	.reset_resume =	rtl8152_resume,
 	.supports_autosuspend = 1,
+	.disable_hub_initiated_lpm = 1,
 };
 
 module_usb_driver(rtl8152_driver);
-- 
1.8.4.2
