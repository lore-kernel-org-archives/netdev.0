From: Jon Mason <jon.mason@exar.com>
Subject: Re: [PATCH 07/10] drivers/net/vxge: Remove unnecessary casts of
 netdev_priv
Date: Mon, 15 Nov 2010 16:51:38 -0600
Message-ID: <20101115225137.GB12891@exar.com>
References: <cover.1289855436.git.joe@perches.com>
 <5aee4bf89b5baa6e1d32c99be560893925ed2e19.1289855436.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Kosina <trivial@kernel.org>,
	Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>,
	Sivakumar Subramani <Sivakumar.Subramani@exar.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@exar.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5aee4bf89b5baa6e1d32c99be560893925ed2e19.1289855436.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 15, 2010 at 01:12:30PM -0800, Joe Perches wrote:
> Signed-off-by: Joe Perches <joe@perches.com>

Looks good to me.

Acked-by: Jon Mason <jon.mason@exar.com>

> ---
>  drivers/net/vxge/vxge-ethtool.c |   26 +++++++++++++-------------
>  drivers/net/vxge/vxge-main.c    |   26 +++++++++++++-------------
>  2 files changed, 26 insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/vxge/vxge-ethtool.c b/drivers/net/vxge/vxge-ethtool.c
> index 09f721e..bc9bd10 100644
> --- a/drivers/net/vxge/vxge-ethtool.c
> +++ b/drivers/net/vxge/vxge-ethtool.c
> @@ -80,7 +80,7 @@ static int vxge_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
>  static void vxge_ethtool_gdrvinfo(struct net_device *dev,
>  				  struct ethtool_drvinfo *info)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	strlcpy(info->driver, VXGE_DRIVER_NAME, sizeof(VXGE_DRIVER_NAME));
>  	strlcpy(info->version, DRV_VERSION, sizeof(DRV_VERSION));
>  	strlcpy(info->fw_version, vdev->fw_version, VXGE_HW_FW_STRLEN);
> @@ -108,7 +108,7 @@ static void vxge_ethtool_gregs(struct net_device *dev,
>  	enum vxge_hw_status status;
>  	u64 reg;
>  	u64 *reg_space = (u64 *)space;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct __vxge_hw_device *hldev = vdev->devh;
>  
>  	regs->len = sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
> @@ -144,7 +144,7 @@ static void vxge_ethtool_gregs(struct net_device *dev,
>   */
>  static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct __vxge_hw_device *hldev = vdev->devh;
>  
>  	vxge_hw_device_flick_link_led(hldev, VXGE_FLICKER_ON);
> @@ -166,7 +166,7 @@ static int vxge_ethtool_idnic(struct net_device *dev, u32 data)
>  static void vxge_ethtool_getpause_data(struct net_device *dev,
>  				       struct ethtool_pauseparam *ep)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct __vxge_hw_device *hldev = vdev->devh;
>  
>  	vxge_hw_device_getpause_data(hldev, 0, &ep->tx_pause, &ep->rx_pause);
> @@ -185,7 +185,7 @@ static void vxge_ethtool_getpause_data(struct net_device *dev,
>  static int vxge_ethtool_setpause_data(struct net_device *dev,
>  				      struct ethtool_pauseparam *ep)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct __vxge_hw_device *hldev = vdev->devh;
>  
>  	vxge_hw_device_setpause_data(hldev, 0, ep->tx_pause, ep->rx_pause);
> @@ -203,7 +203,7 @@ static void vxge_get_ethtool_stats(struct net_device *dev,
>  	enum vxge_hw_status status;
>  	enum vxge_hw_status swstatus;
>  	struct vxge_vpath *vpath = NULL;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct __vxge_hw_device *hldev = vdev->devh;
>  	struct vxge_hw_xmac_stats *xmac_stats;
>  	struct vxge_hw_device_stats_sw_info *sw_stats;
> @@ -572,7 +572,7 @@ static void vxge_ethtool_get_strings(struct net_device *dev, u32 stringset,
>  {
>  	int stat_size = 0;
>  	int i, j;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	switch (stringset) {
>  	case ETH_SS_STATS:
>  		vxge_add_string("VPATH STATISTICS%s\t\t\t",
> @@ -1059,21 +1059,21 @@ static void vxge_ethtool_get_strings(struct net_device *dev, u32 stringset,
>  
>  static int vxge_ethtool_get_regs_len(struct net_device *dev)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	return sizeof(struct vxge_hw_vpath_reg) * vdev->no_of_vpath;
>  }
>  
>  static u32 vxge_get_rx_csum(struct net_device *dev)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	return vdev->rx_csum;
>  }
>  
>  static int vxge_set_rx_csum(struct net_device *dev, u32 data)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	if (data)
>  		vdev->rx_csum = 1;
> @@ -1095,7 +1095,7 @@ static int vxge_ethtool_op_set_tso(struct net_device *dev, u32 data)
>  
>  static int vxge_ethtool_get_sset_count(struct net_device *dev, int sset)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	switch (sset) {
>  	case ETH_SS_STATS:
> @@ -1114,7 +1114,7 @@ static int vxge_ethtool_get_sset_count(struct net_device *dev, int sset)
>  
>  static int vxge_set_flags(struct net_device *dev, u32 data)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	enum vxge_hw_status status;
>  
>  	if (data & ~ETH_FLAG_RXHASH)
> @@ -1148,7 +1148,7 @@ static int vxge_set_flags(struct net_device *dev, u32 data)
>  
>  static int vxge_fw_flash(struct net_device *dev, struct ethtool_flash *parms)
>  {
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	if (vdev->max_vpath_supported != VXGE_HW_MAX_VIRTUAL_PATHS) {
>  		printk(KERN_INFO "Single Function Mode is required to flash the"
> diff --git a/drivers/net/vxge/vxge-main.c b/drivers/net/vxge/vxge-main.c
> index 22c7d79..5cba4a6 100644
> --- a/drivers/net/vxge/vxge-main.c
> +++ b/drivers/net/vxge/vxge-main.c
> @@ -153,7 +153,7 @@ static void
>  vxge_callback_link_up(struct __vxge_hw_device *hldev)
>  {
>  	struct net_device *dev = hldev->ndev;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
>  		vdev->ndev->name, __func__, __LINE__);
> @@ -177,7 +177,7 @@ static void
>  vxge_callback_link_down(struct __vxge_hw_device *hldev)
>  {
>  	struct net_device *dev = hldev->ndev;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  
>  	vxge_debug_entryexit(VXGE_TRACE,
>  		"%s: %s:%d", vdev->ndev->name, __func__, __LINE__);
> @@ -787,7 +787,7 @@ vxge_xmit(struct sk_buff *skb, struct net_device *dev)
>  		return NETDEV_TX_OK;
>  	}
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  
>  	if (unlikely(!is_vxge_card_up(vdev))) {
>  		vxge_debug_tx(VXGE_ERR,
> @@ -1052,7 +1052,7 @@ static void vxge_set_multicast(struct net_device *dev)
>  	vxge_debug_entryexit(VXGE_TRACE,
>  		"%s:%d", __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  	hldev = (struct __vxge_hw_device  *)vdev->devh;
>  
>  	if (unlikely(!is_vxge_card_up(vdev)))
> @@ -1209,7 +1209,7 @@ static int vxge_set_mac_addr(struct net_device *dev, void *p)
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  	hldev = vdev->devh;
>  
>  	if (!is_valid_ether_addr(addr->sa_data))
> @@ -1671,7 +1671,7 @@ static void vxge_netpoll(struct net_device *dev)
>  	struct __vxge_hw_device *hldev;
>  	struct vxgedev *vdev;
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  	hldev = pci_get_drvdata(vdev->pdev);
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
> @@ -2581,7 +2581,7 @@ vxge_open(struct net_device *dev)
>  	vxge_debug_entryexit(VXGE_TRACE,
>  		"%s: %s:%d", dev->name, __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  	hldev = pci_get_drvdata(vdev->pdev);
>  	function_mode = vdev->config.device_hw_info.function_mode;
>  
> @@ -2809,7 +2809,7 @@ static int do_vxge_close(struct net_device *dev, int do_io)
>  	vxge_debug_entryexit(VXGE_TRACE, "%s: %s:%d",
>  		dev->name, __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  	hldev = pci_get_drvdata(vdev->pdev);
>  
>  	if (unlikely(!is_vxge_card_up(vdev)))
> @@ -3138,7 +3138,7 @@ vxge_tx_watchdog(struct net_device *dev)
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  
>  	vdev->cric_err_event = VXGE_HW_EVENT_RESET_START;
>  
> @@ -3166,7 +3166,7 @@ vxge_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  
>  	vpath = &vdev->vpaths[0];
>  	if ((NULL == grp) && (vpath->is_open)) {
> @@ -3215,7 +3215,7 @@ vxge_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
>  	struct vxge_vpath *vpath;
>  	int vp_id;
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  
>  	/* Add these vlan to the vid table */
>  	for (vp_id = 0; vp_id < vdev->no_of_vpath; vp_id++) {
> @@ -3242,7 +3242,7 @@ vxge_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
>  
>  	vxge_debug_entryexit(VXGE_TRACE, "%s:%d", __func__, __LINE__);
>  
> -	vdev = (struct vxgedev *)netdev_priv(dev);
> +	vdev = netdev_priv(dev);
>  
>  	vlan_group_set_device(vdev->vlgrp, vid, NULL);
>  
> @@ -3475,7 +3475,7 @@ vxge_callback_crit_err(struct __vxge_hw_device *hldev,
>  			enum vxge_hw_event type, u64 vp_id)
>  {
>  	struct net_device *dev = hldev->ndev;
> -	struct vxgedev *vdev = (struct vxgedev *)netdev_priv(dev);
> +	struct vxgedev *vdev = netdev_priv(dev);
>  	struct vxge_vpath *vpath = NULL;
>  	int vpath_idx;
>  
> -- 
> 1.7.3.1.g432b3.dirty
> 
