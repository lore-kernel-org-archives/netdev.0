From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 0/3] net: hns: fixed the setting overtime bug
Date: Fri, 4 Mar 2016 12:38:13 +0800
Message-ID: <1457066296-66202-1-git-send-email-lisheng011@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: haifeng.wei@huawei.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, xuwei5@hisilicon.com, linuxarm@huawei.com,
 linux-arm-kernel@lists.infradead.org, kenneth-lee-2012@foxmail.com
To: <davem@davemloft.net>, <yisen.zhuang@huawei.com>, <salil.mehta@huawei.com>,
 <liguozhu@huawei.com>, <huangdaode@hisilicon.com>,
 <lisheng011@huawei.com>, <yankejian@huawei.com>, <arnd@arndb.de>,
 <andriy.shevchenko@linux.intel.com>, <andrew@lunn.ch>,
 <chenny.xu@huawei.com>, <ivecera@redhat.com>, <fengguang.wu@intel.com>
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

In V2 chip,we can set overtime reg is for each port,
that is differents from for all port in V1.
This patch will modify some functions: set/get the reg.

Lisheng (3):
  net: hns: fixed the setting overtime bug
  net: hns: modified dump overtime regs
  net: hns: fixed set-coalesce-usecs return void bug

 drivers/net/ethernet/hisilicon/hns/hnae.h         |   2 +-
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c |  64 +++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 196 ++++++++++------------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h |  23 +--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h |   1 +
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c  |   6 +-
 6 files changed, 133 insertions(+), 159 deletions(-)

-- 
1.9.1
