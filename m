From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netpoll checksum issue
Date: Sun, 23 Apr 2006 21:34:32 +1000
Message-ID: <20060423113432.GA16424@gondor.apana.org.au>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com> <20060419103153.64ef0054@localhost.localdomain> <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4877 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751379AbWDWLek
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 07:34:40 -0400
To: Aubrey <aubreylee@gmail.com>
Content-Disposition: inline
In-Reply-To: <6d6a94c50604191854m73b241e3v104d713b7bb93674@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 20, 2006 at 09:54:54AM +0800, Aubrey wrote:
>
> Hi Herbert - I'm working on blackfin uclinux platform. My network
> driver is for blackfin on-chip EMAC. Of course it's open source, but
> so far it's not committed into mainline tree. We can be found at here:
> http://www.blackfin.uclinux.org

Please send me a copy of the driver source that you were using when
this happened.

> My driver didn't assign any value to skb->ip_summed,  and didn't
> define tx/rx checksum routine like "e1000_rx_checksum", but it did
> work before on 2.6.12. I'm trying to find what's broken.

Could you please add a printk in checksum_udp to print out the pertinent
values such as the expected checksum and actual checksum?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
