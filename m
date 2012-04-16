From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull request: linux-can 2012-04-16
Date: Mon, 16 Apr 2012 21:43:07 +0200
Message-ID: <1334605388-1549-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:33935 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754472Ab2DPTnR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 15:43:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

there's a fix targetting net/master from Jesper Juhl, fixing a mem leak
in the error path of the pcan_usb_pro driver. 

redards,
Marc

The following changes since commit 8a9a0ea6032186e3030419262678d652b88bf6a8:

  net/ethernet: ks8851_mll fix rx frame buffer overflow (2012-04-14 15:21:27 -0400)

are available in the git repository at:
  git://gitorious.org/linux-can/linux-can.git master

Jesper Juhl (1):
      can: usb: PCAN-USB Pro: fix mem leaks in pcan_usb_pro_init() on error paths

 drivers/net/can/usb/peak_usb/pcan_usb_pro.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)
