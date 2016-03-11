From: Daode Huang <huangdaode@hisilicon.com>
Subject: [PATCH V2 net 0/6] net: hns: hns driver updates
Date: Fri, 11 Mar 2016 17:10:40 +0800
Message-ID: <1457687446-109867-1-git-send-email-huangdaode@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lisheng011@huawei.com, salil.mehta@huawei.com, yankejian@huawei.com,
 kenneth-lee-2012@foxmail.com, liguozhu@hisilicon.com, linuxarm@huawei.com,
 xuwei5@hisilicon.com, linux-kernel@vger.kernel.org, huangdaode@hisilicon.com,
 netdev@vger.kernel.org, Yisen.Zhuang@huawei.com,
 linux-arm-kernel@lists.infradead.org
To: <davem@davemloft.net>
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

Hi Dave,

This patch series are hisilicon network driver bug fix.
please merge them to the net repo.
Thanks

Daode Huang
---
changlog
v2: some minor change according to 
    MBR Sergei <sergei.shtylyov@cogentembedded.com> in
    [patch 3/6] [patch 4/6].

v1: initial version.

Daode Huang (6):
  net: hns: bug fix about the overflow of mss
  net: hns: fixes the hw interrupt bug in using napi
  net: hns: fixed portid bug in sending manage pkt
  net: hns: adds uc match for debug port
  net: hns: fixed service-ges setting MAC-addr bug
  net: hns: bug fix of getting hilink status

 drivers/net/ethernet/hisilicon/hns/hnae.h          |  3 ++
 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  |  1 +
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c | 29 +++++++++++----
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 41 ++++++++++++----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  |  4 +++
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      | 32 +++++++++--------
 6 files changed, 70 insertions(+), 40 deletions(-)

-- 
1.9.1
