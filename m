From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 23/50] efx: use dev_hw_addr_random() instead of
 random_ether_addr()
Date: Wed, 8 Feb 2012 21:29:40 +0000
Message-ID: <1328736580.2627.9.camel@bwh-desktop>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
	 <1328735457-29986-24-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-24-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-02-08 at 22:10 +0100, Danny Kukawka wrote:
> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.
> 
> Reset the state to NET_ADDR_PERM as soon as the MAC get
> changed via .ndo_set_mac_address.
> 
> Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
> ---
>  drivers/net/ethernet/sfc/efx.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
> index e43702f..cce339a 100644
> --- a/drivers/net/ethernet/sfc/efx.c
> +++ b/drivers/net/ethernet/sfc/efx.c
> @@ -940,7 +940,7 @@ static int efx_probe_port(struct efx_nic *efx)
>  			rc = -EINVAL;
>  			goto err;
>  		}
> -		random_ether_addr(efx->net_dev->dev_addr);
> +		dev_hw_addr_random(efx->net_dev, efx->net_dev->dev_addr);
>  		netif_info(efx, probe, efx->net_dev,
>  			   "using locally-generated MAC %pM\n",
>  			   efx->net_dev->dev_addr);
[...]

This code no longer exists in net-next.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
