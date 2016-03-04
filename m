From: Lisheng <lisheng011@huawei.com>
Subject: [PATCH net 0/2] net: hns: fixed the pause ctl bug
Date: Fri, 4 Mar 2016 12:40:48 +0800
Message-ID: <1457066450-72395-1-git-send-email-lisheng011@huawei.com>
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

The change is for supporting pause in V2 chip:
	service ports can close pause-rx;
	debug ports can open pause-rx/tx.

Lisheng (2):
  net: hns: fixed the pause ctl bug
  net: hns: update pause regs to dump function

 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 20 +++++-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  | 30 +++------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 71 ++++++++++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  4 ++
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  6 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  6 ++
 6 files changed, 98 insertions(+), 39 deletions(-)

-- 
1.9.1
