From: yankejian <yankejian@huawei.com>
Subject: [PATCH v2 next 0/2] dts: hisi: fixes no syscon error when init mdio
Date: Mon, 7 Dec 2015 16:25:05 +0800
Message-ID: <1449476707-224320-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linuxarm@huawei.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <robh+dt@kernel.org>, <pawel.moll@arm.com>,
 <mark.rutland@arm.com>, <ijc+devicetree@hellion.org.uk>,
 <galak@codeaurora.org>, <xuwei5@hisilicon.com>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>,
 <wangkefeng.wang@huawei.com>, <dingtianhong@huawei.com>,
 <liguozhu@huawei.com>, <Yisen.Zhuang@huawei.com>,
 <sboyd@codeaurora.org>, <haojian.zhuang@linaro.org>,
 <wangzhou1@hisilicon.com>, <bintian.wang@huawei.com>,
 <long.wanglong@huawei.com>, <leo.yan@linaro.org>
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

this patchset fixes the bug that eth can't initial successful on hip05-D02
because the dts files doesn't match the source code.

yankejian (2):
  dts: hisi: fixes no syscon error when init mdio
  net: hns: fixes no syscon error when init mdio

---
change log:
v2:
 1) update the related documented in the binding as well
 2) use the normal naming conventions using '-' instead of '_', and
    update the related *.c files.

v1:
 initial version

 .../devicetree/bindings/arm/hisilicon/hisilicon.txt      | 16 ++++++++++++++++
 arch/arm64/boot/dts/hisilicon/hip05.dtsi                 |  5 +++++
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi             |  4 ++--
 drivers/net/ethernet/hisilicon/hns_mdio.c                |  2 +-
 4 files changed, 24 insertions(+), 3 deletions(-)

-- 
1.9.1
