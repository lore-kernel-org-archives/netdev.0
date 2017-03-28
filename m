From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/4] net: dsa: fix chip definitions
Date: Tue, 28 Mar 2017 13:50:31 -0400
Message-ID: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The definitions of some of the mv88e6xxx_ops and mv88e6xxx_info
structures are misordered and erroneous for 88E6191 and 88E6391.

This patch series cleans that up.

Vivien Didelot (4):
  net: dsa: mv88e6xxx: reorder 88E6141 definitions
  net: dsa: mv88e6xxx: reorder 88E6341 definitions
  net: dsa: mv88e6xxx: fix 88E6191 ops
  net: dsa: mv88e6xxx: remove 88E6391 ops

 drivers/net/dsa/mv88e6xxx/chip.c | 186 ++++++++++++++++-----------------------
 1 file changed, 78 insertions(+), 108 deletions(-)

-- 
2.12.1
