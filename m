From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v3 0/3] Code adjustment
Date: Wed, 12 Nov 2014 10:05:02 +0800
Message-ID: <1394712342-15778-91-Taiwan-albertk@realtek.com>
References: <1394712342-15778-79-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-79-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

v3:
 Remove the test_bit for patch #2.

v2:
 Correct the spelling error for the comment of patch #3.

v1:
Adjust some codes to make them more reasonable.

Hayes Wang (3):
  r8152: remove the duplicate init for the list of rx_done
  r8152: clear the flag of SCHEDULE_TASKLET in tasklet
  r8152: check RTL8152_UNPLUG and netif_running before autoresume

 drivers/net/usb/r8152.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

-- 
1.9.3
