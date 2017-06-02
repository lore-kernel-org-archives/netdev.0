From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 0/2] Fixes for mv88e6161
Date: Fri,  2 Jun 2017 23:22:44 +0200
Message-ID: <1496438566-30612-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Chris Healy <cphealy@gmail.com>,
        Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:34999 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdFBVYQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Jun 2017 17:24:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing a board with an mv88e6161 turned up two issues. The PHYs were
not found, because the wrong method to access them was used. The
statistics did not work, because the wrong snapshot method was used

Andrew Lunn (2):
  net: dsa: mv88e6xxx: mv88e6161 uses global 2 for PHY access
  net: dsa: mv88e6xxx: mv88e6161 uses mv88e6320 stats snapshot

 drivers/net/dsa/mv88e6xxx/chip.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
2.11.0
