From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: pull-request: can 2012-08-24
Date: Fri, 24 Aug 2012 11:30:41 +0200
Message-ID: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55964 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756344Ab2HXJau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 05:30:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

here are two fixes for the v3.6 release cycle. Alexey Khoroshilov submitted a
fix for a memory leak in the softing driver (in softing_load_fw()) in case a
krealloc() fails. Sven Schmitt fixed the misuse of the IRQF_SHARED flag in the
irq resouce of the sja1000 platform driver, now the correct flag is used. There
are no mainline users of this feature which need to be converted.

regards, Marc


The following changes since commit a0dfb2634e5671770f598cda08002d8cda66ac77:

  af_packet: match_fanout_group() can be static (2012-08-23 09:27:12 -0700)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can.git fixes-for-3.6

for you to fetch changes up to da3d50ef308d53f216f1f92f4971f245c13e9f65:

  can: sja1000_platform: fix wrong flag IRQF_SHARED for interrupt sharing (2012-08-24 10:54:05 +0200)

----------------------------------------------------------------
Alexey Khoroshilov (1):
      can: softing: Fix potential memory leak in softing_load_fw()

Sven Schmitt (1):
      can: sja1000_platform: fix wrong flag IRQF_SHARED for interrupt sharing

 drivers/net/can/sja1000/sja1000_platform.c |    4 +++-
 drivers/net/can/softing/softing_fw.c       |    7 ++++---
 2 files changed, 7 insertions(+), 4 deletions(-)
