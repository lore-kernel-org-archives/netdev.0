From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 0/3] r8152: behavior modification
Date: Thu, 9 Jan 2014 14:50:29 +0800
Message-ID: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The purpose is to add a choice for determining whether add the
limitation between r8152 and ecm drivers or not.

Hayes Wang (3):
  r8152: change the descriptor
  r8152: fix the warnings and a error from checkpatch.pl
  r8152: add supporting the vendor mode only

 drivers/net/usb/Kconfig     | 14 ++++++++--
 drivers/net/usb/cdc_ether.c |  2 +-
 drivers/net/usb/r8152.c     | 62 ++++++++++++++++++++++-----------------------
 drivers/net/usb/r815x.c     |  4 +--
 4 files changed, 45 insertions(+), 37 deletions(-)

-- 
1.8.4.2
