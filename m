From: Chunhao Lin <hau@realtek.com>
Subject: [PATCH net 0/3] r8169:issues fix.
Date: Fri, 26 Feb 2016 16:40:43 +0800
Message-ID: <1456476046-5436-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	Chunhao Lin <hau@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series of patches fix 3 issues that are listed below.

Chunhao Lin (3):
  r8169:fix nic sometimes doesn't work after changing the mac address.
  r8169:eliminate error message in using ethtool -S when nic is down.
  r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_41~48

 drivers/net/ethernet/realtek/r8169.c | 22 ++++++++++++++++------
 1 file changed, 16 insertions(+), 6 deletions(-)

-- 
1.9.1
