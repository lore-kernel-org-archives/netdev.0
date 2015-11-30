From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v4 net 0/6] Marvell Armada XP/370/38X Neta fixes
Date: Mon, 30 Nov 2015 13:27:40 +0100
Message-ID: <1448886466-31538-1-git-send-email-mw@semihalf.com>
Cc: davem@davemloft.net, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, mw@semihalf.com,
	jaz@semihalf.com, tn@semihalf.com
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm sending v4 with corrected commit log of the last patch, in order to
avoid possible conflicts between the branches as suggested by Gregory
Clement.

Best regards,
Marcin Wojtas

Changes from v4:
* Correct commit log of patch 6/6

Changes from v2:
* Style fixes in patch updating mbus protection
* Remove redundant stable notifications except for patch 4/6

Changes from v1:
* update MBUS windows access protection register once, after whole loop
* add fixing value of MVNETA_RXQ_INTR_ENABLE_ALL_MASK
* add fixing error path for skb_build()
* add possibility of setting custom TX IP checksum limit in DT property

Marcin Wojtas (6):
  net: mvneta: add configuration for MBUS windows access protection
  net: mvneta: fix bit assignment in MVNETA_RXQ_CONFIG_REG
  net: mvneta: fix bit assignment for RX packet irq enable
  net: mvneta: fix error path for building skb
  net: mvneta: enable setting custom TX IP checksum limit
  mvebu: dts: enable IP checksum with jumbo frames for Armada 38x on
    Port0

 .../bindings/net/marvell-armada-370-neta.txt       |  6 ++++
 arch/arm/boot/dts/armada-38x.dtsi                  |  1 +
 drivers/net/ethernet/marvell/mvneta.c              | 33 ++++++++++++++++++----
 3 files changed, 34 insertions(+), 6 deletions(-)

-- 
1.8.3.1
