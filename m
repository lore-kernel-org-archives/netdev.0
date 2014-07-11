From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8169: support IPv6
Date: Fri, 11 Jul 2014 16:25:55 +0800
Message-ID: <1394712342-15778-10-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<nic_swsd@realtek.com>
To: <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The RTL8168C and the later chips support the hardware checksum
for IPv6. Adjust some code and add the relative code.

Hayes Wang (3):
  r8169: split rtl8169_tso_csum
  r8169: use Giant Send
  r8169: support IPv6

 drivers/net/ethernet/realtek/r8169.c | 220 ++++++++++++++++++++++++++++-------
 1 file changed, 181 insertions(+), 39 deletions(-)

-- 
1.9.3
