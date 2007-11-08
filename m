From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Fwd: Re: [PATCH] iSCSI fix endieness of digest to be network
 byte order
Date: Thu, 08 Nov 2007 10:47:44 -0500
Message-ID: <47332FA0.2020405@hp.com>
References: <47320C54.10406@panasas.com> <20071108011849.GA12428@gondor.apana.org.au> <20071108170409B.fujita.tomonori@lab.ntt.co.jp> <20071108104040.GA16312@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>,
	bhalevy@panasas.com, linux-crypto@vger.kernel.org,
	michaelc@cs.wisc.edu, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:60929 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759511AbXKHPrr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Nov 2007 10:47:47 -0500
In-Reply-To: <20071108104040.GA16312@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Nov 08, 2007 at 05:04:09PM +0900, FUJITA Tomonori wrote:
>> I wonder why crc32c isn't used directly while crc32 is used directly
>> since they vary by only the polynomial.
> 
> It's because iSCSI uses it with scatterlists.  The crypto layer
> provides a nice interface for that while using it directly would
> require the user to do the scatterlist walk.
> 
>> Using crc32c directly might enable us to kill net/sctp/crc32c.c and
>> merge lib/crc32.c and lib/libcrc32c?
> 
> I'm pretty sure we can kill net/sctp/crc32c.c today by converting
> it over to use the crypto interface.


Funny, I looked for crc32c in the lib just the other week and didn't spot
it.  Need to look harder :)

-vlad
