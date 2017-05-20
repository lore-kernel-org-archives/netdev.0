From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 6/9] xfrm: make xfrm_dev_register static
Date: Sat, 20 May 2017 08:48:22 +0200
Message-ID: <20170520064822.GM22049@secunet.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
 <20170519165556.483-7-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49198 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752999AbdETGsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 20 May 2017 02:48:25 -0400
Content-Disposition: inline
In-Reply-To: <20170519165556.483-7-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 19, 2017 at 09:55:53AM -0700, Stephen Hemminger wrote:
> This function is only used in this file and should not be global.
> 
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
>  net/xfrm/xfrm_device.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
> index 8ec8a3fcf8d4..50ec73399b48 100644
> --- a/net/xfrm/xfrm_device.c
> +++ b/net/xfrm/xfrm_device.c
> @@ -138,7 +138,7 @@ bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
>  }
>  EXPORT_SYMBOL_GPL(xfrm_dev_offload_ok);
>  
> -int xfrm_dev_register(struct net_device *dev)
> +static int xfrm_dev_register(struct net_device *dev)

I've applied a patch with this exact fix already to the
ipsec-next tree yesterday.
