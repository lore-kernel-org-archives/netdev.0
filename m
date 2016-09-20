From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCHv2 net-next 0/2] Preparation for mv88e6390
Date: Tue, 20 Sep 2016 02:33:08 +0200
Message-ID: <1474331590-7959-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52751 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753014AbcITAdd (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 20:33:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These two patches are a couple of preparation steps for supporting the
the MV88E6390 family of chips. This is a new generation from Marvell,
and will need more feature flags than are currently available in an
unsigned long. Expand to an unsigned long long. The MV88E6390 also
places its port registers somewhere else, so add a wrapper around port
register access.

v2: Rework wrappers to use mv88e6xxx_{read|write}
    Simpliy some (err < ) to (err)
    Add Reviewed by tag.

Andrew Lunn (2):
  net: dsa: mv88e6xxx: Convert flag bits to unsigned long long
  WIP: net: dsa: mv88e6xxx: Implement interrupt support.

 drivers/net/dsa/mv88e6xxx/chip.c      | 174 ++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/global2.c   | 128 ++++++++++++++++++++++++-
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |  90 +++++++++++-------
 3 files changed, 359 insertions(+), 33 deletions(-)

-- 
2.9.3
