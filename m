From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sat, 24 Nov 2007 14:15:05 +0800
Message-ID: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
References: <1195850001.4149.165.camel@johannes.berg>
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org (Johannes Berg)
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1195850001.4149.165.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
>
> Now, the IP stack actually assumes that its header is four-byte aligned
> (see comment at NET_IP_ALIGN, although it is not said explicitly that
> the alignment requirement for an IP header is four) so that is actually
> something for the hardware/firmware (!) to do, for example Broadcom

Good point.  In fact IIRC we've always had the policy that drivers
should do their best to generate aligned packets but it is not a
requirement since on some platforms it's more important for the DMA
to be aligned.

So it's up the platform code to fix up any exceptions should they
show up.

Daniel, what's the specific case that you had in mind with this
patch?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
