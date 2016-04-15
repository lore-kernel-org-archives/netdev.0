From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/7] net: dsa: mv88e6xxx: factorize switch info
Date: Fri, 15 Apr 2016 14:25:43 -0400
Message-ID: <1460744750-13896-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset factorizes drastically the mv88e6xxx code by sharing a new
extendable info structure to store static data such as switch family,
product number, number of ports, number of databases and the name.

The next step is to add a "features" bitmap member to the info structure
in order to simplify the shared code with a feature-based logic instead
of checking their family/ID.

This is a step forward having a single mv88e6xxx driver supporting many
similar devices, like any usual Linux driver.

Vivien Didelot (7):
  net: dsa: mv88e6xxx: drop double ds assignment
  net: dsa: mv88e6xxx: drop revision probing
  net: dsa: mv88e6xxx: add switch info
  net: dsa: mv88e6xxx: add family to info
  net: dsa: mv88e6xxx: add number of ports to info
  net: dsa: mv88e6xxx: add number of database to info
  net: dsa: mv88e6xxx: drop switch id

 drivers/net/dsa/mv88e6123.c |  29 +------
 drivers/net/dsa/mv88e6131.c |  32 ++-----
 drivers/net/dsa/mv88e6171.c |  15 ++--
 drivers/net/dsa/mv88e6352.c |  24 ++----
 drivers/net/dsa/mv88e6xxx.c | 201 ++++++++++++--------------------------------
 drivers/net/dsa/mv88e6xxx.h |  83 +++++++-----------
 6 files changed, 106 insertions(+), 278 deletions(-)

-- 
2.8.0
