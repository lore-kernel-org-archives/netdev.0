From: <Frank.Li@freescale.com>
Subject: [Patch net-next v2 0/4] net: fec: add interrupt coalescence
Date: Wed, 17 Sep 2014 01:58:06 +0800
Message-ID: <1410890290-11248-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <shawn.guo@linaro.org>, <linux-arm-kernel@lists.infradead.org>,
	Frank Li <Frank.Li@freescale.com>
To: <b38611@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <lznuaa@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0130.outbound.protection.outlook.com ([207.46.100.130]:23072
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755020AbaIPTCW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Sep 2014 15:02:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Li <Frank.Li@freescale.com>

improve error handle when parse queue number.
add interrupt coalescence feature.

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
