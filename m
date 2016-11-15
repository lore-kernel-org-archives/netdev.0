From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/5] net: Implenent ethtool::nway_reset for a few drivers
Date: Tue, 15 Nov 2016 11:19:44 -0800
Message-ID: <20161115191949.15361-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch, tremyfr@gmail.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35290 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752194AbcKOTUP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 14:20:15 -0500
Received: by mail-pg0-f68.google.com with SMTP id p66so12527374pga.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 11:20:15 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series depends on "net: phy: Centralize auto-negotation restart"
since it provides phy_ethtool_nway_reset as a helper function.

The drivers here already support PHYLIB, so there really is no reason why
restarting auto-negotiation would not be possible with these.

Florian Fainelli (5):
  net: stmmac: Implement ethtool::nway_reset
  net: ethoc: Implement ethtool::nway_reset
  net: ethernet: mvneta: Implement ethtool::nway_reset
  net: ethernet: mvpp2: Implement ethtool::nway_reset
  net: ethernet: marvell: pxa168_eth: Implement ethtool::nway_reset

 drivers/net/ethernet/ethoc.c                         | 1 +
 drivers/net/ethernet/marvell/mvneta.c                | 1 +
 drivers/net/ethernet/marvell/mvpp2.c                 | 1 +
 drivers/net/ethernet/marvell/pxa168_eth.c            | 1 +
 drivers/net/ethernet/stmicro/stmmac/stmmac_ethtool.c | 1 +
 5 files changed, 5 insertions(+)

-- 
2.9.3
