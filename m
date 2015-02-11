From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] Adjust the settings about USB_RX_EARLY_AGG
Date: Wed, 11 Feb 2015 14:46:56 +0800
Message-ID: <1394712342-15778-137-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The USB_RX_EARLY_AGG contains timeout and size. Separate them, and
they could be set independently. Then, the ethtool could be used to
change the timeout according to situation of the platform.

Hayes Wang (3):
  r8152: separate USB_RX_EARLY_AGG
  r8152: change rx early size when the mtu is changed
  r8152: support setting rx coalesce

 drivers/net/usb/r8152.c | 128 ++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 101 insertions(+), 27 deletions(-)

-- 
2.1.0
