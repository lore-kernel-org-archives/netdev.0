From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/2] r8152: adjust r8152_submit_rx
Date: Mon, 22 Dec 2014 14:52:54 +0800
Message-ID: <1394712342-15778-110-Taiwan-albertk@realtek.com>
References: <1394712342-15778-107-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-107-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v2:
Replace the patch #1 with "call rtl_start_rx after netif_carrier_on".

For patch #2, replace checking tp->speed with netif_carrier_ok.

v1:
Avoid r8152_submit_rx() from submitting rx during unexpected
moment. This could reduce the time of stopping rx.

For patch #1, the tp->speed should be updated early. Then,
the patch #2 could use it to check the current linking status.

Hayes Wang (2):
  r8152: call rtl_start_rx after netif_carrier_on
  r8152: check the status before submitting rx

 drivers/net/usb/r8152.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

-- 
2.1.0
