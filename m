From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 0/2] flexcan driver updates
Date: Tue, 26 Jun 2012 16:49:21 +0800
Message-ID: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Marc Kleine-Budde <mkl@pengutronix.de>, <netdev@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe004.messaging.microsoft.com ([213.199.154.207]:43927
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751088Ab2FZItX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:49:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are a couple of flexcan driver/bindings updates, which are meant
to get the driver more device tree friendly.

Shawn Guo (2):
  net: flexcan: clock-frequency is optional for device tree probe
  net: flexcan: add transceiver switch gpio support

 .../devicetree/bindings/net/can/fsl-flexcan.txt    |    6 ++++
 drivers/net/can/flexcan.c                          |   30 ++++++++++++++++++++
 2 files changed, 36 insertions(+), 0 deletions(-)

-- 
1.7.5.4
