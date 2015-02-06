From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 5/7] r8152: adjust the line feed for hw_features
Date: Fri, 6 Feb 2015 11:30:49 +0800
Message-ID: <1394712342-15778-134-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
 <1394712342-15778-129-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:60457 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754253AbbBFDbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 22:31:51 -0500
In-Reply-To: <1394712342-15778-129-Taiwan-albertk@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep NETIF_F_HW_VLAN_CTAG_RX and NETIF_F_HW_VLAN_CTAG_TX at the
same line.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index aade7b5..8bdd477 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -3908,8 +3908,7 @@ static int rtl8152_probe(struct usb_interface *intf,
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
