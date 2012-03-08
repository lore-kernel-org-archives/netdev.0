From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull request: linux-can-next 2012-03-08
Date: Thu,  8 Mar 2012 10:50:29 +0100
Message-ID: <1331200230-1118-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:45150 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751644Ab2CHJuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 04:50:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this patch is against net-next. It's a bugfix for the PCAN-USB driver
on big endian system.

Regards, Marc

---

The following changes since commit ae5d33723e325392c48bc0ff481d9ec8d646a0ed:

  powerpc/44x: Add more changes for APM821XX EMAC driver (2012-03-06 17:07:42 -0500)

are available in the git repository at:
  git@gitorious.org:linux-can/linux-can-next.git master

Stephane Grosjean (1):
      can: peak_usb: PCAN-USB specific part: fix little endian usage

 drivers/net/can/usb/peak_usb/pcan_usb.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)
