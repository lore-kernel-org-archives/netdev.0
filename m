From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH] net: hns: declare function as static
Date: Tue, 6 Sep 2016 19:53:11 +0800
Message-ID: <1473162791-43858-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
        Kefeng Wang <wangkefeng.wang@huawei.com>,
        Yisen Zhuang <yisen.zhuang@huawei.com>,
        Kejian Yan <yankejian@huawei.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declare function as static to kill warning about missing-prototypes.

Cc: Yisen Zhuang <yisen.zhuang@huawei.com>
Cc: Kejian Yan <yankejian@huawei.com>
Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---

The warning is shown when make with W=1.

 drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c  | 22 +++++++++++-----------
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c  |  4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c |  4 ++--
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c  |  6 +++---
 drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c  |  4 ++--
 .../net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c    |  2 +-
 drivers/net/ethernet/hisilicon/hns/hns_enet.c      |  8 ++++----
 drivers/net/ethernet/hisilicon/hns/hns_ethtool.c   | 16 ++++++++--------
 10 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
index e28d960..cb47c23 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ae_adapt.c
@@ -73,7 +73,7 @@ static struct ring_pair_cb *hns_ae_get_ring_pair(struct hnae_queue *q)
 	return container_of(q, struct ring_pair_cb, q);
 }
 
-struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
+static struct hnae_handle *hns_ae_get_handle(struct hnae_ae_dev *dev,
 				      u32 port_id)
 {
 	int vfnum_per_port;
@@ -271,7 +271,7 @@ static int hns_ae_start(struct hnae_handle *handle)
 	return 0;
 }
 
-void hns_ae_stop(struct hnae_handle *handle)
+static void hns_ae_stop(struct hnae_handle *handle)
 {
 	struct hns_mac_cb *mac_cb = hns_get_mac_cb(handle);
 
@@ -299,7 +299,7 @@ static void hns_ae_reset(struct hnae_handle *handle)
 	}
 }
 
