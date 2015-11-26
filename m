From: Marcin Wojtas <mw@semihalf.com>
Subject: [PATCH v2 net 0/6] Marvell Armada XP/370/38X Neta fixes
Date: Thu, 26 Nov 2015 19:08:07 +0100
Message-ID: <1448561293-16431-1-git-send-email-mw@semihalf.com>
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

According to David's remark I split the original patchset into two. First
one, which I submit is a list of fixes, all stable-CC'ed.

On the occasion two new bugs were fixed - wrong define in one of registers
and, more important, an error path in mvneta_rx() after failing of skb
build.

I'm looking forward to the comments or remarks.

Best regards,
Marcin Wojtas

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
  net: mvneta: enable IP checksum with jumbo frames for Armada 38x on
    Port0

 .../bindings/net/marvell-armada-370-neta.txt       |  6 ++++
 arch/arm/boot/dts/armada-38x.dtsi                  |  1 +
 drivers/net/ethernet/marvell/mvneta.c              | 34 ++++++++++++++++++----
 3 files changed, 35 insertions(+), 6 deletions(-)

-- 
1.8.3.1
