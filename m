From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/5] r8152: correct the flow of PHY
Date: Tue, 20 Sep 2016 16:22:04 +0800
Message-ID: <1394712342-15778-219-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First, to enable the PHY as early as possible. Some settings may fail if the
PHY is power down.

Move the other PHY settings to hw_phy_cfg() to make sure the order is correct.

Finally, disable ALDPS and EEE before updating the PHY for RTL8153.

Hayes Wang (5):
  r8152: move some functions
  r8152: move enabling PHY
  r8152: move PHY settings to hw_phy_cfg
  r8152: remove r8153_enable_eee
  r8152: disable ALDPS and EEE before setting PHY

 drivers/net/usb/r8152.c | 281 +++++++++++++++++++++++++-----------------------
 1 file changed, 146 insertions(+), 135 deletions(-)

-- 
2.7.4
