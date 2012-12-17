From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [PATCH 0/3 v2] net/macb: RX path enhancement
Date: Mon, 17 Dec 2012 14:01:56 +0100
Message-ID: <cover.1355748676.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>,
	Joachim Eastwood <manabian@gmail.com>,
	Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Here is the patch series for modifying the RX path in macb driver.
This change applies on GEM variant of the Cadence IP and introduces
function pointers to match the path to the proper adapter. The move
to RX buffers adapted to MTU and that can be DMAed directly in SKB
is done in two steps but can be merged in a single patch.

v2: - gave up the idea of using non-coherent memory for
      rx buffers
    - addition of the struct macb layout optimization


Havard Skinnemoen (1):
  net/macb: Try to optimize struct macb layout

Nicolas Ferre (2):
  net/macb: increase RX buffer size for GEM
  net/macb: change RX path for GEM

 drivers/net/ethernet/cadence/macb.c | 323 +++++++++++++++++++++++++++++++-----
 drivers/net/ethernet/cadence/macb.h |  35 ++--
 2 files changed, 306 insertions(+), 52 deletions(-)

-- 
1.8.0
