From: Keyur Chudgar <kchudgar@apm.com>
Subject: [PATCH v1 0/3] drivers: net: xgene: Add second SGMII based 1G
 interface
Date: Tue, 17 Mar 2015 11:27:10 -0700
Message-ID: <1426616833-9671-1-git-send-email-kchudgar@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Keyur Chudgar <kchudgar@apm.com>, patches@apm.com,
 linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net,
	netdev@vger.kernel.org,
	devicetree@vger.kernel.org
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

This patch adds support for second SGMII based 1G interface.
  
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
Keyur Chudgar (3):
  Documentation: dtb: Add port-id field for APM X-Gene ethernet
  dtb: xgene: Add second SGMII based 1G interface node
  drivers: net: xgene: Add second SGMII based 1G interface

 .../devicetree/bindings/net/apm-xgene-enet.txt     |  2 +
 arch/arm64/boot/dts/apm/apm-mustang.dts            |  4 ++
 arch/arm64/boot/dts/apm/apm-storm.dtsi             | 25 +++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h     |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c   | 50 +++++++++++++++++++---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h   | 17 ++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c  | 10 +++--
 7 files changed, 98 insertions(+), 12 deletions(-)

-- 
1.9.1
