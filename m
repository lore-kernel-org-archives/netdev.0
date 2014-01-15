From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next v2 0/3] r8152: remove limitation
Date: Wed, 15 Jan 2014 10:42:13 +0800
Message-ID: <1389753736-2218-1-git-send-email-hayeswang@realtek.com>
References: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389250232-8663-1-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove the limitation between ecm mode and vendor mode.

v2: replace the patch #3 with "ecm and vendor modes coexist".

Hayes Wang (3):
  r8152: change the descriptor
  r8152: fix the warnings and a error from checkpatch.pl
  r8152: ecm and vendor modes coexist

 drivers/net/usb/Kconfig     |  5 ++--
 drivers/net/usb/cdc_ether.c |  9 -------
 drivers/net/usb/r8152.c     | 62 ++++++++++++++++++---------------------------
 drivers/net/usb/r815x.c     |  8 ------
 4 files changed, 27 insertions(+), 57 deletions(-)

-- 
1.8.4.2
