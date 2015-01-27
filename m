From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2015-01-27
Date: Tue, 27 Jan 2015 09:01:23 +0100
Message-ID: <1422345687-12839-1-git-send-email-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58330 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbbA0IBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:01:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this is another pull request for net/master which consists of 4 patches.

All 4 patches are contributed by Ahmed S. Darwish, he fixes more problems in
the kvaser_usb driver.

David, please merge net/master to net-next/master, as we have more kvaser_usb
patches in the queue, that target net-next.

regards,
Marc

The following changes since commit 600ddd6825543962fb807884169e57b580dba208:

  net: sctp: fix slab corruption from use after free on INIT collisions (2015-01-26 17:02:05 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mkl/linux-can.git tags/linux-can-fixes-for-3.19-20150127

for you to fetch changes up to e638642b08c170d2021b706f0b1c4f4ae93d8cbd:

  can: kvaser_usb: Fix state handling upon BUS_ERROR events (2015-01-27 08:55:09 +0100)

----------------------------------------------------------------
linux-can-fixes-for-3.19-20150127

----------------------------------------------------------------
Ahmed S. Darwish (4):
      can: kvaser_usb: Do not sleep in atomic context
      can: kvaser_usb: Send correct context to URB completion
      can: kvaser_usb: Retry the first bulk transfer on -ETIMEDOUT
      can: kvaser_usb: Fix state handling upon BUS_ERROR events

 drivers/net/can/usb/kvaser_usb.c | 28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)
