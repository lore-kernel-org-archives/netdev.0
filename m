From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH v2 0/4] net: hix5hd2_gmac: add tx sg feature and reset/clock control signals
Date: Mon, 5 Dec 2016 21:27:57 +0800
Message-ID: <1480944481-118803-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <mturquette@baylibre.com>, <sboyd@codeaurora.org>,
        <linux@armlinux.org.uk>, <zhangfei.gao@linaro.org>,
        <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
        <davem@davemloft.net>, <arnd@arndb.de>, <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "hix5hd2" is SoC name, add the generic ethernet driver compatible string.
The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
the SG/TXCSUM/TSO/UFO features.
This patch set only adds the SG(scatter-gather) driver for transmitting,
the drivers of other features will be submitted later.

Add the MAC reset control signals and clock signals.
We make these signals optional to be backward compatible with
the hix5hd2 SoC.

Changes in v2:
- Make the compatible string changes be a separate patch and
the most specific string come first than the generic string
as advised by Rob.
- Make the MAC reset control signals and clock signals optional
to be backward compatible with the hix5hd2 SoC.
- Change the compatible string and give the clock a specific name
in hix5hd2 dts file.

Dongpo Li (4):
  net: hix5hd2_gmac: add generic compatible string
  net: hix5hd2_gmac: add tx scatter-gather feature
  net: hix5hd2_gmac: add reset control and clock signals
  ARM: dts: hix5hd2: add gmac generic compatible and clock names

 .../bindings/net/hisilicon-hix5hd2-gmac.txt        |  27 +-
 arch/arm/boot/dts/hisi-x5hd2.dtsi                  |   6 +-
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 352 +++++++++++++++++++--
 3 files changed, 352 insertions(+), 33 deletions(-)

-- 
2.8.2
