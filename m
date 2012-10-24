From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-10-24
Date: Wed, 24 Oct 2012 11:06:14 +0200
Message-ID: <1351069576-20790-1-git-send-email-mkl@pengutronix.de>
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-can@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33889 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934466Ab2JXJGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 05:06:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here are two patches for the v3.7 release cycle. A patch by Wolfgang Grandegger
for the flexcan driver, which switches off a workaround on the imx6q that is
not needed, because the hardware is not affected by that bug. And a patch by
Stephane Grosjean which updates the pci device table for the peak pci sja1000
driver.


regards, Marc

--

The following changes since commit 37561f68bd527ec39076e32effdc7b1dcdfb17ea:

  tcp: Reject invalid ack_seq to Fast Open sockets (2012-10-23 02:42:56 -0400)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.7

for you to fetch changes up to fc09e3672ed623f9c8e73ded3cbcd2cfcf304aac:

  can: sja1000: fix/add miniPCIe/cPCI PC/104Plus PCI/104e PEAK-System boards (2012-10-24 10:53:49 +0200)

----------------------------------------------------------------
Stephane Grosjean (1):
      can: sja1000: fix/add miniPCIe/cPCI PC/104Plus PCI/104e PEAK-System boards

Wolfgang Grandegger (1):
      can: flexcan: disable bus error interrupts for the i.MX6q

 drivers/net/can/flexcan.c          |   19 ++++++++++++++++---
 drivers/net/can/sja1000/peak_pci.c |   13 +++++++++++--
 2 files changed, 27 insertions(+), 5 deletions(-)