-void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
+static void hns_ae_toggle_ring_irq(struct hnae_ring *ring, u32 mask)
 {
 	u32 flag;
 
@@ -487,7 +487,7 @@ static void hns_ae_get_coalesce_range(struct hnae_handle *handle,
 	*rx_usecs_high  = HNS_RCB_MAX_COALESCED_USECS;
 }
 
-void hns_ae_update_stats(struct hnae_handle *handle,
+static void hns_ae_update_stats(struct hnae_handle *handle,
 			 struct net_device_stats *net_stats)
 {
 	int port;
@@ -570,7 +570,7 @@ void hns_ae_update_stats(struct hnae_handle *handle,
 	net_stats->multicast = mac_cb->hw_stats.rx_mc_pkts;
 }
 
-void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
+static void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
 {
 	int idx;
 	struct hns_mac_cb *mac_cb;
@@ -602,7 +602,7 @@ void hns_ae_get_stats(struct hnae_handle *handle, u64 *data)
 		hns_dsaf_get_stats(vf_cb->dsaf_dev, p, vf_cb->port_index);
 }
 
-void hns_ae_get_strings(struct hnae_handle *handle,
+static void hns_ae_get_strings(struct hnae_handle *handle,
 			u32 stringset, u8 *data)
 {
 	int port;
@@ -635,7 +635,7 @@ void hns_ae_get_strings(struct hnae_handle *handle,
 		hns_dsaf_get_strings(stringset, p, port, dsaf_dev);
 }
 
-int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
+static int hns_ae_get_sset_count(struct hnae_handle *handle, int stringset)
 {
 	u32 sset_count = 0;
 	struct hns_mac_cb *mac_cb;
@@ -684,7 +684,7 @@ static int hns_ae_config_loopback(struct hnae_handle *handle,
 	return ret;
 }
 
-void hns_ae_update_led_status(struct hnae_handle *handle)
+static void hns_ae_update_led_status(struct hnae_handle *handle)
 {
 	struct hns_mac_cb *mac_cb;
 
@@ -695,7 +695,7 @@ void hns_ae_update_led_status(struct hnae_handle *handle)
 	hns_set_led_opt(mac_cb);
 }
 
-int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
+static int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
 			   enum hnae_led_state status)
 {
 	struct hns_mac_cb *mac_cb;
@@ -707,7 +707,7 @@ int hns_ae_cpld_set_led_id(struct hnae_handle *handle,
 	return hns_cpld_led_set_id(mac_cb, status);
 }
 
-void hns_ae_get_regs(struct hnae_handle *handle, void *data)
+static void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 {
 	u32 *p = data;
 	int i;
@@ -732,7 +732,7 @@ void hns_ae_get_regs(struct hnae_handle *handle, void *data)
 		hns_dsaf_get_regs(vf_cb->dsaf_dev, vf_cb->port_index, p);
 }
 
-int hns_ae_get_regs_len(struct hnae_handle *handle)
+static int hns_ae_get_regs_len(struct hnae_handle *handle)
 {
 	u32 total_num;
 	struct hnae_vf_cb *vf_cb = hns_ae_get_vf_cb(handle);
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
index 1e1eb92..f0c63c8 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_gmac.c
@@ -327,7 +327,7 @@ static void hns_gmac_init(void *mac_drv)
 		hns_gmac_set_uc_match(mac_drv, 0);
 }
 
-void hns_gmac_update_stats(void *mac_drv)
+static void hns_gmac_update_stats(void *mac_drv)
 {
 	struct mac_hw_stats *hw_stats = NULL;
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
index 5c8afe1..0d9f261 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_mac.c
@@ -898,7 +898,7 @@ static int hns_mac_get_mode(phy_interface_t phy_if)
 	}
 }
 
-u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
+static u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
 			      struct hns_mac_cb *mac_cb, u32 mac_mode_idx)
 {
 	u8 __iomem *base = dsaf_dev->io_base;
@@ -917,7 +917,7 @@ u8 __iomem *hns_mac_get_vaddr(struct dsaf_device *dsaf_dev,
  * @mac_cb: mac control block
  * return 0 - success , negative --fail
  */
-int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
+static int hns_mac_get_cfg(struct dsaf_device *dsaf_dev, struct hns_mac_cb *mac_cb)
 {
 	int ret;
 	u32 mac_mode_idx;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
index afb5daa..0f4ad08 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
@@ -41,7 +41,7 @@ static const struct acpi_device_id hns_dsaf_acpi_match[] = {
 };
 MODULE_DEVICE_TABLE(acpi, hns_dsaf_acpi_match);
 
-int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
+static int hns_dsaf_get_cfg(struct dsaf_device *dsaf_dev)
 {
 	int ret, i;
 	u32 desc_num;
@@ -2092,7 +2092,7 @@ static void hns_dsaf_pfc_unit_cnt(struct dsaf_device *dsaf_dev, int  mac_id,
  * @dsaf_id: dsa fabric id
  * @xge_ge_work_mode
  */
-void hns_dsaf_port_work_rate_cfg(struct dsaf_device *dsaf_dev, int mac_id,
+static void hns_dsaf_port_work_rate_cfg(struct dsaf_device *dsaf_dev, int mac_id,
 				 enum dsaf_port_rate_mode rate_mode)
 {
 	u32 port_work_mode;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
index 611b67b..8ebe463 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c
@@ -417,7 +417,7 @@ static phy_interface_t hns_mac_get_phy_if_acpi(struct hns_mac_cb *mac_cb)
 	return phy_if;
 }
 
-int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
+static int hns_mac_get_sfp_prsnt(struct hns_mac_cb *mac_cb, int *sfp_prsnt)
 {
 	if (!mac_cb->cpld_ctrl)
 		return -ENODEV;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
index 6ea8722..238c992 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
@@ -73,7 +73,7 @@ hns_ppe_common_get_ioaddr(struct ppe_common_cb *ppe_common)
  * comm_index: common index
  * retuen 0 - success , negative --fail
  */
-int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
+static int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 {
 	struct ppe_common_cb *ppe_common;
 	int ppe_num;
@@ -104,7 +104,7 @@ int hns_ppe_common_get_cfg(struct dsaf_device *dsaf_dev, int comm_index)
 	return 0;
 }
 
-void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
+static void hns_ppe_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index)
 {
 	dsaf_dev->ppe_common[comm_index] = NULL;
 }
@@ -337,7 +337,7 @@ static void hns_ppe_uninit_hw(struct hns_ppe_cb *ppe_cb)
 	}
 }
 
-void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
+static void hns_ppe_uninit_ex(struct ppe_common_cb *ppe_common)
 {
 	u32 i;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
index ef11077..ded4506 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
@@ -612,7 +612,7 @@ void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode, u16 *max_vfn,
 	}
 }
 
-int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
+static int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 {
 	switch (dsaf_dev->dsaf_mode) {
 	case DSAF_MODE_ENABLE_FIX:
@@ -648,7 +648,7 @@ int hns_rcb_get_ring_num(struct dsaf_device *dsaf_dev)
 	}
 }
 
-void __iomem *hns_rcb_common_get_vaddr(struct rcb_common_cb *rcb_common)
+static void __iomem *hns_rcb_common_get_vaddr(struct rcb_common_cb *rcb_common)
 {
 	struct dsaf_device *dsaf_dev = rcb_common->dsaf_dev;
 
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
index 8f4f0e8..3198890 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_xgmac.c
@@ -306,7 +306,7 @@ static void hns_xgmac_config_max_frame_length(void *mac_drv, u16 newval)
 	dsaf_write_dev(drv, XGMAC_MAC_MAX_PKT_SIZE_REG, newval);
 }
 
-void hns_xgmac_update_stats(void *mac_drv)
+static void hns_xgmac_update_stats(void *mac_drv)
 {
 	struct mac_driver *drv = (struct mac_driver *)mac_drv;
 	struct mac_hw_stats *hw_stats = &drv->mac_cb->hw_stats;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index d7e1f8c..1b51191 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1085,7 +1085,7 @@ static int hns_nic_net_set_mac_address(struct net_device *ndev, void *p)
 	return 0;
 }
 
-void hns_nic_update_stats(struct net_device *netdev)
+static void hns_nic_update_stats(struct net_device *netdev)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1486,7 +1486,7 @@ static netdev_features_t hns_nic_fix_features(
  *
  * return void
  */
-void hns_set_multicast_list(struct net_device *ndev)
+static void hns_set_multicast_list(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1504,7 +1504,7 @@ void hns_set_multicast_list(struct net_device *ndev)
 	}
 }
 
-void hns_nic_set_rx_mode(struct net_device *ndev)
+static void hns_nic_set_rx_mode(struct net_device *ndev)
 {
 	struct hns_nic_priv *priv = netdev_priv(ndev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1519,7 +1519,7 @@ void hns_nic_set_rx_mode(struct net_device *ndev)
 	hns_set_multicast_list(ndev);
 }
 
-struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
+static struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
 					      struct rtnl_link_stats64 *stats)
 {
 	int idx = 0;
diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
index ab33487..206f830 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
@@ -666,7 +666,7 @@ static void hns_nic_get_drvinfo(struct net_device *net_dev,
  * @dev: net device
  * @param: ethtool parameter
  */
-void hns_get_ringparam(struct net_device *net_dev,
+static void hns_get_ringparam(struct net_device *net_dev,
 		       struct ethtool_ringparam *param)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
@@ -815,7 +815,7 @@ static int hns_set_coalesce(struct net_device *net_dev,
  * @dev: net device
  * @ch: channel info.
  */
-void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
+static void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
 
@@ -832,7 +832,7 @@ void hns_get_channels(struct net_device *net_dev, struct ethtool_channels *ch)
  * @stats: statistics info.
  * @data: statistics data.
  */
-void hns_get_ethtool_stats(struct net_device *netdev,
+static void hns_get_ethtool_stats(struct net_device *netdev,
 			   struct ethtool_stats *stats, u64 *data)
 {
 	u64 *p = data;
@@ -890,7 +890,7 @@ void hns_get_ethtool_stats(struct net_device *netdev,
  * @stats: string set ID.
  * @data: objects data.
  */
-void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
+static void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -980,7 +980,7 @@ void hns_get_strings(struct net_device *netdev, u32 stringset, u8 *data)
  *
  * Return string set count.
  */
-int hns_get_sset_count(struct net_device *netdev, int stringset)
+static int hns_get_sset_count(struct net_device *netdev, int stringset)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1012,7 +1012,7 @@ int hns_get_sset_count(struct net_device *netdev, int stringset)
  *
  * Return 0 on success, negative on failure.
  */
-int hns_phy_led_set(struct net_device *netdev, int value)
+static int hns_phy_led_set(struct net_device *netdev, int value)
 {
 	int retval;
 	struct hns_nic_priv *priv = netdev_priv(netdev);
@@ -1035,7 +1035,7 @@ int hns_phy_led_set(struct net_device *netdev, int value)
  *
  * Return 0 on success, negative on failure.
  */
-int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
+static int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
 {
 	struct hns_nic_priv *priv = netdev_priv(netdev);
 	struct hnae_handle *h = priv->ae_handle;
@@ -1109,7 +1109,7 @@ int hns_set_phys_id(struct net_device *netdev, enum ethtool_phys_id_state state)
  * @cmd: ethtool cmd
  * @date: register data
  */
-void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
+static void hns_get_regs(struct net_device *net_dev, struct ethtool_regs *cmd,
 		  void *data)
 {
 	struct hns_nic_priv *priv = netdev_priv(net_dev);
-- 
1.7.12.4
