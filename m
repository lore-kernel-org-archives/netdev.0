From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Subject: [PATCH 0/5] net: davinci: trivial cleanup
Date: Thu, 16 May 2013 13:00:33 +0530
Message-ID: <1368689438-23889-1-git-send-email-prabhakar.csengg@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	"Lad, Prabhakar" <prabhakar.csengg@gmail.com>
To: DLOS <davinci-linux-open-source@linux.davincidsp.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Kosina <trivial@kernel.org>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:35282 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753561Ab3EPHav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 03:30:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lad, Prabhakar <prabhakar.csengg@gmail.com>

This patch series cleans up the davinci driver.

This patch series applies on 3.10.rc1 and is boot tested
on OMAP-L138 EVM.

Lad, Prabhakar (5):
  davinci: net: cpdma: remove unwanted header file incusion and sort
    thme alphabetically
  net: davinci_emac: remove unwanted header inclusion and sort the
    alphabetically
  net: davinci: emac: Convert to devm_* api
  net: davinci_emac: simplify the OF parser code
  net: davinci_mdio: trivial cleanup

 drivers/net/ethernet/ti/davinci_cpdma.c |   10 +--
 drivers/net/ethernet/ti/davinci_emac.c  |  159 ++++++++-----------------------
 drivers/net/ethernet/ti/davinci_mdio.c  |   23 ++---
 3 files changed, 55 insertions(+), 137 deletions(-)

-- 
1.7.4.1
