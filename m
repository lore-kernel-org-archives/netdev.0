From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-03-09
Date: Mon,  9 Mar 2015 10:36:15 +0100
Message-ID: <1425893781-10867-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:50303 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbCIJg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2015 05:36:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is a pull request for net/master for the 4.0 release cycle, it consists of
6 patches:

A patch by Oliver Hartkopp fixes a long outstanding bug in the infrastructure,
which leads to skb_under_panics when CAN interfaces are used by AF_PACKET
sockets e.g. by dhclient. Stephane Grosjean contributes a patch for the
peak_usb driver which adds a missing initialization. Two patches by Ahmed S.
Darwish fix problems in the kvaser_usb driver. Followed by two patches by
myself, updating the MAINTAINERS file.

regards,
Marc
---

The following changes since commit c247f0534cc5a5a547a343903f42295a471844e2:

  ip: fix error queue empty skb handling (2015-03-08 23:01:54 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-4.0-20150309

for you to fetch changes up to ee2daa00fbe62a491446d3385542d43be233d81c:

  MAINTAINERS: add Marc Kleine-Budde as co maintinaer for CAN networking layer (2015-03-09 10:22:45 +0100)

----------------------------------------------------------------
linux-can-fixes-for-4.0-20150309

----------------------------------------------------------------
Ahmed S. Darwish (2):
      can: kvaser_usb: Avoid double free on URB submission failures
      can: kvaser_usb: Read all messages in a bulk-in URB buffer

Marc Kleine-Budde (2):
      MAINTAINERS: linux-can moved to github
      MAINTAINERS: add Marc Kleine-Budde as co maintinaer for CAN networking layer

Oliver Hartkopp (1):
      can: add missing initialisations in CAN related skbuffs

Stephane Grosjean (1):
      can: peak_usb: fix missing ctrlmode_ init for every dev

 MAINTAINERS                                |  5 ++--
 drivers/net/can/dev.c                      |  8 +++++
 drivers/net/can/usb/kvaser_usb.c           | 48 +++++++++++++++++++-----------
 drivers/net/can/usb/peak_usb/pcan_usb_fd.c |  4 +++
 net/can/af_can.c                           |  3 ++
 5 files changed, 49 insertions(+), 19 deletions(-)
