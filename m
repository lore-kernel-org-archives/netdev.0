From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 0/2] net: dsa: port enabling
Date: Fri, 22 Sep 2017 19:01:54 -0400
Message-ID: <20170922230156.19521-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset makes slave open and close symmetrical and provides
helpers for enabling or disabling a given DSA port.

Changes in v3:
  - save the phy_device change for a future patchset

Changes in v2:
  - do not remove the phy argument from port enable/disable

Vivien Didelot (2):
  net: dsa: make slave close symmetrical to open
  net: dsa: add port enable and disable helpers

 net/dsa/dsa_priv.h |  3 ++-
 net/dsa/port.c     | 31 ++++++++++++++++++++++++++++++-
 net/dsa/slave.c    | 21 ++++++---------------
 3 files changed, 38 insertions(+), 17 deletions(-)

-- 
2.14.1
