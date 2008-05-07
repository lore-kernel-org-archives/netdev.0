From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: [PATCH] mac80211: rewrite fragmentation code
Date: Wed, 7 May 2008 21:05:48 +0800
Message-ID: <20080507130548.GA26977@gondor.apana.org.au>
References: <20080430124055.091382000@sipsolutions.net> <20080430130050.105344000@sipsolutions.net> <20080507071026.GA24407@gondor.apana.org.au> <1210150217.9305.39.camel@johannes.berg> <20080507090040.GA25186@gondor.apana.org.au> <1210159339.5642.13.camel@johannes.berg> <20080507114123.GA26073@gondor.apana.org.au> <1210161133.5642.19.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Ron Rindjunsky <ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Tomas Winkler <tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Ivo van Doorn <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1210161133.5642.19.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, May 07, 2008 at 01:52:13PM +0200, Johannes Berg wrote:
>
> Hmm. Why does busy exist then? Historical accident? I really really

Yes it's historical baggage.  These days the biggest users would
be LLTX drivers which should all be converted to non-LLTX and
drivers that don't keep track of queue status properly.

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
