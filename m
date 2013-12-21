From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH 0/5] drivers: net: Adding support for APM X-Gene SoC Ethernet
 base driver
Date: Fri, 20 Dec 2013 19:42:51 -0800
Message-ID: <1387597376-29303-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, gregkh@linuxfoundation.org,
 Iyappan Subramanian <isubramanian@apm.com>, patches@apm.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, jcm@redhat.com,
 Keyur Chudgar <kchudgar@apm.com>, linux-arm-kernel@lists.infradead.org,
 Ravi Patel <rapatel@apm.com>
To: davem@davemloft.net
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

APM X-Gene SoC Ethernet subsystem communicates with a central Queue Manager
 (QMTM) using messages for transmit, receive and allocating data buffers.
 There are multiple ethernet interfaces in APM X-Gene SoC.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Ravi Patel <rapatel@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
---
Iyappan Subramanian (5):
  Documentation: APM X-Gene SoC Ethernet DTS binding documentation
  arm64: dts: APM X-Gene SoC Ethernet device tree nodes
  drivers: net: APM X-Gene SoC Ethernet base driver
  drivers: net: APM X-Gene SoC Ethernet driver error handling
  drivers: net: APM X-Gene SoC Ethernet driver ethtool support

 .../devicetree/bindings/net/apm-xgene-enet.txt     |   67 +
 MAINTAINERS                                        |    7 +
 arch/arm64/boot/dts/apm-mustang.dts                |    8 +
 arch/arm64/boot/dts/apm-storm.dtsi                 |   19 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/apm/Kconfig                   |    1 +
 drivers/net/ethernet/apm/Makefile                  |    5 +
 drivers/net/ethernet/apm/xgene/Kconfig             |   10 +
 drivers/net/ethernet/apm/xgene/Makefile            |   12 +
 drivers/net/ethernet/apm/xgene/xgene_enet_common.c |  497 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_common.h |  450 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h    |  427 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_err.c    |  715 +++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_mac.c    |  520 +++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 1609 ++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   |  177 +++
 drivers/net/ethernet/apm/xgene/xgene_enet_tools.c  |  296 ++++
 18 files changed, 4822 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/apm-xgene-enet.txt
 create mode 100644 drivers/net/ethernet/apm/Kconfig
 create mode 100644 drivers/net/ethernet/apm/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/Kconfig
 create mode 100644 drivers/net/ethernet/apm/xgene/Makefile
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_common.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_common.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_csr.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_err.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_mac.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_main.h
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_tools.c

-- 
1.7.9.5
