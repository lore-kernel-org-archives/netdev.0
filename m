From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: headers cleanup
Date: Wed, 17 May 2017 15:46:02 -0400
Message-ID: <20170517194605.31639-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA core files share a common private header file. Include the DSA
public header there instead of independently in each core source file.

DSA core and its drivers use switchdev, thus include switchdev.h in the
public DSA header. This allows us to get rid of the forward declaration
and use typedef defined by switchdev.

Vivien Didelot (3):
  net: dsa: include dsa.h only once
  net: dsa: include switchdev.h only once
  net: dsa: use switchdev_obj_dump_cb_t everywhere

 drivers/net/dsa/b53/b53_common.c |  7 +++----
 drivers/net/dsa/b53/b53_priv.h   |  4 ++--
 drivers/net/dsa/bcm_sf2.c        |  1 -
 drivers/net/dsa/dsa_loop.c       |  3 +--
 drivers/net/dsa/mt7530.c         |  3 +--
 drivers/net/dsa/mv88e6xxx/chip.c | 11 +++++------
 drivers/net/dsa/qca8k.c          |  3 +--
 include/net/dsa.h                | 13 ++++---------
 net/dsa/dsa.c                    |  2 +-
 net/dsa/dsa2.c                   |  2 +-
 net/dsa/dsa_priv.h               |  1 +
 net/dsa/legacy.c                 |  2 +-
 net/dsa/slave.c                  |  3 +--
 net/dsa/switch.c                 |  3 ++-
 net/dsa/tag_brcm.c               |  2 +-
 net/dsa/tag_dsa.c                |  2 +-
 net/dsa/tag_edsa.c               |  2 +-
 net/dsa/tag_lan9303.c            |  2 +-
 net/dsa/tag_mtk.c                |  2 +-
 net/dsa/tag_qca.c                |  2 +-
 net/dsa/tag_trailer.c            |  2 +-
 21 files changed, 31 insertions(+), 41 deletions(-)

-- 
2.13.0
