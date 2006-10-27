From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.18 forcedeth GSO panic on send
Date: Fri, 27 Oct 2006 13:58:58 +1000
Message-ID: <20061027035858.GA11129@gondor.apana.org.au>
References: <200610270117.57877.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:11015 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1423748AbWJ0D7h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 23:59:37 -0400
To: Denis Vlasenko <vda.linux@googlemail.com>
Content-Disposition: inline
In-Reply-To: <200610270117.57877.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 26, 2006 at 11:17:57PM +0000, Denis Vlasenko wrote:
> 
> I am using an AMD64 box with 32bit userspace / 64bit kernel.
> 
> Kernels 2.6.18 and 2.6.18.1 semi-randomly hang when I upload stuff
> over the net - for example, "svn commit", scp are affected.
> 2.6.17.11 does not seem to be affected.
> 
> Unfortunately even 60-line screen is not big enough
> to catch whole trace. There are at least two traces,
> and first scrolls off. I have a photo at
> http://busybox.net/~vda/gso_panic/forcedeth_gso_panic.jpg

Looks like a network stack bug rather than a driver problem.
However, I'd really like to see the first oops including the
print out from skb_over_panic.

Could you try booting with pause_on_oops=1 or perhaps use a
serial console?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
