From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH v1 0/4] net: fec: Code cleanup
Date: Tue, 23 Sep 2014 15:40:54 +0800
Message-ID: <1411458058-18934-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <b20596@freescale.com>,
	<b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0138.outbound.protection.outlook.com ([65.55.169.138]:52038
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755215AbaIWIYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 04:24:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patches does several things:
  - Fixing multiqueue issue.
  - Removing the unnecessary errata workaround.
  - Aligning the data buffer dma map/unmap size.
  - Freeing resource after probe failed.


Fugang Duan (4):
  net: fec: Add Ftype to BD to distiguish three tx queues for AVB
  net: fec: remove the ERR006358 workaround for imx6sx enet
  net: fec: align rx data buffer size for dma map/unmap
  net: fec: free resource after phy probe failed

 drivers/net/ethernet/freescale/fec.h      |    1 +
 drivers/net/ethernet/freescale/fec_main.c |   25 ++++++++++++++++++++-----
 2 files changed, 21 insertions(+), 5 deletions(-)

-- 
1.7.8
