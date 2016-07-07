From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8152: remove the redundant code
Date: Thu, 7 Jul 2016 15:09:17 +0800
Message-ID: <1394712342-15778-210-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the unnacessary code.

Hayes Wang (3):
  r8152: remove rtl_phy_reset function
  r8152: remove a netif_carrier_off in rtl8152_open function
  r8152: remove cancel_delayed_work_sync in rtl8152_set_speed

 drivers/net/usb/r8152.c | 27 ---------------------------
 1 file changed, 27 deletions(-)

-- 
2.7.4
