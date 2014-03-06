From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 1/3] r8152: deal with the empty line and space
Date: Thu, 6 Mar 2014 15:07:16 +0800
Message-ID: <1394089638-1580-2-git-send-email-hayeswang@realtek.com>
References: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
 <1394089638-1580-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394089638-1580-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add or remove some empty lines. Replace the spaces with the tabs.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0654bd3..c8bad62 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -593,6 +593,7 @@ int set_registers(struct r8152 *tp, u16 value, u16 index, u16 size, void *data)
 			       value, index, tmp, size, 500);
 
 	kfree(tmp);
+
 	return ret;
 }
 
@@ -1514,6 +1515,7 @@ static void tx_bottom(struct r8152 *tp)
 				netif_warn(tp, tx_err, netdev,
 					   "failed tx_urb %d\n", res);
 				stats->tx_dropped += agg->skb_num;
+
 				spin_lock_irqsave(&tp->tx_lock, flags);
 				list_add_tail(&agg->list, &tp->tx_free);
 				spin_unlock_irqrestore(&tp->tx_lock, flags);
@@ -1833,7 +1835,6 @@ static void r8152_power_cut_en(struct r8152 *tp, bool enable)
 	ocp_data = ocp_read_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS);
 	ocp_data &= ~RESUME_INDICATE;
 	ocp_write_word(tp, MCU_TYPE_USB, USB_PM_CTRL_STATUS, ocp_data);
-
 }
 
 #define WAKE_ANY (WAKE_PHY | WAKE_MAGIC | WAKE_UCAST | WAKE_BCAST | WAKE_MCAST)
@@ -2013,8 +2014,8 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 
 static void r8152b_exit_oob(struct r8152 *tp)
 {
-	u32	ocp_data;
-	int	i;
+	u32 ocp_data;
+	int i;
 
 	ocp_data = ocp_read_dword(tp, MCU_TYPE_PLA, PLA_RCR);
 	ocp_data &= ~RCR_ACPT_ALL;
@@ -2573,6 +2574,7 @@ static int rtl8152_open(struct net_device *netdev)
 	netif_carrier_off(netdev);
 	netif_start_queue(netdev);
 	set_bit(WORK_ENABLE, &tp->flags);
+
 	res = usb_submit_urb(tp->intr_urb, GFP_KERNEL);
 	if (res) {
 		if (res == -ENODEV)
@@ -3101,6 +3103,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 
 	netdev->features |= NETIF_F_IP_CSUM;
 	netdev->hw_features = NETIF_F_IP_CSUM;
+
 	SET_ETHTOOL_OPS(netdev, &ops);
 
 	tp->mii.dev = netdev;
-- 
1.8.4.2
