From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] More mdio device build failure fixes
Date: Tue, 12 Jan 2016 03:24:29 +0100
Message-ID: <1452565471-8953-1-git-send-email-andrew@lunn.ch>
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:46034 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758927AbcALCYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2016 21:24:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix two build errors reported by Guenter Roeck

Andrew Lunn (2):
  net: freescale: ucc_geth: Fix build error from phy_device API change
  net: freescale: mac-fec: Fix build error from phy_device API change

 drivers/net/ethernet/freescale/fs_enet/mac-fec.c | 2 +-
 drivers/net/ethernet/freescale/ucc_geth.c        | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

-- 
2.7.0.rc3
