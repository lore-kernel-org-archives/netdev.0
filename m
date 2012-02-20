From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-02-20
Date: Mon, 20 Feb 2012 11:58:31 +0100
Message-ID: <1329735512-29402-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56439 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751301Ab2BTK6j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 05:58:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here's a single patch intendet for 3.3. Oliver Hartkopp fixed a problem in
the generic SJA1000 interrupt handler. If you unplug a PCMCIA or PCIe card,
 when the CAN bus is under high load, the interrupt handler my
loop forever, not noticing that the hardware has been removed. I added
stable to Cc, v3.2 was the first kernel with such a driver.

regards, Marc

---

The following changes since commit 64f0a836f600e9c31ffd511713ab5d328aa96ac8:

  b44: remove __exit from b44_pci_exit() (2012-02-19 18:57:51 -0500)

are available in the git repository at:
  git://gitorious.org/linux-can/linux-can.git master

Oliver Hartkopp (1):
      can: sja1000: fix isr hang when hw is unplugged under load

 drivers/net/can/sja1000/sja1000.c |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)
