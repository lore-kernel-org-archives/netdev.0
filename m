From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC] skbuff: introduce skb_put_zero()
Date: Thu, 25 May 2017 13:01:17 -0400 (EDT)
Message-ID: <20170525.130117.551364108206528221.davem@davemloft.net>
References: <20170524070747.18573-1-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170524070747.18573-1-johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Wed, 24 May 2017 09:07:47 +0200

> From: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> This pattern was introduced a number of times in mac80211 just now,
> and since it's present in a number of other places it makes sense
> to add a little helper for it.
> 
> The transformations of all code were done with the following spatch:
> 
> @@
> identifier p;
> expression len;
> expression skb;
> @@
> -p = skb_put(skb, len);
> -memset(p, 0, len);
> +p = skb_put_zero(skb, len);
> 
> Signed-off-by: Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
> NB: the patch won't apply to net-next because a few of the mac80211
>     users don't exist there yet

Acked-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>

No objections, feel free to push this in via your mac80211 tree.
