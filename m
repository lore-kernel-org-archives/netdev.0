From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 5/7] r8152: adjust the link feed for hw_features
Date: Mon, 19 Jan 2015 15:13:35 +0800
Message-ID: <1394712342-15778-123-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_TX at the
same line.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 9be642e..f66ffbd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3926,8 +3926,7 @@ static int rtl8152_probe(struct usb_interface *intf,
 	netdev->hw_features = NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_SG |
 			      NETIF_F_TSO | NETIF_F_FRAGLIST |
 			      NETIF_F_IPV6_CSUM | NETIF_F_TSO6 |
-			      NETIF_F_HW_VLAN_CTAG_RX |
-			      NETIF_F_HW_VLAN_CTAG_TX;
+			      NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_TX;
 	netdev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
 				NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
 				NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
-- 
2.1.0
