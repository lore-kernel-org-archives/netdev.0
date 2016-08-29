From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: add MDB support
Date: Mon, 29 Aug 2016 16:32:43 -0400
Message-ID: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:41179 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754081AbcH2UdO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 16:33:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds the switchdev MDB object support to the DSA layer.

The MDB support for the mv88e6xxx driver is very similar to the FDB
support. The FDB operations care about unicast addresses while the MDB
operations care about multicast addresses.

Both operation set load/purge/dump the Address Translation Table (ATU),
thus common code is used.

Vivien Didelot (3):
  net: dsa: add MDB support
  net: dsa: mv88e6xxx: make switchdev DB ops generic
  net: dsa: mv88e6xxx: add MDB support

 Documentation/networking/dsa/dsa.txt |  23 +++++
 drivers/net/dsa/mv88e6xxx/chip.c     | 161 ++++++++++++++++++++++++++---------
 include/net/dsa.h                    |  16 ++++
 net/dsa/slave.c                      |  55 ++++++++++++
 4 files changed, 213 insertions(+), 42 deletions(-)

-- 
2.9.3
