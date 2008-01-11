From: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Subject: Re: handing cloned frames to netif_rx()?
Date: Sat, 12 Jan 2008 10:01:05 +1100
Message-ID: <20080111230105.GA32656@gondor.apana.org.au>
References: <E1JDSPG-0008Of-00@gondolin.me.apana.org.au> <1200092285.3528.5.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ron.rindjunsky-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1200092285.3528.5.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 11, 2008 at 11:58:05PM +0100, Johannes Berg wrote:
>
> Ok. Yes, we will of course adhere to that, but I was wondering whether
> maybe the net stack assumes somewhere that a packet it got from the
> driver can be written to w/o copying.

All parts of the rx stack support clone handling because they can always
run after another handler (e.g., AF_PACKET) which may have cloned the
packet.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
