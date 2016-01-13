From: Kejian Yan <yankejian@huawei.com>
Subject: [patch v3 net-next 0/2] dts: hisi: fixes no syscon fault when init mdio
Date: Wed, 13 Jan 2016 15:09:57 +0800
Message-ID: <1452668999-443-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <haifeng.wei@huawei.com>, <devicetree@vger.kernel.org>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linuxarm@huawei.com>
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
	<mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
	<galak@codeaurora.org>, <xuwei5@hisilicon.com>,
	<catalin.marinas@arm.com>, <will.deacon@arm.com>,
	<f.fainelli@gmail.com>, <andrew@lunn.ch>, <liguozhu@huawei.com>,
	<Yisen.Zhuang@huawei.com>, <sboyd@codeaurora.org>,
	<haojian.zhuang@linaro.org>, <wangzhou1@hisilicon.com>,
	<bintian.wang@huawei.com>, <long.wanglong@huawei.com>,
	<leo.yan@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset fixes the bug that eth can't initial successful on hip05-D02
because the dts files doesn't match the source code.

Kejian Yan (2):
  dts: hisi: fixes no syscon fault when init mdio
  net: hns: fixes no syscon error when init mdio
---
change log:
v3:
 1) uses capital letter at the beginning of sentences
 2) updates the right device node name

v2:
 1) update the related documented in the binding as well
 2) use the normal naming conventions using '-' instead of '_', and
    update the related *.c files.
v1:
 first submit

 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
 drivers/net/ethernet/hisilicon/hns_mdio.c                |  2 +-
 4 files changed, 24 insertions(+), 3 deletions(-)

-- 
2.4.1
