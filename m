From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/2] r8152: random MAC address
Date: Wed, 3 Sep 2014 10:59:13 +0800
Message-ID: <1394712342-15778-29-Taiwan-albertk@realtek.com>
References: <1394712342-15778-26-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-26-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If the interface has invalid MAC address, it couldn't
be used. In order to let it work normally, give a
random one.

v2:
  Use "%pM" format specifier for printing a MAC address.

Hayes Wang (2):
  r8152: change the location of rtl8152_set_mac_address
  r8152: use eth_hw_addr_random

 drivers/net/usb/r8152.c | 65 ++++++++++++++++++++++++++++---------------------
 1 file changed, 37 insertions(+), 28 deletions(-)

-- 
1.9.3
