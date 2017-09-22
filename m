From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: use slave device phydev
Date: Fri, 22 Sep 2017 15:40:42 -0400
Message-ID: <20170922194045.18814-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset removes the private phy_device in favor of the one
provided by the slave net_device, makes slave open and close symmetrical
and finally provides helpers for enabling or disabling a DSA port.

Changes in v2:
  - do not remove the phy argument from port enable/disable

Vivien Didelot (3):
  net: dsa: use slave device phydev
  net: dsa: make slave close symmetrical to open
  net: dsa: add port enable and disable helpers

 net/dsa/dsa_priv.h |   3 +-
 net/dsa/port.c     |  31 +++++++++++-
 net/dsa/slave.c    | 143 +++++++++++++++++++++++------------------------------
 3 files changed, 94 insertions(+), 83 deletions(-)

-- 
2.14.1
