From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 0/6] drivers: net: xgene-v2: Add RGMII based 1G driver
Date: Tue, 31 Jan 2017 11:03:15 -0800
Message-ID: <1485889401-13909-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org
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

This patch set adds support for RGMII based 1GbE hardware which uses a linked
list of DMA descriptor architecture (v2) for APM X-Gene SoCs.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---

Iyappan Subramanian (6):
  drivers: net: xgene-v2: Add DMA descriptor
  drivers: net: xgene-v2: Add mac configuration
  drivers: net: xgene-v2: Add ethernet hardware configuration
  drivers: net: xgene-v2: Add base driver
  drivers: net: xgene-v2: Add transmit and receive
  MAINTAINERS: Add entry for APM X-Gene SoC Ethernet (v2) driver

 MAINTAINERS                                |   6 +
 drivers/net/ethernet/apm/Kconfig           |   1 +
 drivers/net/ethernet/apm/Makefile          |   1 +
 drivers/net/ethernet/apm/xgene-v2/Kconfig  |  11 +
 drivers/net/ethernet/apm/xgene-v2/Makefile |   6 +
 drivers/net/ethernet/apm/xgene-v2/enet.c   |  71 ++++
 drivers/net/ethernet/apm/xgene-v2/enet.h   |  43 ++
 drivers/net/ethernet/apm/xgene-v2/mac.c    | 116 +++++
 drivers/net/ethernet/apm/xgene-v2/mac.h    | 132 ++++++
 drivers/net/ethernet/apm/xgene-v2/main.c   | 657 +++++++++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene-v2/main.h   |  88 ++++
 drivers/net/ethernet/apm/xgene-v2/ring.c   |  73 ++++
 drivers/net/ethernet/apm/xgene-v2/ring.h   |  77 ++++
 13 files changed, 1282 insertions(+)
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/enet.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/mac.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/main.h
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.c
 create mode 100644 drivers/net/ethernet/apm/xgene-v2/ring.h

-- 
1.9.1
