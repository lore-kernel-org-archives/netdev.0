From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 4 May 2008 20:56:52 +0800
Message-ID: <20080504125652.GA1618@gondor.apana.org.au>
References: <1209867740.6210.46.camel@johannes.berg> <20080504031652.GA30993@gondor.apana.org.au> <1209890847.6210.51.camel@johannes.berg> <1209892489.6210.56.camel@johannes.berg> <20080504094444.GA541@gondor.apana.org.au> <1209894754.6210.58.camel@johannes.berg> <1209900355.6210.64.camel@johannes.berg> <1209904088.4065.11.camel@johannes.berg> <20080504124542.GA1455@gondor.apana.org.au> <1209905561.4065.23.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1209905561.4065.23.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, May 04, 2008 at 02:52:41PM +0200, Johannes Berg wrote:
>
> > have no cache at all,
> 
> That wouldn't be good either I think since we can actually use the
> ethernet header quite well.

Actually this is not as bad as it sounds.  Since you're constructing
the hardware header anyway, it may turn out to be easier to tack on
the Ethernet header while you're at it.

Please note that the hardware cache is not the same as the neighbour
cache.  Just because you lose the hardware cache doesn't mean that
you'd lose the neighbour (ARP) cache.

However, this would mean that you'd no longer have an Ethernet device
which is both good and bad.

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
