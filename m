From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-07-15
Date: Wed, 15 Jul 2015 09:09:37 +0200
Message-ID: <1436944189-26618-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

this is a pull request of 12 patches by me.

This series fixes the use of the skb after netif_receive_skb() / netif_rx()
which exists in several drivers.

Marc

---

The following changes since commit 50c2e4dd6749725338621fff456b26d3a592259f:

  net/xen-netback: off by one in BUG_ON() condition (2015-07-14 15:40:52 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.2-20150715

for you to fetch changes up to 1c0ee046957648106b415df79038e4e62b144c19:

  can: pcan_usb: don't touch skb after netif_rx() (2015-07-15 09:04:28 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.2-20150715

----------------------------------------------------------------
Marc Kleine-Budde (12):
      can: at91_can: don't touch skb after netif_receive_skb()/netif_rx()
      can: flexcan: don't touch skb after netif_receive_skb()
      can: bfin_can: don't touch skb after netif_rx()
      can: grcan: don't touch skb after netif_rx()
      can: slcan: don't touch skb after netif_rx_ni()
      can: ti_heccn: don't touch skb after netif_rx()
      can: cc770: don't touch skb after netif_rx()
      can: sja1000: don't touch skb after netif_rx()
      can: esd_usb2: don't touch skb after netif_rx()
      can: ems_usb: don't touch skb after netif_rx()
      can: usb_8dev: don't touch skb after netif_rx()
      can: pcan_usb: don't touch skb after netif_rx()

 drivers/net/can/at91_can.c                  | 8 ++++----
 drivers/net/can/bfin_can.c                  | 6 ++----
 drivers/net/can/cc770/cc770.c               | 4 ++--
 drivers/net/can/flexcan.c                   | 7 +++----
 drivers/net/can/grcan.c                     | 3 ++-
 drivers/net/can/sja1000/sja1000.c           | 6 ++----
 drivers/net/can/slcan.c                     | 2 +-
 drivers/net/can/ti_hecc.c                   | 2 +-
 drivers/net/can/usb/ems_usb.c               | 6 ++----
 drivers/net/can/usb/esd_usb2.c              | 6 ++----
 drivers/net/can/usb/peak_usb/pcan_usb.c     | 7 +++----
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c | 4 ++--
 drivers/net/can/usb/usb_8dev.c              | 6 ++----
 13 files changed, 28 insertions(+), 39 deletions(-)

