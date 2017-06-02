From: Rafal Ozieblo <rafalo@cadence.com>
Subject: [PATCH v2 0/4] PTP support for macb driver
Date: Fri, 2 Jun 2017 15:23:59 +0100
Message-ID: <1496413439-12900-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Rafal Ozieblo <rafalo@cadence.com>
To: David Miller <davem@davemloft.net>, <nicolas.ferre@atmel.com>, Richard
 Cochran <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
 <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
 <linux-arm-kernel@lists.infradead.org>, <harini.katakam@xilinx.com>,
 <andrei.pistirica@microchip.com>
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

This patch series adds support for PTP synchronization protocol
in Cadence GEM driver based on PHC.

v2 changes:
* removed alarm's support
* removed external time stamp support
* removed PTP event interrupt handling
* removed ptp_hw_support flag
* removed all extra sanity checks
* removed unnecessary #ifdef
* fixed coding style and alligment issues
* renamed macb.c to macb_main.c

Rafal Ozieblo (4):
  net: macb: Add support for PTP timestamps in DMA descriptors
  net: macb: Add tsu_clk to device tree
  net: macb: macb.c changed to macb_main.c
  net: macb: Add hardware PTP support

 Documentation/devicetree/bindings/net/macb.txt |    1 +
 drivers/net/ethernet/cadence/Kconfig           |   10 +-
 drivers/net/ethernet/cadence/Makefile          |    5 +
 drivers/net/ethernet/cadence/macb.c            | 3509 -----------------------
 drivers/net/ethernet/cadence/macb.h            |  158 +-
 drivers/net/ethernet/cadence/macb_main.c       | 3647 ++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb_ptp.c        |  512 ++++
 7 files changed, 4325 insertions(+), 3517 deletions(-)
 delete mode 100644 drivers/net/ethernet/cadence/macb.c
 create mode 100644 drivers/net/ethernet/cadence/macb_main.c
 create mode 100755 drivers/net/ethernet/cadence/macb_ptp.c

-- 
2.4.5
