From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: [PATCH 1/1] netlink: nla_nest_end return "unsigned init"
Date: Mon, 16 May 2011 13:35:48 -0400
Message-ID: <20110516173548.GB6551@tuxdriver.com>
References: <1305555810-17565-1-git-send-email-wey-yi.w.guy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1305555810-17565-1-git-send-email-wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This should go to netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org instead...

On Mon, May 16, 2011 at 07:23:30AM -0700, Wey-Yi Guy wrote:
> skb->len has unsigned int, return the correct value from nla_nest_end call.
> 
> Signed-off-by: Wey-Yi Guy <wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  include/net/netlink.h |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/include/net/netlink.h b/include/net/netlink.h
> index 8a3906a..241fc0d 100644
> --- a/include/net/netlink.h
> +++ b/include/net/netlink.h
> @@ -1015,7 +1015,8 @@ static inline struct nlattr *nla_nest_start(struct sk_buff *skb, int attrtype)
>   *
>   * Returns the total data length of the skb.
>   */
> -static inline int nla_nest_end(struct sk_buff *skb, struct nlattr *start)
> +static inline unsigned int nla_nest_end(struct sk_buff *skb,
> +					struct nlattr *start)
>  {
>  	start->nla_len = skb_tail_pointer(skb) - (unsigned char *)start;
>  	return skb->len;
> -- 
> 1.7.0.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
