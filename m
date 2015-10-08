From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 0/3] net: dsa: push switchdev prepare phase in FDB ops
Date: Thu,  8 Oct 2015 11:35:11 -0400
Message-ID: <1444318514-32250-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset pushes the switchdev prepare phase for the FDB add and del
operations down to the DSA drivers. Currently only mv88e6xxx is affected.

Since the dump requires a bit of refactoring in the driver, it'll come in a
future patchset.

Changes in v2:
 * forward declare switchdev structs instead of fixing the dsa.h include.

Vivien Didelot (3):
  net: dsa: add port_fdb_prepare
  net: dsa: push prepare phase in port_fdb_add
  net: dsa: use switchdev obj in port_fdb_del

 drivers/net/dsa/mv88e6171.c |  1 +
 drivers/net/dsa/mv88e6352.c |  1 +
 drivers/net/dsa/mv88e6xxx.c | 24 ++++++++++++++++++------
 drivers/net/dsa/mv88e6xxx.h |  8 ++++++--
 include/net/dsa.h           | 11 +++++++++--
 net/dsa/slave.c             | 11 +++++++----
 6 files changed, 42 insertions(+), 14 deletions(-)

-- 
2.6.0
