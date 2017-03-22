From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v2 0/2] net: phy: state machine fixes for interrupt driven PHYs
Date: Wed, 22 Mar 2017 13:02:02 +0200
Message-ID: <1490180524-28675-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <andrew@lunn.ch>, <davem@davemloft.net>, <kyle.roeschley@ni.com>,
        <nsekhar@ti.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Roger Quadros <rogerq@ti.com>
To: <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:48173 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758822AbdCVLFX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 07:05:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

These 2 patches fix the following 2 issues with the PHY state machine
when used with interrupt driven PHYs.

- PHY link not coming up if Ethernet cable is plugged before Ethernet network
interface is brought up.

- PHY not being suspended when PHY is halted.

cheers,
-roger

Roger Quadros (2):
  net: phy: Fix PHY AN done state machine for interrupt driven PHYs
  net: phy: Don't miss phy_suspend() on PHY_HALTED for PHYs with
    interrupts

 drivers/net/phy/phy.c | 5 +++++
 1 file changed, 5 insertions(+)

-- 
2.7.4
