From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH net-next 0/3] can: mscan-mpc5xxx: add support for the Freescale MPC512x
Date: Sat,  2 Jan 2010 09:17:51 +0100
Message-ID: <1262420274-16586-1-git-send-email-wg@grandegger.com>
Cc: Socketcan-core@lists.berlios.de, Linuxppc-dev@lists.ozlabs.org,
	Devicetree-discuss@lists.ozlabs.org,
	Wolfram Sang <w.sang@pengutronix.de>,
	Wolfgang Grandegger <wg@grandegger.com>
To: Netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for the MPC512x from Freescale to
the mpc5xxx_can MSCAN driver.

Wolfgang

Wolfgang Grandegger (3):
  can: mscan: fix improper return if dlc < 8 in start_xmit function
  can: mscan-mpc5xxx: add support for the MPC521x processor
  powerpc/mpc5xxx: add OF platform binding doc for FSL MSCAN devices

 Documentation/powerpc/dts-bindings/fsl/can.txt     |   53 +++++
 Documentation/powerpc/dts-bindings/fsl/mpc5200.txt |    9 +-
 drivers/net/can/mscan/Kconfig                      |    2 +-
 drivers/net/can/mscan/mpc5xxx_can.c                |  234 ++++++++++++++++----
 drivers/net/can/mscan/mscan.c                      |   52 ++++-
 drivers/net/can/mscan/mscan.h                      |   81 ++++----
 6 files changed, 333 insertions(+), 98 deletions(-)
 create mode 100644 Documentation/powerpc/dts-bindings/fsl/can.txt

