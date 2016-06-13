From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8152: code adjustment for PHY
Date: Mon, 13 Jun 2016 17:49:35 +0800
Message-ID: <1394712342-15778-175-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches are for adjusting the code about PHY and setting speed.

Hayes Wang (3):
  r8152: move the settings of PHY to a work queue
  r8152: move the setting for the default speed
  r8152: save the speed

 drivers/net/usb/r8152.c | 53 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 12 deletions(-)

-- 
2.4.11
