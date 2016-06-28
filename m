From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 0/7] r8152: support new chips
Date: Tue, 28 Jun 2016 20:28:35 +0800
Message-ID: <1394712342-15778-198-Taiwan-albertk@realtek.com>
References: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-184-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v3:
Insert a patch "r8152: add u2p3_enable for rtl_ops".

Change the patch "r8152: support RTL8153B". Disable U2P3.

v2:
Fix the commit message for patch #6.

v1:
In order to support new chips, adjust some codes. Then, add the settings
for the new chips.

Hayes Wang (7):
  r8152: add aldps_enable for rtl_ops
  r8152: add u1u2_enable for rtl_ops
  r8152: add power_cut_en for rtl_ops
  r8152: add u2p3_enable for rtl_ops
  r8152: support the new chip 8050
  r8152: support RTL8153B
  r8152: add byte_enable for ocp_read_word function

 drivers/net/usb/r8152.c | 641 ++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 592 insertions(+), 49 deletions(-)

-- 
2.4.11
