From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-01-15
Date: Thu, 15 Jan 2015 17:11:15 +0100
Message-ID: <1421338283-12417-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56590 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbAOQLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 11:11:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of 8 patches.

Ahmed S. Darwish contributes 4 fixes for the kvaser_usb driver. The two patches
by Oliver Hartkopp mark the m_can driver as non-ISO, as the CANFD standard was
updated. Roger Quadros's patch for the c_can driver fixes the register access
during RAMINIT. And one patch by my, which updates the MAINTAINERS file, as we
moved the git repos to the kernel.org infrastructure.

regards,
Marc

---

The following changes since commit 16dde0d6ac159531a5e03cd3f8bc8a401d9f3fb6:

  be2net: Allow GRE to work concurrently while a VxLAN tunnel is configured (2015-01-15 01:55:05 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-3.19-20150115

for you to fetch changes up to a58518ccf39f86f898a65201518dd8e799b3abeb:

  can: kvaser_usb: Don't dereference skb after a netif_rx() (2015-01-15 16:58:02 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.19-20150115

----------------------------------------------------------------
Ahmed S. Darwish (4):
      can: kvaser_usb: Don't free packets when tight on URBs
      can: kvaser_usb: Reset all URB tx contexts upon channel close
      can: kvaser_usb: Don't send a RESET_CHIP for non-existing channels
      can: kvaser_usb: Don't dereference skb after a netif_rx()

Marc Kleine-Budde (1):
      MAINTAINERS: update linux-can git repositories

Oliver Hartkopp (2):
      can: dev: fix crtlmode_supported check
      can: m_can: tag current CAN FD controllers as non-ISO

Roger Quadros (1):
      can: c_can: use regmap_update_bits() to modify RAMINIT register

 MAINTAINERS                            |  6 ++++--
 drivers/net/can/c_can/c_can_platform.c | 29 ++++++++++++++++++-----------
 drivers/net/can/dev.c                  |  8 ++++++--
 drivers/net/can/m_can/m_can.c          |  5 +++++
 drivers/net/can/usb/kvaser_usb.c       | 31 +++++++++++++++----------------
 include/uapi/linux/can/netlink.h       |  1 +
 6 files changed, 49 insertions(+), 31 deletions(-)
