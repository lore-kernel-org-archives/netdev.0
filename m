From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 0/3] net: dsa: add port VLAN dump operation
Date: Tue, 23 Feb 2016 12:13:53 -0500
Message-ID: <1456247636-4706-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The VLAN GetNext approach is specific to some switches and thus hard to
implement for others. This patchset replaces it with a simpler port VLAN dump
operation, similar to the corresponding FDB operation.

The mv88e6xxx driver is the only one currently affected by the change.
The documentation is updated accordingly.

Note: this patchset uses http://www.spinics.net/lists/kernel/msg2186705.html

Vivien Didelot (3):
  net: dsa: add port_vlan_dump routine
  net: dsa: mv88e6xxx: implement port_vlan_dump
  net: dsa: drop vlan_getnext

 Documentation/networking/dsa/dsa.txt |  11 +---
 drivers/net/dsa/mv88e6171.c          |   3 +-
 drivers/net/dsa/mv88e6352.c          |   3 +-
 drivers/net/dsa/mv88e6xxx.c          | 110 ++++++++++++++++-------------------
 drivers/net/dsa/mv88e6xxx.h          |   6 +-
 include/net/dsa.h                    |   6 +-
 net/dsa/slave.c                      |  36 +-----------
 7 files changed, 65 insertions(+), 110 deletions(-)

-- 
2.7.1
