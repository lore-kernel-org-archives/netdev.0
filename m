From: Yisen Zhuang <Yisen.Zhuang@huawei.com>
Subject: [PATCH net-next 0/9] net: hns: fix the typo of hns
Date: Mon, 27 Jun 2016 17:54:06 +0800
Message-ID: <1467021255-95900-1-git-send-email-Yisen.Zhuang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, andrew@lunn.ch, fengguang.wu@intel.com,
 liguozhu@huawei.com, arnd@arndb.de, charles.chenxin@huawei.com,
 linux-kernel@vger.kernel.org, linuxarm@huawei.com, geliangtang@163.com,
 huangdaode@hisilicon.com, netdev@vger.kernel.org,
 andriy.shevchenko@linux.intel.com, linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <yankejian@huawei.com>
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

This series includes typo fixes which review by Andy, adding
the hns maintainer to MAINTAINERS,

 > adds the maintainer for hns driver from Daode;

 > from Daode: fix the typo of hns reviewed by Andy Shevchenko;

 > from Kejian: one remove redundant function and two fix to get 
configuration from DT.

Daode Huang (6):
  MAINTAINERS: add maintainers for hns driver
  net: hns: fix code style about hns driver
  net: hns: change code style from a = a + x to a += x
  net: hns: delete redundant parens
  net: hns: add a space before "*/"
  net: hns: normalize two different loop

Kejian Yan (3):
  net: hns: remove redundant hns_mac_dev_to_enet_if()
  net: hns: add media-type property for hns
  net: hns: get reset registers from DT

 MAINTAINERS                                        |  9 +++
 drivers/net/ethernet/hisilicon/hns/hnae.h          |  9 +++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 41 +++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.h  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 52 +++++++-------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 16 ++---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  4 +-
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 14 +++-
 drivers/net/ethernet/hisilicon/hns_mdio.c          | 80 ++++++++++++++++++----
 10 files changed, 158 insertions(+), 69 deletions(-)

-- 
1.9.1
