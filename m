From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/6] support new chip
Date: Thu, 2 Jan 2014 11:22:38 +0800
Message-ID: <1388632963-1341-1-git-send-email-hayeswang@realtek.com>
References: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388111649-1014-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the trailing "/* CRC */" for patch #3.

Change the return value type of rtl_ops_init() from int to boolean
for patch #4.

Replace VENDOR_ID_SAMSUNG with SAMSUNG_VENDOR_ID for patch #6.

Hayes Wang (6):
  r8152: move rtl8152_unload and ocp_reg_write
  r8152: modify the method of accessing PHY
  r8152: change some definitions
  r8152: add rtl_ops
  r8152: split rtl8152_enable
  r8152: support RTL8153

 drivers/net/usb/cdc_ether.c |  10 +
 drivers/net/usb/r8152.c     | 813 +++++++++++++++++++++++++++++++++++++++-----
 drivers/net/usb/r815x.c     |   2 +-
 3 files changed, 742 insertions(+), 83 deletions(-)

-- 
1.8.3.1
