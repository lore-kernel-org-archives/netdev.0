From: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH net-next 3/4] r8152: remove clear_bp function
Date: Wed, 20 Aug 2014 16:58:38 +0800
Message-ID: <1394712342-15778-19-Taiwan-albertk@realtek.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1394712342-15778-16-Taiwan-albertk-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The functions are used to update the firmware. Move the actions into
the firmware files.

Signed-off-by: Hayes Wang <hayeswang-Rasf1IRRPZFBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/usb/r8152.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 33dcc97..937d132 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2189,28 +2189,6 @@ static void rtl_phy_reset(struct r8152 *tp)
 	}
 }
 
-static void rtl_clear_bp(struct r8152 *tp)
-{
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_0, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_2, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_4, 0);
-	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_BP_6, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_0, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_2, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_4, 0);
-	ocp_write_dword(tp, MCU_TYPE_USB, USB_BP_6, 0);
-	mdelay(3);
-	ocp_write_word(tp, MCU_TYPE_PLA, PLA_BP_BA, 0);
-	ocp_write_word(tp, MCU_TYPE_USB, USB_BP_BA, 0);
-}
-
-static void r8153_clear_bp(struct r8152 *tp)
-{
-	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_BP_EN, 0);
-	ocp_write_byte(tp, MCU_TYPE_USB, USB_BP_EN, 0);
-	rtl_clear_bp(tp);
-}
