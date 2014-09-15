From: <Frank.Li@freescale.com>
Subject: [Patch net-next 0/4] net: fec: add interrupt coalescence
Date: Tue, 16 Sep 2014 01:12:53 +0800
Message-ID: <1410801177-15872-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0117.outbound.protection.outlook.com ([65.55.169.117]:11392
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753328AbaIOSRC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2014 14:17:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

improve error handle when parse queue number.
add interrupt coalescence feature.

Frank Li (1):
  net: fec: refine error handle of parser queue number from DT

Fugang Duan (3):
  net: fec: add interrupt coalescence feature support
  net:fec: increase DMA queue number
  net: fec: Workaround for imx6sx enet tx hang when enable three queues

 drivers/net/ethernet/freescale/fec.h      |  16 +++-
 drivers/net/ethernet/freescale/fec_main.c | 144 ++++++++++++++++++++++++++++--
 2 files changed, 150 insertions(+), 10 deletions(-)

-- 
1.9.1
