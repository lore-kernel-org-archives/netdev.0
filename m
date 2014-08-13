From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v2 0/1] net: fec: ptp: avoid register access when ipg clock is disabled
Date: Wed, 13 Aug 2014 12:55:04 +0800
Message-ID: <1407905705-27984-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b38611@freescale.com>
To: <shawn.guo@linaro.org>, <davem@davemloft.net>,
	<richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0241.outbound.protection.outlook.com ([207.46.163.241]:26289
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750742AbaHMFJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2014 01:09:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2:
* As Richard Cochran's suggestion, use schedule_delayed_work instead of period timer.
* Stop delayed work before ipg clock disable like suspend, ethx close.

Fugang Duan (1):
  net: fec: ptp: avoid register access when ipg clock is disabled

 drivers/net/ethernet/freescale/fec.h      |    2 +-
 drivers/net/ethernet/freescale/fec_main.c |   12 +++++++++++-
 drivers/net/ethernet/freescale/fec_ptp.c  |   15 +++++++--------
 3 files changed, 19 insertions(+), 10 deletions(-)

-- 
1.7.8
