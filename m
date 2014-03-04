From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 00/12] r8152: new features
Date: Tue, 4 Mar 2014 20:00:52 +0800
Message-ID: <1393934464-23675-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Besides the adjustment of the code, support rx checksum,
TCP large send, and IPv6.

Hayes Wang (12):
  r8152: deal with the empty line and space
  r8152: replace tp->netdev with netdev
  r8152: remove rtl8152_get_stats
  r8152: replace spin_lock_irqsave and spin_unlock_irqrestore
  r8152: check tx agg list before spin lock
  r8152: up the priority of the transmission
  r8152: support rx checksum
  r8152: support TSO
  r8152: support IPv6
  r8152: reduce the numbers of the bulks
  r8152: add additional parameter for non x86 platform
  r8152: modify the tx timeout funcfion

 drivers/net/usb/r8152.c | 436 +++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 343 insertions(+), 93 deletions(-)

-- 
1.8.4.2
