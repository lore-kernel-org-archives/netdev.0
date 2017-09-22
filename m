From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: simplify port enabling
Date: Fri, 22 Sep 2017 12:17:49 -0400
Message-ID: <20170922161753.19563-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset removes the unnecessary PHY device argument in port
enable/disable switch operations, makes slave open and close symmetrical
and finally provides helpers for enabling or disabling a DSA port.

Vivien Didelot (4):
  net: dsa: move up phy enabling in core
  net: dsa: remove phy arg from port enable/disable
  net: dsa: make slave close symmetrical to open
  net: dsa: add port enable and disable helpers

 drivers/net/dsa/b53/b53_common.c       |  6 +++---
 drivers/net/dsa/b53/b53_priv.h         |  4 ++--
 drivers/net/dsa/bcm_sf2.c              | 32 ++++++++----------------------
 drivers/net/dsa/lan9303-core.c         |  6 ++----
 drivers/net/dsa/microchip/ksz_common.c |  6 ++----
 drivers/net/dsa/mt7530.c               |  8 +++-----
 drivers/net/dsa/mv88e6xxx/chip.c       |  6 ++----
 drivers/net/dsa/qca8k.c                |  6 ++----
 include/net/dsa.h                      |  6 ++----
 net/dsa/dsa_priv.h                     |  3 ++-
 net/dsa/port.c                         | 31 ++++++++++++++++++++++++++++-
 net/dsa/slave.c                        | 36 ++++++++++++++++++----------------
 12 files changed, 77 insertions(+), 73 deletions(-)

-- 
2.14.1
