From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/5] net: dsa: use generic slave phydev
Date: Tue, 26 Sep 2017 17:15:30 -0400
Message-ID: <20170926211535.21273-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DSA currently stores a phy_device pointer in each slave private
structure. This requires to implement our own ethtool ksettings
accessors and such.

This patchset removes the private phy_device in favor of the one
provided in the net_device structure, and thus allows us to use the
generic phy_ethtool_* functions.

Vivien Didelot (5):
  net: dsa: return -ENODEV is there is no slave PHY
  net: dsa: use slave device phydev
  net: dsa: use phy_ethtool_get_link_ksettings
  net: dsa: use phy_ethtool_set_link_ksettings
  net: dsa: use phy_ethtool_nway_reset

 net/dsa/dsa_priv.h |   1 -
 net/dsa/slave.c    | 143 +++++++++++++++++++----------------------------------
 2 files changed, 52 insertions(+), 92 deletions(-)

-- 
2.14.1
