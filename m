From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: random MAC address
Date: Tue, 2 Sep 2014 17:55:09 +0800
Message-ID: <1394712342-15778-26-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the interface has invalid MAC address, it couldn't
be used. In order to let it work normally, give a
random one.

Hayes Wang (2):
  r8152: change the location of rtl8152_set_mac_address
  r8152: use eth_hw_addr_random

 drivers/net/usb/r8152.c | 65 ++++++++++++++++++++++++++++---------------------
 1 file changed, 37 insertions(+), 28 deletions(-)

-- 
1.9.3
