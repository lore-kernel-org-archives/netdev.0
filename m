From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 0/3] r8169:fix 3 runtime pm related issues.
Date: Thu, 28 Jul 2016 00:41:05 +0800
Message-ID: <1469637668-8751-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches fix 3 runtime pm related issues that are listed below.

Chunhao Lin (3):
  r8169:fix kernel log spam when set or get hardware wol setting.
  r8169:add checking driver's runtime pm status in rtl8169_get_ethtool_stats()
  r8169:fix nic may not work after changing the mac address.

 drivers/net/ethernet/realtek/r8169.c | 37 ++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

-- 
1.9.1
