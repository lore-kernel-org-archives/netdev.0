From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 6 May 2008 09:32:53 +0800
Message-ID: <20080506013253.GA13460@gondor.apana.org.au>
References: <1210027447.8012.15.camel@johannes.berg> <20080505.161458.46071527.davem@davemloft.net> <1210029835.8012.30.camel@johannes.berg> <20080505.163916.239187195.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080505.163916.239187195.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, May 05, 2008 at 04:39:16PM -0700, David Miller wrote:
> 
> On free, since skb->nohdr is set, we'll decrement both of (1 <<
> SKB_DATAREF_SHIFT) and the low 16-bit counter.

skb->nohdr is cleared for clones.  Only the copy held by TCP
should have it set.  So this should work correctly, in theory :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
