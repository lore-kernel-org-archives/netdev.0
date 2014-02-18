From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 00/14] r8152: improvement and new features
Date: Tue, 18 Feb 2014 21:48:57 +0800
Message-ID: <1392731351-25502-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change some flows or behavior to improve the efficiency or make the
code readable. Besides, support WOL and runtime suspend.

Hayes Wang (14):
  r8152: move some functions
  r8152: add three functions
  r8152: replace some types from int to bool
  r8152: load the default MAC address
  r8152: reduce the frequency of spin_lock
  r8152: clear BMCR_PDOWN
  r8152: combine PHY reset with set_speed
  r8152: move some functions from probe to open
  r8152: support WOL
  r8152: support runtime suspend
  r8152: disable teredo for RTL8152
  r8152: replace netif_rx with netif_receive_skb
  r8152: set disable_hub_initiated_lpm
  r8152: support get_msglevel and set_msglevel

 drivers/net/usb/r8152.c | 711 +++++++++++++++++++++++++++++++++++-------------
 1 file changed, 526 insertions(+), 185 deletions(-)

-- 
1.8.4.2
