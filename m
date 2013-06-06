From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next PATCH 5/8] macvlan: change the max number of queues to
 16
Date: Thu, 6 Jun 2013 14:05:31 +0300
Message-ID: <20130606110531.GD8626@redhat.com>
References: <1370512480-14272-1-git-send-email-jasowang@redhat.com>
 <1370512480-14272-6-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370512480-14272-6-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 06, 2013 at 05:54:37PM +0800, Jason Wang wrote:
> Macvtap should be at least compatible with tap, so change the max number to 16.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  include/linux/if_macvlan.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index e47ad46..62d8bda 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -50,7 +50,7 @@ struct macvlan_pcpu_stats {
>   * Maximum times a macvtap device can be opened. This can be used to
>   * configure the number of receive queue, e.g. for multiqueue virtio.
>   */
> -#define MAX_MACVTAP_QUEUES	(NR_CPUS < 16 ? NR_CPUS : 16)
> +#define MAX_MACVTAP_QUEUES	16
>  
>  #define MACVLAN_MC_FILTER_BITS	8
>  #define MACVLAN_MC_FILTER_SZ	(1 << MACVLAN_MC_FILTER_BITS)
> -- 
> 1.7.1
