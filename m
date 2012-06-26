From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH 0/3] fec driver updates
Date: Tue, 26 Jun 2012 16:45:05 +0800
Message-ID: <1340700308-8315-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	Shawn Guo <shawn.guo@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:35335
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752429Ab2FZIpL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:45:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The series makes a few updates on fec driver to make it work better
for device tree boot.

Shawn Guo (3):
  net: fec: reset phy after pinctrl setup
  net: fec: enable regulator for fec phy
  net: fec: add phy-reset-interval for device tree probe

 Documentation/devicetree/bindings/net/fsl-fec.txt |    5 ++++-
 drivers/net/ethernet/freescale/fec.c              |   21 ++++++++++++++++++---
 2 files changed, 22 insertions(+), 4 deletions(-)

-- 
1.7.5.4
