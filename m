From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] Code adjustment
Date: Fri, 31 Oct 2014 14:03:53 +0800
Message-ID: <1394712342-15778-75-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust some codes to make them more reasonable.

Hayes Wang (3):
  r8152: remove the duplicate the init for the list of rx_done
  r8152: clear the flag of SCHEDULE_TASKLET in tasklet
  r8152: check RTL8152_UNPLUG and netif_running before autoresume

 drivers/net/usb/r8152.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

-- 
1.9.3
