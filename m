From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory corruption in 8390.c ? (was Re: Possible leaks in network drivers)
Date: Thu, 22 Jun 2006 19:02:27 +1000
Message-ID: <20060622090227.GA28367@gondor.apana.org.au>
References: <1150909982.15275.100.camel@localhost.localdomain> <E1FtDU0-0005nd-00@gondolin.me.apana.org.au> <20060622023029.GA6156@gondor.apana.org.au> <449A533E.4090201@pobox.com> <20060622082931.GA26083@gondor.apana.org.au> <449A5B83.4090104@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932536AbWFVJCz@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <449A5B83.4090104@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 04:57:39AM -0400, Jeff Garzik wrote:
>
> >>Non-linear skbs smaller than ETH_ZLEN seem unlikely.
> >
> >When I was grepping it seems that a few drivers were using it with
> >a length other than ETH_ZLEN.  I've just done another grep and here
> >are the potential suspects:
> >
> >cassini.c
> >starfire.c
> >yellowfin.c
> 
> That doesn't really invalidate the point :)  These drivers are still 
> only padding very small packets.

Hmm, at least cassini pads it to 255 for gigabit...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
