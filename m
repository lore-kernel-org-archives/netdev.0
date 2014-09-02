From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH net-next 0/3] fec: Do not use NULL pointer to indicate error
Date: Mon,  1 Sep 2014 22:12:52 -0300
Message-ID: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Cc: linux@arm.linux.org.uk, B38611@freescale.com,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f182.google.com ([209.85.220.182]:43817 "EHLO
	mail-vc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbaIBBNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:13:20 -0400
Received: by mail-vc0-f182.google.com with SMTP id im17so6187101vcb.41
        for <netdev@vger.kernel.org>; Mon, 01 Sep 2014 18:13:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Using IS_ERR() to indicate error can simplify the code a bit, so let's use
it when appropriate.

Fabio Estevam (3):
  fec: Do not set fep->clk_ptp to NULL on error
  fec: Do not set fep->clk_enet_out to NULL on error
  fec: Do not set fep->reg_phy to NULL on error

 drivers/net/ethernet/freescale/fec_main.c | 28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

-- 
1.9.1
