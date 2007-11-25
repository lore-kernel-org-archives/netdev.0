From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 22:01:21 +0800
Message-ID: <20071125140121.GA12665@gondor.apana.org.au>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au> <1195893216.4149.186.camel@johannes.berg> <20071124133200.GA27531@gondor.apana.org.au> <1195912176.4149.194.camel@johannes.berg> <20071124141319.GA27819@gondor.apana.org.au> <1195938799.4149.197.camel@johannes.berg> <20071125014446.GA32104@gondor.apana.org.au> <1195988428.4149.225.camel@johannes.berg> <20071125112251.GA10039@gondor.apana.org.au> <1195998864.4149.229.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1195998864.4149.229.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 25, 2007 at 02:54:24PM +0100, Johannes Berg wrote:
>
> But I do have a choice where to fix it up and I'd prefer the drivers to
> do it where necessary. For that, the warning would work because it'd
> show driver authors that they need to fix something.

Fair enough.

> Hmm. I don't think so. Take an AP for example. It gets a lot of packets
> from stations. Now, if you're not QoS capable then all is well. But i
> you are and some stations are as well then all those stations send QoS
> packets (+2 bytes). Or take an AP connected via wireless (WPS), WPS has
> +6 bytes so I get all incoming upstream traffic with such unaligned
> headers.

The question is does this actually change all the time.  Let's
say you took a random sample of a second worth of IP packets
over wireless, what proportion of them are going to have the
same hardware header length modulo 4?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
