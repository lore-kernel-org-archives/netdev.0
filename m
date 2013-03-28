From: Steffen Trumtrar <s.trumtrar@pengutronix.de>
Subject: [PATCH v2 0/3] net/macb: fixes to use core on Zynq SoCs
Date: Thu, 28 Mar 2013 10:07:04 +0100
Message-ID: <1364461627-26521-1-git-send-email-s.trumtrar@pengutronix.de>
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Steffen Trumtrar <s.trumtrar@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37632 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754890Ab3C1JHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 05:07:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The Cadence GEM is also licensed for the Xilinx Zynq7000 SoCs.
As Xilinx uses other reset defaults, some fixes are necessary to have it
working there. And as the Zynq is dualcore, the clk_enables/disables now need
to be atomic.

Changes in v2:
	- only 3/3 was changed to correctly use the atomic clk_[en|dis]able

Regards,
Steffen

Steffen Trumtrar (3):
  net/macb: clear tx/rx completion flags in ISR
  net/macb: force endian_swp_pkt_en to off
  net/macb: make clk_enable atomic

 drivers/net/ethernet/cadence/macb.c | 24 ++++++++++++++----------
 drivers/net/ethernet/cadence/macb.h |  2 ++
 2 files changed, 16 insertions(+), 10 deletions(-)

-- 
1.8.2.rc2
