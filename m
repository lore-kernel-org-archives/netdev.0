From: <Frank.Li@freescale.com>
Subject: [Patch net-next v3 0/4] net: fec: add interrupt coalescence
Date: Wed, 17 Sep 2014 05:18:50 +0800
Message-ID: <1410902334-7827-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0101.outbound.protection.outlook.com ([157.56.110.101]:60147
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751884AbaIPWXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 18:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

improve error handle when parse queue number.
add interrupt coalescence feature.

Change from v2 to v3
 - add error check in fec_enet_set_coalesce
 - fix a run time warning to get clock rate in interrupt
 - fix commit message use TKT number

Change from v1 to v2
 - fix indention
 - use errata number instead of TKT

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
