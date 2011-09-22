From: Shawn Guo <shawn.guo@linaro.org>
Subject: [PATCH v4 0/3] add fec support for imx6q
Date: Thu, 22 Sep 2011 13:10:15 +0800
Message-ID: <1316668218-10194-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<patches@linaro.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:45668 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab1IVFBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 01:01:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds imx6q enet support.  The imx6q enet is a derivative of
imx28 enet controller.  It fixed the frame endian issue found on imx28,
and added 1 Gbps support.

Changes since v3:
 * The minus one on phy_speed should happend before left shift.

Changes since v2:
 * Refine patch #1 to get fec_reset_phy() return void

Changes since v1:
 * Fix typo pointed out by Francois Romieu
 * Drop patch #3 in the v1
 * Rebase on net-next tree

Thanks.

Shawn Guo (3):
      net/fec: fec_reset_phy() does not need to always succeed
      net/fec: fix fec1 check in fec_enet_mii_init()
      net/fec: add imx6q enet support

 drivers/net/ethernet/freescale/Kconfig |    9 ++--
 drivers/net/ethernet/freescale/fec.c   |   79 +++++++++++++++++++++++---------
 2 files changed, 61 insertions(+), 27 deletions(-)
