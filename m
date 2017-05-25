From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v2 net-next 0/4] More marvell phy cleanups
Date: Thu, 25 May 2017 21:42:04 +0200
Message-ID: <1495741328-25001-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44925 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933080AbdEYTnj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 May 2017 15:43:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset continues the cleanup of the Marvell PHY driver.  These
phys use pages to allow more than the 32 registers that fit into the
MDIO address space. Cleanup the code used for changing pages.

v2
Reverse christmas tree

Andrew Lunn (4):
  net: phy: marvell: #defines for copper and fibre pages
  net: phy: marvell: More hidden page changes refactored
  net: phy: marvell: helper to get and set page
  net: phy: marvell: Uniform page names

 drivers/net/phy/marvell.c | 181 +++++++++++++++++++++++++---------------------
 1 file changed, 98 insertions(+), 83 deletions(-)

-- 
2.11.0
