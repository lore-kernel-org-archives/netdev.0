From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory corruption in 8390.c ? (was Re: Possible leaks in network drivers)
Date: Thu, 22 Jun 2006 19:12:29 +1000
Message-ID: <20060622091229.GA28488@gondor.apana.org.au>
References: <1150909982.15275.100.camel@localhost.localdomain> <E1FtDU0-0005nd-00@gondolin.me.apana.org.au> <20060622023029.GA6156@gondor.apana.org.au> <449A533E.4090201@pobox.com> <20060622082931.GA26083@gondor.apana.org.au> <449A5B83.4090104@pobox.com> <20060622090227.GA28367@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:32262 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161015AbWFVJMo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 05:12:44 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20060622090227.GA28367@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 07:02:27PM +1000, herbert wrote:
>
> > >cassini.c
> > >starfire.c
> > >yellowfin.c
> > 
> > That doesn't really invalidate the point :)  These drivers are still 
> > only padding very small packets.
> 
> Hmm, at least cassini pads it to 255 for gigabit...

The one in starfire looks especially dodgy.  It supports SG and also
requires the whole length to be a multiple of 4 if the firmware is
broken.  The question is do they really intend this or do they want
each fragment to terminate on a 4-byte boundary.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
