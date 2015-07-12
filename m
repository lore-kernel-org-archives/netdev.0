From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-07-12
Date: Sun, 12 Jul 2015 21:18:03 +0200
Message-ID: <1436728691-1145-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54985 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbbGLTSQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 15:18:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of 8 patchs for net/master.

Sergei Shtylyov contributes 5 patches for the rcar_can driver, fixing the IRQ
check and several info and error messages. There are two patches by J.D.
Schroeder and Roger Quadros for the c_can driver and dra7x-evm device tree,
which precent a glitch in the DCAN1 pinmux. Oliver Hartkopp provides a better
approach to make the CAN skbs unique, the timestamp is replaced by a counter.

regards,
Marc

---

The following changes since commit 2ee94014d9bd3868b1c0d17405f96d63bec83f28:

  net: switchdev: don't abort unsupported operations (2015-07-11 21:29:55 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.2-20150712

for you to fetch changes up to d3b58c47d330de8c29898fe9746f7530408f8a59:

  can: replace timestamp as unique skb attribute (2015-07-12 21:13:22 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.2-20150712

----------------------------------------------------------------
J.D. Schroeder (1):
      can: c_can: Fix default pinmux glitch at init

Oliver Hartkopp (1):
      can: replace timestamp as unique skb attribute

Roger Quadros (1):
      ARM: dts: dra7x-evm: Prevent glitch on DCAN1 pinmux

Sergei Shtylyov (5):
      can: rcar_can: fix IRQ check
      can: rcar_can: print signed IRQ #
      can: rcar_can: fix typo in error message
      can: rcar_can: print request_irq() error code
      can: rcar_can: unify error messages

 arch/arm/boot/dts/dra7-evm.dts  |  5 +++--
 arch/arm/boot/dts/dra72-evm.dts |  5 +++--
 drivers/net/can/c_can/c_can.c   | 10 ++++++++--
 drivers/net/can/dev.c           |  7 ++-----
 drivers/net/can/rcar_can.c      | 16 ++++++++++------
 drivers/net/can/slcan.c         |  2 +-
 drivers/net/can/vcan.c          |  3 ---
 include/linux/can/skb.h         |  2 ++
 net/can/af_can.c                | 12 +++++++-----
 net/can/bcm.c                   |  2 ++
 net/can/raw.c                   |  7 ++++---
 11 files changed, 42 insertions(+), 29 deletions(-)
