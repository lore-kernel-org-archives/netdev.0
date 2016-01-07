From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Fix breakage from mdio device
Date: Thu,  7 Jan 2016 21:55:50 +0100
Message-ID: <1452200152-15793-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43507 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753263AbcAGU4M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2016 15:56:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches fix MIPS platforms which got broken by
the recent mdio device patchset.

Andrew Lunn (2):
  net: lantiq_etop.c: Use helper to find first phy
  net: ethernet-rgmii.c: Fix breakage from moving phdev bus

 drivers/net/ethernet/lantiq_etop.c      | 10 ++--------
 drivers/staging/octeon/ethernet-rgmii.c |  6 +++---
 2 files changed, 5 insertions(+), 11 deletions(-)

-- 
2.6.4
