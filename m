From: "Gustavo F. Padovan" <gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH] Bluetooth: Bring back var 'i' increment
Date: Fri, 18 Jun 2010 21:28:07 -0300
Message-ID: <20100619002807.GD14514@vigoh>
References: <20100619002213.GC14514@vigoh>
 <1276907040-23229-1-git-send-email-padovan@profusion.mobi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org
To: "Gustavo F. Padovan" <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1276907040-23229-1-git-send-email-padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

* Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org> [2010-06-18 21:24:00 -0300]:

> commit ff6e2163f28a1094fb5ca5950fe2b43c3cf6bc7a accidentally added a
> regression on the bnep code. Fixing it.
> 
> Signed-off-by: Gustavo F. Padovan <padovan-Y3ZbgMPKUGA34EUeqzHoZw@public.gmane.org>
> ---
>  net/bluetooth/bnep/netdev.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/bluetooth/bnep/netdev.c b/net/bluetooth/bnep/netdev.c
> index 0faad5c..8c100c9 100644
> --- a/net/bluetooth/bnep/netdev.c
> +++ b/net/bluetooth/bnep/netdev.c
> @@ -104,6 +104,8 @@ static void bnep_net_set_mc_list(struct net_device *dev)
>  				break;
>  			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
>  			memcpy(__skb_put(skb, ETH_ALEN), ha->addr, ETH_ALEN);
> +
> +			i++;
>  		}
>  		r->len = htons(skb->len - len);
>  	}
> -- 

Marcel, if you want I can carry the fix on my tree for -next.

-- 
Gustavo F. Padovan
http://padovan.org
