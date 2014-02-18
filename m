From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 11/14] r8152: disable teredo for RTL8152
Date: Tue, 18 Feb 2014 21:49:08 +0800
Message-ID: <1392731351-25502-12-git-send-email-hayeswang@realtek.com>
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

Disable teredo for RTL8152 by default.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f303549..3ff11ed 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2021,6 +2021,7 @@ static void r8152b_exit_oob(struct r8152 *tp)
 	ocp_write_dword(tp, MCU_TYPE_PLA, PLA_RCR, ocp_data);
 
 	rxdy_gated_en(tp, true);
+	r8153_teredo_off(tp);
 	r8152b_hw_phy_cfg(tp);
 
 	ocp_write_byte(tp, MCU_TYPE_PLA, PLA_CRWECR, CRWECR_NORAML);
-- 
1.8.4.2
