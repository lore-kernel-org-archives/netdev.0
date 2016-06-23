From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2016-06-23
Date: Thu, 23 Jun 2016 11:22:18 +0200
Message-ID: <1466673741-23115-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:33054 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185AbcFWJW1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 05:22:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request of 3 patches for the upcoming linux-4.7 release.

The first two patches are by Oliver Hartkopp fixing oopes in the generic CAN
device netlink handling. Jimmy Assarsson's patch for the kvaser_usb driver adds
support for more devices by adding their USB product ids.

regards,
Marc

---

The following changes since commit acd43fe85b2d1dbad55ce211b8817e6d6687246f:

  Merge branch 'mlx4-fixes' (2016-06-22 16:38:17 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.7-20160623

for you to fetch changes up to 71873a9b38d1cc6c93e2962149a7bb7272a7cb66:

  can: kvaser_usb: Add support for more Kvaser Leaf v2 devices (2016-06-23 11:16:41 +0200)

----------------------------------------------------------------
linux-can-fixes-for-4.7-20160623

----------------------------------------------------------------
Jimmy Assarsson (1):
      can: kvaser_usb: Add support for more Kvaser Leaf v2 devices

Oliver Hartkopp (2):
      can: fix handling of unmodifiable configuration options fix
      can: fix oops caused by wrong rtnl dellink usage

 drivers/net/can/dev.c            | 9 +++++++++
 drivers/net/can/usb/Kconfig      | 2 ++
 drivers/net/can/usb/kvaser_usb.c | 8 +++++++-
 3 files changed, 18 insertions(+), 1 deletion(-)
