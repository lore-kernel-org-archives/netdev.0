From: Romain Perier <romain.perier@free-electrons.com>
Subject: [PATCH 0/4] Add support for the ethernet switch on the EXPRESSObin
Date: Mon, 19 Dec 2016 15:16:05 +0100
Message-ID: <20161219141610.30934-1-romain.perier@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Romain Perier <romain.perier@free-electrons.com>,
 Pawel Moll <pawel.moll@arm.com>, Ian Campbell <ijc+devicetree@hellion.org.uk>,
 netdev@vger.kernel.org, Nadav Haklai <nadavh@marvell.com>,
 Rob Herring <robh+dt@kernel.org>, Kumar Gala <galak@codeaurora.org>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
 Gregory Clement <gregory.clement@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This set of patches adds support for the Marvell ethernet switch 88E6341.
It also add the devicetree definition of thid switch to the DT board.

Romain Perier (4):
  net: dsa: mv88e6xxx: Allow mv88e6xxx_smi_init() to be used at address
    0x1
  net: dsa: mv88e6xxx: Don't forbid MDIO I/Os for PHY addr >=
    num_of_ports
  net: dsa: mv88e6xxx: Add support for ethernet switch 88E6341/88E6141
  arm64: dts: marvell: Add ethernet switch definition for the
    EXPRESSObin

 .../boot/dts/marvell/armada-3720-espressobin.dts   | 67 ++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx/chip.c                   | 24 ++++----
 drivers/net/dsa/mv88e6xxx/mv88e6xxx.h              |  4 +-
 3 files changed, 84 insertions(+), 11 deletions(-)

-- 
2.9.3
