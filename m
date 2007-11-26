From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Mon, 26 Nov 2007 09:36:55 +0800
Message-ID: <20071126013655.GA22528@gondor.apana.org.au>
References: <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <1195938799.4149.197.camel@johannes.berg> <20071125014446.GA32104@gondor.apana.org.au> <1195988428.4149.225.camel@johannes.berg> <20071125112251.GA10039@gondor.apana.org.au> <1195998864.4149.229.camel@johannes.berg> <20071125140121.GA12665@gondor.apana.org.au> <1196010257.4149.234.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1196010257.4149.234.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 25, 2007 at 06:04:17PM +0100, Johannes Berg wrote:
>
> I'd think that totally depends on the traffic. If you have a non-QoS AP
> with WPS upstream connection, then the traffic to stations will be
> four-byte aligned while the WPS upstream will be at a 2-byte-mod-4
> boundary. And you'll have all packets from stations come in aligned and
> all response packets from wherever come in as WPS.

OK, sounds like you'll just have to fix them up after DMA.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
