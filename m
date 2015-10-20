From: kbuild test robot <lkp@intel.com>
Subject: [RFC PATCH] net:hns: hns_aev2_toggle_ring_irq() can be static
Date: Tue, 20 Oct 2015 23:54:56 +0800
Message-ID: <20151020155456.GA96665@xian>
References: <201510202306.WYUMdngA%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mark.rutland@arm.com, catalin.marinas@arm.com, will.deacon@arm.com,
 linuxarm@huawei.com, paul.gortmaker@windriver.com, lisheng011@huawei.com,
 yankejian <yankejian@huawei.com>, pawel.moll@arm.com, xuwei5@hisilicon.com,
 huangdaode@hisilicon.com, dingtianhong@huawei.com, zhangfei.gao@linaro.org,
 yisen.zhuang@huawei.com, devicetree@vger.kernel.org, arnd@arndb.de,
 ijc+devicetree@hellion.org.uk, mehta.salil.lnk@gmail.com, robh+dt@kernel.org,
 lipeng <lipeng321@huawei.com>, linux-arm-kernel@lists.infradead.org,
 kenneth-lee-2012@foxmail.com, salil.mehta@huawei.com, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, kbuild-all@01.org, galak@codeaurora.org,
 liguozhu@hisilicon.com, davem@davemloft.net
To: Salil <salil.mehta@huawei.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
In-Reply-To: <1445353278-130498-2-git-send-email-salil.mehta@huawei.com>
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


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 hns_ae_adapt.c |    2 +-
 hns_enet.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index c3d64ce..bf277c7 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -337,7 +337,7 @@ void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 	hns_rcb_int_ctrl_hw(ring->q, flag, mask);
 }
 
-void hns_aev2_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
+static void hns_aev2_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 {
 	u32 flag;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 7d996a4..33061f1 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -995,7 +995,7 @@ static void hns_nic_ring_close(struct net_device *netdev, int idx)
 	napi_disable(&priv->ring_data[idx].napi);
 }
 
-void hns_set_irq_affinity(struct hns_nic_priv *priv)
+static void hns_set_irq_affinity(struct hns_nic_priv *priv)
 {
 	struct hnae_handle *h = priv->ae_handle;
 	struct hns_nic_ring_data *rd;
