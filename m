From: Greg <gvrose8192@gmail.com>
Subject: Re: [PATCH 1/1] ixgbevf: replace integer number with bool value
Date: Thu, 28 Jul 2016 07:29:06 -0700
Message-ID: <1469716146.14256.1.camel@gmail.com>
References: <1469626117-3669-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Zhu Yanjun <zyjzyj2000@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469626117-3669-1-git-send-email-zyjzyj2000@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-07-27 at 21:28 +0800, Zhu Yanjun wrote:
> The variable get_mac_status is a bool variable. So a bool value is
> better than an integer number.
> 
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>

Looks good to me.

Reviewed-by: Greg Rose <grose@lightfleet.com>

> ---
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 2 +-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
>  2 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> index 508e72c..ce221d1 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
> @@ -104,7 +104,7 @@ static int ixgbevf_get_settings(struct net_device *netdev,
>  	ecmd->transceiver = XCVR_DUMMY1;
>  	ecmd->port = -1;
>  
> -	hw->mac.get_link_status = 1;
> +	hw->mac.get_link_status = true;
>  	hw->mac.ops.check_link(hw, &link_speed, &link_up, false);
>  
>  	if (link_up) {
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index acc2401..a98e7c2 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -1285,7 +1285,7 @@ static irqreturn_t ixgbevf_msix_other(int irq, void *data)
>  	struct ixgbevf_adapter *adapter = data;
>  	struct ixgbe_hw *hw = &adapter->hw;
>  
> -	hw->mac.get_link_status = 1;
> +	hw->mac.get_link_status = true;
>  
>  	ixgbevf_service_event_schedule(adapter);
>  
> @@ -2109,7 +2109,7 @@ static void ixgbevf_up_complete(struct ixgbevf_adapter *adapter)
>  	ixgbevf_save_reset_stats(adapter);
>  	ixgbevf_init_last_counter_stats(adapter);
>  
> -	hw->mac.get_link_status = 1;
> +	hw->mac.get_link_status = true;
>  	mod_timer(&adapter->service_timer, jiffies);
>  }
>  
