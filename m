From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 06/14] xen: Use eth_<foo>_addr instead of memset
Date: Tue, 3 Mar 2015 10:13:14 +0000
Message-ID: <20150303101314.GV11855@zion.uk.xensource.com>
References: <cover.1425354527.git.joe@perches.com>
 <8762529463d8d2290ef0b67e5ed91f4bccb98b37.1425354528.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8762529463d8d2290ef0b67e5ed91f4bccb98b37.1425354528.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 02, 2015 at 07:54:51PM -0800, Joe Perches wrote:
> Use the built-in function instead of memset.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/interface.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index f38227a..4ae98e2 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -438,7 +438,7 @@ struct xenvif *xenvif_alloc(struct device *parent, domid_t domid,
>  	 * stolen by an Ethernet bridge for STP purposes.
>  	 * (FE:FF:FF:FF:FF:FF)
>  	 */
> -	memset(dev->dev_addr, 0xFF, ETH_ALEN);
> +	eth_broadcast_addr(dev->dev_addr);
>  	dev->dev_addr[0] &= ~0x01;
>  
>  	netif_carrier_off(dev);
> -- 
> 2.1.2
