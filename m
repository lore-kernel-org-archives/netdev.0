From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Tue, 15 Dec 2009 22:42:52 +0800
Message-ID: <20091215144252.GA7465@gondor.apana.org.au>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091213122512.GA17255@gondor.apana.org.au> <20091213234055.GA28340@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43616 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751713AbZLOOnN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2009 09:43:13 -0500
Content-Disposition: inline
In-Reply-To: <20091213234055.GA28340@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 01:40:55AM +0200, Michael S. Tsirkin wrote:
>
> An interesting thing is that
> 48925e372f04f5e35fec6269127c62b2c71ab794
> was supposed to do this already.

But Rusty missed the queue wake call.  That too needs to check
that the required amount of space exists.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
