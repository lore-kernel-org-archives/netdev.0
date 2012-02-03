From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 0/9] can: driver updates
Date: Fri,  3 Feb 2012 01:51:49 +0100
Message-ID: <1328230318-8962-1-git-send-email-mkl@pengutronix.de>
Cc: Netdev@vger.kernel.org, kernel@pengutronix.de, mkl@blackshift.org,
	linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this patch series targets net-next. It consists of various driver updates:
- plx_pci: add IXXAT PCI card
- flexcan: fixes CAN specific loopback handling
- pch_can: updates to copyright and Kconfig desciption
- ems_usb: improve memory handling
- add missing do_get_berr_counter to drivers
- replace the dev_dbg/info/err/... with the new netdev_xxx

The last patch (replace the dev_dbg/info/err) depends on a patch I requested
to go into 3.3 (f84cbda can: ems_usb: Removed double netif_device_detach).
In order to avoid merge conflicts I added this patch to this series, too.
If this is a bad idea we can postpone this pull request until you merged
the net/master branch and I'll respin the pull request without that patch.

regards,
Marc

---

The following changes since commit e1f4c485cdb2b1d7aae172b731f6c2b403381ebb:

  eicon: fix -Warray-bounds warning (2012-02-02 16:47:41 -0500)

are available in the git repository at:
  git://gitorious.org/linux-can/linux-can-next.git master

James Kime (1):
      can: plx_pci: add support for IXXAT PCI cards

Marc Kleine-Budde (1):
      can: dev: let can_get_echo_skb() return dlc of CAN frame

Reuben Dowle (1):
      can: flexcan: Fix CAN_RAW_RECV_OWN_MSGS and CAN_RAW_LOOPBACK

Sebastian Haas (2):
      can: ems_usb: Removed double netif_device_detach
      can: ems_usb: Improved memory handling on ems_usb_start

Tomoya MORINAGA (2):
      can: pch_can: Change company name OKI SEMICONDUCTOR to LAPIS Semiconductor
      can: Kconfig: add more information about Intel EG20T PCH CAN controller

Wolfgang Grandegger (2):
      can: bfin_can/ti_hecc/mscan: add missing do_get_berr_counter callback
      can: replace the dev_dbg/info/err/... with the new netdev_xxx macros

 drivers/net/can/Kconfig           |    6 ++--
 drivers/net/can/bfin_can.c        |   36 ++++++++++++-------
 drivers/net/can/dev.c             |   33 ++++++++++-------
 drivers/net/can/flexcan.c         |   61 ++++++++++++++-----------------
 drivers/net/can/mcp251x.c         |    3 +-
 drivers/net/can/mscan/mscan.c     |   33 ++++++++++++-----
 drivers/net/can/pch_can.c         |    2 +-
 drivers/net/can/sja1000/Kconfig   |    1 +
 drivers/net/can/sja1000/plx_pci.c |   22 +++++++++++-
 drivers/net/can/sja1000/sja1000.c |   19 +++++-----
 drivers/net/can/ti_hecc.c         |   32 +++++++++++-----
 drivers/net/can/usb/ems_usb.c     |   72 ++++++++++++++-----------------------
 drivers/net/can/usb/esd_usb2.c    |   27 ++++++--------
 include/linux/can/dev.h           |    2 +-
 14 files changed, 192 insertions(+), 157 deletions(-)


