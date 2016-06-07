From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: [PATCH v2 0/2] net: ethernet: ti: cpsw: delete rx_descs property
Date: Tue,  7 Jun 2016 16:59:34 +0300
Message-ID: <1465307976-12235-1-git-send-email-ivan.khoronzhuk@linaro.org>
Cc: grygorii.strashko@ti.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, bcousson@baylibre.com, tony@atomide.com,
	devicetree@vger.kernel.org,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
To: mugunthanvnm@ti.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no reason in rx_descs property because davinici_cpdma
driver splits pool of descriptors equally between tx and rx channels.
So, this patch series makes driver to use available number of
descriptors for rx channels.

Based on master branch

Since v1:
- separate device tree and driver patches
- return number of rx buffers from cpdma driver

Ivan Khoronzhuk (2):
  net: ethernet: ti: cpsw: remove rx_descs property
  Documentation: DT: cpsw: remove rx_descs property

 Documentation/devicetree/bindings/net/cpsw.txt |  1 -
 arch/arm/boot/dts/am33xx.dtsi                  |  1 -
 arch/arm/boot/dts/am4372.dtsi                  |  1 -
 arch/arm/boot/dts/dm814x.dtsi                  |  1 -
 arch/arm/boot/dts/dra7.dtsi                    |  1 -
 drivers/net/ethernet/ti/cpsw.c                 | 13 +++----------
 drivers/net/ethernet/ti/cpsw.h                 |  1 -
 drivers/net/ethernet/ti/davinci_cpdma.c        |  6 ++++++
 drivers/net/ethernet/ti/davinci_cpdma.h        |  1 +
 9 files changed, 10 insertions(+), 16 deletions(-)

-- 
1.9.1
