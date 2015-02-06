From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/7] r8152: adjust the code
Date: Fri, 6 Feb 2015 11:30:44 +0800
Message-ID: <1394712342-15778-129-Taiwan-albertk@realtek.com>
References: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-118-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V2:
Correct the subject of patch #5. Replace "link feed" with "line feed".

v1:
Code adjustment.

Hayes Wang (7):
  r8152: adjust rx_bottom
  r8152: adjust lpm timer
  r8152: check linking status with netif_carrier_ok
  r8152: check RTL8152_UNPLUG for rtl8152_close
  r8152: adjust the line feed for hw_features
  r8152: replace get_protocol with vlan_get_protocol
  r8152: use BIT macro

 drivers/net/usb/r8152.c | 99 +++++++++++++++++++++++--------------------------
 1 file changed, 46 insertions(+), 53 deletions(-)

-- 
2.1.0
