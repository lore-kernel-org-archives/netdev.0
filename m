From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Tue, 12 Feb 2013 01:22:17 +0530
Message-ID: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <linux-arm-kernel@lists.infradead.org>,
	<linux-omap@vger.kernel.org>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:42616 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759348Ab3BKTwv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2013 14:52:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements Dual EMAC mode implementation of CPSW
which acts as two standalone EMAC by segregating the switch using VIDs
and port VLAN

Mugunthan V N (3):
  driver: net: ethernet: davinci_cpdma: add support for directed packet
    and source port detection
  driver: net: ethernet: cpsw: make cpts as pointer
  driver: net: ethernet: cpsw: dual emac interface implementation

 Documentation/devicetree/bindings/net/cpsw.txt |    2 +
 drivers/net/ethernet/ti/cpsw.c                 |  387 +++++++++++++++++++-----
 drivers/net/ethernet/ti/davinci_cpdma.c        |   17 +-
 drivers/net/ethernet/ti/davinci_cpdma.h        |    4 +-
 drivers/net/ethernet/ti/davinci_emac.c         |    6 +-
 include/linux/platform_data/cpsw.h             |    3 +
 6 files changed, 338 insertions(+), 81 deletions(-)

-- 
1.7.9.5
