From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V3 2/8] Add a new zerocopy device flag
Date: Wed, 20 Apr 2011 20:48:26 +0100
Message-ID: <1303328906.2823.24.camel@bwh-desktop>
References: <1303328216.19336.18.camel@localhost.localdomain>
	 <1303328648.19336.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303328648.19336.24.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-20 at 12:44 -0700, Shirley Ma wrote:
> This zerocopy flag is used to support device DMA userspace buffers.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
>  include/linux/netdevice.h |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 0249fe7..0998d3d 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1067,6 +1067,9 @@ struct net_device {
>  #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
>  #define NETIF_F_RXCSUM		(1 << 29) /* Receive checksumming offload */
>  
> +/* bit 29 is for device to map userspace buffers -- zerocopy */
> +#define NETIF_F_ZEROCOPY	(1 << 29)

Look above.

Ben.

>  	/* Segmentation offload features */
>  #define NETIF_F_GSO_SHIFT	16
>  #define NETIF_F_GSO_MASK	0x00ff0000
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
