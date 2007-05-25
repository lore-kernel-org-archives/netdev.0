From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Fri, 25 May 2007 10:20:14 +1000
Message-ID: <20070525002014.GA16642@gondor.apana.org.au>
References: <4643CD64.4090000@mvista.com> <E1HouAO-0003i5-00@gondolin.me.apana.org.au> <20070518212148.GA25363@gondor.apana.org.au> <46562AA2.8030102@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Mark Huth <mhuth@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1230 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752676AbXEYAUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 20:20:49 -0400
Content-Disposition: inline
In-Reply-To: <46562AA2.8030102@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 24, 2007 at 05:15:30PM -0700, Mark Huth wrote:
> 
> I'm a bit curious why all of the crypto modules got loaded, but it 
> doesn't matter.

If anybody does a PFKEY_REGISTER call then all the algorithms will get
loaded so that the key manager can find out what algorithms are actually
available.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
