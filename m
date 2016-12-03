From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH v1 net-next 0/5] mv88e6390 batch 3
Date: Sat,  3 Dec 2016 04:45:15 +0100
Message-ID: <1480736720-12608-1-git-send-email-andrew@lunn.ch>
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38576 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753044AbcLCDrh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 2 Dec 2016 22:47:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More patches to support the MV88e6390. This is mostly refactoring
existing code and adding implementations for the mv88e6390.  This
patchset set which reserved frames are sent to the cpu, the size of
jumbo frames that will be accepted, turn off egress rate limiting, and
configuration of pause frames.

Andrew Lunn (5):
  net: dsa: mv88e6xxx: Reserved Management frames to CPU
  net: dsa: mv88e6xxx: Refactor setting of jumbo frames
  net: dsa: mv88e6xxx: Refactor egress rate limiting
  net: dsa: mv88e6xxx: Refactor pause configuration
  net: dsa: mv88e6xxx: Implement mv88e6390 pause control

 drivers/net/dsa/mv88e6xxx/chip.c      | 125 +++++++++++++++++++++++++++-------
 drivers/net/dsa/mv88e6xxx/global1.c   |  27 ++++++++
 drivers/net/dsa/mv88e6xxx/global1.h   |   1 +
 drivers/net/dsa/mv88e6xxx/global2.c   |  43 +++++++-----
 drivers/net/dsa/mv88e6xxx/global2.h   |   6 ++
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h |   9 +++
 drivers/net/dsa/mv88e6xxx/port.c      |  50 ++++++++++++++
 drivers/net/dsa/mv88e6xxx/port.h      |   6 +-
 8 files changed, 225 insertions(+), 42 deletions(-)

-- 
2.10.2
