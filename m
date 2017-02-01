From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/2] MV88E6390 fixes
Date: Thu,  2 Feb 2017 00:46:14 +0100
Message-ID: <1485992776-23750-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52953 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750873AbdBAXrR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 1 Feb 2017 18:47:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two patches, which have been posted before. Fix simple issues in the
mv88e6390 support. These don't need to go to stable, since the
mv88e6390 support in stable is insufficient to be usable.

To apply cleanly, these patches rely on "net: dsa: mv88e6xxx:
Workaround missing PHY".

v2: Added Reviewed-by.
    Removed a redundant "the"

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Fix ATU age timer for MV88E6390
  net: dsa: mv88e6xxx: Fix typ0 when configuring 2.5Gbps

 drivers/net/dsa/mv88e6xxx/chip.c | 12 ++++++------
 drivers/net/dsa/mv88e6xxx/port.c |  2 +-
 2 files changed, 7 insertions(+), 7 deletions(-)

-- 
2.11.0
