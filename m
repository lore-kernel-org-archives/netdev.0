From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH] xen-netfront: correct MAX_TX_TARGET calculation.
Date: Thu, 26 Jan 2012 13:19:00 -0500
Message-ID: <20120126181900.GB25572@phenom.dumpdata.com>
References: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jeremy@goop.org,
	xen-devel@lists.xensource.com, ian.campbell@citrix.com
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:52645 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab2AZSVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2012 13:21:35 -0500
Content-Disposition: inline
In-Reply-To: <1327598603-16398-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 26, 2012 at 05:23:23PM +0000, Wei Liu wrote:

Can you give some more details please? What is the impact of
not having this? Should it be backported to stable?

> Signed-off-by: Wei Liu <wei.liu2@citrix.com>
> ---
>  drivers/net/xen-netfront.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
> index 38f9c95..01f589d 100644
> --- a/drivers/net/xen-netfront.c
> +++ b/drivers/net/xen-netfront.c
> @@ -68,7 +68,7 @@ struct netfront_cb {
>  
>  #define NET_TX_RING_SIZE __CONST_RING_SIZE(xen_netif_tx, PAGE_SIZE)
>  #define NET_RX_RING_SIZE __CONST_RING_SIZE(xen_netif_rx, PAGE_SIZE)
> -#define TX_MAX_TARGET min_t(int, NET_RX_RING_SIZE, 256)
> +#define TX_MAX_TARGET min_t(int, NET_TX_RING_SIZE, 256)
>  
>  struct netfront_stats {
>  	u64			rx_packets;
> -- 
> 1.7.8.3
