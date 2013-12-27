From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/6] Support new chip
Date: Fri, 27 Dec 2013 10:34:04 +0800
Message-ID: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust the code to make it easy to add the settings for the new chip.
Then, add the relative parameters of the RTL8153.

Hayes Wang (6):
  r8152: move rtl8152_unload and ocp_reg_write
  r8152: modify the method of accessing PHY
  r8152: change some definitions
  r8152: add rtl_ops
  r8152: split rtl8152_enable
  r8152: support RTL8153

 drivers/net/usb/cdc_ether.c |  10 +
 drivers/net/usb/r8152.c     | 812 +++++++++++++++++++++++++++++++++++++++-----
 drivers/net/usb/r815x.c     |   2 +-
 3 files changed, 741 insertions(+), 83 deletions(-)

-- 
1.8.3.1
