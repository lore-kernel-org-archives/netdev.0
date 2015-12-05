From: yankejian <yankejian@huawei.com>
Subject: [PATCH net-next 0/2] net: hns: enet specisies a reference to dsaf
Date: Sat, 5 Dec 2015 15:59:14 +0800
Message-ID: <1449302356-54658-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree@vger.kernel.org, haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linuxarm@huawei.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <arnd@arndb.de>, <fengguang.wu@intel.com>,
 <robh+dt@kernel.org>, <pawel.moll@arm.com>, <mark.rutland@arm.com>,
 <ijc+devicetree@hellion.org.uk>, <galak@codeaurora.org>,
 <catalin.marinas@arm.com>, <will.deacon@arm.com>,
 <salil.mehta@huawei.com>, <Yisen.Zhuang@huawei.com>,
 <liguozhu@huawei.com>, <lisheng011@huawei.com>,
 <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>
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

in this patchset, enet specifies a reference to dsaf. and delete the 
ae-name in enet, and adds parsing the ae-handle from DT to set the 
associating with dsaf.
the patchset updates the dtsi and bindings documents as well.

yankejian (2):
  net: hns: enet specisies a reference to dsaf
  net: hns: enet specisies a reference to dsaf (config and documents)

 .../devicetree/bindings/net/hisilicon-hns-dsaf.txt    |  5 +----
 .../devicetree/bindings/net/hisilicon-hns-nic.txt     |  7 ++++---
 arch/arm64/boot/dts/hisilicon/hip05_hns.dtsi          | 19 +++++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.c             | 17 +++++++----------
 drivers/net/ethernet/hisilicon/hns/hnae.h             |  7 +++++--
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c     |  4 ++++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c    | 10 +---------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h    |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_enet.c         | 13 +++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_enet.h         |  2 +-
 10 files changed, 42 insertions(+), 43 deletions(-)

-- 
1.9.1
