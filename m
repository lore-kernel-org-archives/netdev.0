From: Fabio Estevam <fabio.estevam@freescale.com>
Subject: [PATCH 0/5] fec: Control the PHY regulator in suspend/resume
Date: Mon, 27 May 2013 10:48:28 -0300
Message-ID: <1369662513-32133-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <kernel@pengutronix.de>,
	<netdev@vger.kernel.org>,
	Fabio Estevam <fabio.estevam@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co9ehsobe005.messaging.microsoft.com ([207.46.163.28]:37938
	"EHLO co9outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932379Ab3E0Nsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 09:48:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series provides support for controlling the PHY regulator in suspend/resume.

Fabio Estevam (5):
  fec: Place the phy regulator in the private structure
  fec: Invert the order of error path sequence
  fec: Disable the PHY regulator on error and removal
  fec: Remove irqs first
  fec: Handle the regulator in suspend/resume

 drivers/net/ethernet/freescale/fec.h      |  1 +
 drivers/net/ethernet/freescale/fec_main.c | 37 ++++++++++++++++++++++---------
 2 files changed, 27 insertions(+), 11 deletions(-)

-- 
1.8.1.2
