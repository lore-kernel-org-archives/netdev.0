From: Luwei Zhou <b45643@freescale.com>
Subject: [PATCH v3 0/3] Enable FEC pps feather
Date: Fri, 10 Oct 2014 13:15:27 +0800
Message-ID: <1412918130-18830-1-git-send-email-b45643@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <shawn.guo@linaro.org>,
	<bhutchings@solarflare.com>, <R49496@freescale.com>,
	<b38611@freescale.com>, <b20596@freescale.com>,
	<stephen@networkplumber.org>
To: <davem@davemloft.net>, <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0139.outbound.protection.outlook.com ([207.46.100.139]:2995
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750905AbaJJGfK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Oct 2014 02:35:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change from v2 to v3:
	-Using the default channel 0 to be PPS channel not PTP_PIN_SET/GETFUNC interface.
	-Using the linux definition of NSEC_PER_SEC.

Change from v1 to v2:
	- Fix the potential 32-bit multiplication overflow issue.
	- Optimize the hareware adjustment code to improve efficiency as Richard suggested
	- Use ptp PTP_PIN_SET/GETFUNC interface to set PPS channel not device tree
	and add PTP_PF_PPS enumeration
	- Modify comments style


Luwei Zhou (3):
  net: fec: ptp: Use the 31-bit ptp timer.
  net: fec: ptp: Use hardware algorithm to adjust PTP counter.
  net: fec: ptp: Enable PPS output based on ptp clock

 drivers/net/ethernet/freescale/fec.h      |  10 ++
 drivers/net/ethernet/freescale/fec_main.c |   2 +
 drivers/net/ethernet/freescale/fec_ptp.c  | 272 ++++++++++++++++++++++++++++--
 3 files changed, 267 insertions(+), 17 deletions(-)

-- 
1.9.1
