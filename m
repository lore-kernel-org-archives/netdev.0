From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v1 0/4] Enable FEC pps ouput
Date: Thu, 25 Sep 2014 16:10:17 +0800
Message-ID: <1411632621-17429-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bn0103.outbound.protection.outlook.com ([157.56.110.103]:43145
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751960AbaIYJaN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2014 05:30:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch does:
	- Replace 32-bit free-running PTP timer with 31-bit.
	- Implement hardware PTP timestamp adjustment.
	- Enable PPS output based on hardware adjustment.


Luwei Zhou (4):
  net: fec: ptp: Use the 31-bit ptp timer.
  net: fec: ptp: Use hardware algorithm to adjust PTP counter.
  net: fec: ptp: Enalbe PPS ouput based on ptp clock
  ARM: Documentation: Update fec dts binding doc

 Documentation/devicetree/bindings/net/fsl-fec.txt |   2 +
 drivers/net/ethernet/freescale/fec.h              |   7 +
 drivers/net/ethernet/freescale/fec_main.c         |   2 +
 drivers/net/ethernet/freescale/fec_ptp.c          | 301 ++++++++++++++++++++--
 4 files changed, 297 insertions(+), 15 deletions(-)

-- 
1.9.1
