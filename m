From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH 0/2][net-next] gianfar: xmit - fix errata workaround and cleanup
Date: Mon, 5 Aug 2013 17:20:08 +0300
Message-ID: <1375712410-11760-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db8lp0189.outbound.messaging.microsoft.com ([213.199.154.189]:8716
	"EHLO db8outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753372Ab3HEOUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 10:20:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
Please find these cleanup patches for the gfar_start_xmit() function,
including a fix for an old errata workaround implementation (eTSEC76,
for MPC8313 and MPC837x). I find this cleanup quite necessary to make
future fixes and improvements in xmit (and Tx processing) easier.
Thanks,

Claudiu Manoil (2):
  gianfar: Fix Tx csum generation errata handling
  gianfar: Cleanup TxFCB insertion on xmit

 drivers/net/ethernet/freescale/gianfar.c | 100 +++++++++++++++++--------------
 1 file changed, 55 insertions(+), 45 deletions(-)

-- 
1.7.11.7
