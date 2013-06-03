From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2013-06-03
Date: Mon,  3 Jun 2013 14:15:30 +0200
Message-ID: <1370261733-22935-1-git-send-email-mkl@pengutronix.de>
Cc: linux-can@vger.kernel.org, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

here are there fixes for the v3.10 release cycle:

The first patch by Jonas Peterson and Olivier Sobrie fixes the reception of CAN
frames on Kvaser's "USBcan Pro" and "USBcan R" type hardware.

The last two patches by Olivier Sobrie (for esd_usb2) and me (for peak_usb)
change the memory handling for the USB messages from stack to kmalloc(), as
memory used for DMA should not be allocated on stack.

regards,
Marc

---

The following changes since commit 01cb71d2d47b78354358e4bb938bb06323e17498:

  net_sched: restore "overhead xxx" handling (2013-06-02 22:22:35 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.10

for you to fetch changes up to f14e22435a27ef183bbfa78f77ad86644c0b354c:

  net: can: peak_usb: Do not do dma on the stack (2013-06-03 14:05:32 +0200)

----------------------------------------------------------------
Jonas Peterson (1):
      net: can: kvaser_usb: fix reception on "USBcan Pro" and "USBcan R" type hardware.

Marc Kleine-Budde (1):
      net: can: peak_usb: Do not do dma on the stack

Olivier Sobrie (1):
      net: can: esd_usb2: Do not do dma on the stack

 drivers/net/can/usb/esd_usb2.c              | 127 +++++++++++++++++-----------
 drivers/net/can/usb/kvaser_usb.c            |  64 +++++++++-----
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c |  61 ++++++++-----
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h |   1 +
 4 files changed, 160 insertions(+), 93 deletions(-)


