From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH v2 0/8] net/macb: fixes after big driver update
Date: Tue, 31 Mar 2015 15:01:58 +0200
Message-ID: <1427806926-18887-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Boris BREZILLON <boris.brezillon@free-electrons.com>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	<michal.simek@xilinx.com>, <punnaia@xilinx.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The recent modifications to the macb driver lead to issues with the probe
function code flow. Here are some attempt to fix them.
This time, some more issues are fixed related to the clock as reported by Boris
Brezillon.

The series is written on top of net-next.

Changes in v2:
- address Cyrille comment about exit condition of queue configuration loop
- add fixes for probe sequence related to clocks
- add ethtool register dump
- fix peripheral version test

Nicolas Ferre (8):
  net/macb: only probe queues once and use stored values
  net/macb: add comment in macb_probe_queues
  net/macb: fix capabilities configuration
  net/macb: trivial: correct wording for caps
  net/macb: fix probe sequence to setup clocks earlier
  net/macb: add the user i/o to ethtool register dump
  net/macb: fix the peripheral version test
  net/macb: unify peripheral version testing

 drivers/net/ethernet/cadence/macb.c | 207 +++++++++++++++++++++---------------
 drivers/net/ethernet/cadence/macb.h |  10 +-
 2 files changed, 130 insertions(+), 87 deletions(-)

-- 
2.1.3
