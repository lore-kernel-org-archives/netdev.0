From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 1/3] r8152: replace some tabs with spaces
Date: Mon, 6 Jan 2014 17:08:41 +0800
Message-ID: <1388999323-9059-2-git-send-email-hayeswang@realtek.com>
References: <1388990366-8508-1-git-send-email-hayeswang@realtek.com>
 <1388999323-9059-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388999323-9059-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace the tabs of the variables declaration with the spaces.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 13fabbb..095f15b 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -584,8 +584,8 @@ int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 				void *data, u16 type)
 {
-	u16	limit = 64;
-	int	ret = 0;
+	u16 limit = 64;
+	int ret = 0;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
@@ -624,9 +624,9 @@ static int generic_ocp_read(struct r8152 *tp, u16 index, u16 size,
 static int generic_ocp_write(struct r8152 *tp, u16 index, u16 byteen,
 				u16 size, void *data, u16 type)
 {
-	int	ret;
-	u16	byteen_start, byteen_end, byen;
-	u16	limit = 512;
+	int ret;
+	u16 byteen_start, byteen_end, byen;
+	u16 limit = 512;
 
 	if (test_bit(RTL8152_UNPLUG, &tp->flags))
 		return -ENODEV;
@@ -1812,8 +1812,8 @@ static void r8152b_exit_oob(struct r8152 *tp)
 
 static void r8152b_enter_oob(struct r8152 *tp)
 {
-	u32	ocp_data;
-	int	i;
+	u32 ocp_data;
+	int i;
 
 	ocp_data = ocp_read_byte(tp, MCU_TYPE_PLA, PLA_OOB_CTRL);
 	ocp_data &= ~NOW_IS_OOB;
@@ -2340,7 +2340,7 @@ static void r8153_clear_bp(struct r8152 *tp)
 
 static void r8152b_enable_eee(struct r8152 *tp)
 {
-	u32	ocp_data;
+	u32 ocp_data;
 
 	ocp_data = ocp_read_word(tp, MCU_TYPE_PLA, PLA_EEE_CR);
 	ocp_data |= EEE_RX_EN | EEE_TX_EN;
-- 
1.8.4.2
