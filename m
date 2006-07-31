From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Mon, 31 Jul 2006 20:59:43 +1000
Message-ID: <20060731105943.GA26114@gondor.apana.org.au>
References: <20060731103322.GA1898@2ka.mipt.ru> <E1G7V7r-0006jL-00@gondolin.me.apana.org.au> <20060731105037.GA2073@2ka.mipt.ru> <20060731.035716.39159213.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, drepper@redhat.com, zach.brown@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:20241 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932146AbWGaK7y
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 06:59:54 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060731.035716.39159213.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 03:57:16AM -0700, David Miller wrote:
> 
> So I would say for up to 4 or 5 events, system call overhead alone
> touches as many cache lines as the events themselves.

Absolutely.

The other to consider is that events don't come from the hardware.
Events are written by the kernel.  So if user-space is just reading
the events that we've written, then there are no cache misses at all.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
