From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/2] r8152: use ECM mode for future chips
Date: Mon, 24 Nov 2014 11:09:47 +0800
Message-ID: <1394712342-15778-101-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For the future chips which the r8152 doesn't support yet, we could
still use ECM mode for basic transmission.

Hayes Wang (2):
  r8152: redefine REALTEK_USB_DEVICE
  r8152: use ECM mode for unsupported chips

 drivers/net/usb/r8152.c | 118 +++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 107 insertions(+), 11 deletions(-)

-- 
1.9.3
