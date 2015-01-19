From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 0/2] r8152: couldn't read OCP_SRAM_DATA
Date: Mon, 19 Jan 2015 17:02:44 +0800
Message-ID: <1394712342-15778-126-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Read OCP_SRAM_DATA would read additional bytes and may let
the hw abnormal.

Hayes Wang (2):
  r8152: remove generic_ocp_read before writing
  r8152: remove sram_read

 drivers/net/usb/r8152.c | 30 ++++++------------------------
 1 file changed, 6 insertions(+), 24 deletions(-)

-- 
2.1.0
