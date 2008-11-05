From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Fix ESP SA loading (by default)
Date: Wed, 5 Nov 2008 17:38:47 +0800
Message-ID: <20081105093847.GA21763@gondor.apana.org.au>
References: <20081101.213315.01349801.davem@davemloft.net> <20081103001643.GA22217@x200.localdomain> <20081103010431.GA29905@gondor.apana.org.au> <20081105.013148.156667310.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: adobriyan@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42709 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754356AbYKEJiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 04:38:54 -0500
Content-Disposition: inline
In-Reply-To: <20081105.013148.156667310.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 05, 2008 at 01:31:48AM -0800, David Miller wrote:
>
> As we've discussed several times it's not "passing" errors
> that sucks, it's the fact that we use the same traditional
> UNIX error codes for a thousand different errors. :-)

Right.

> I really think we should explore the idea where the current
> process can get tagged with a string when an error is going
> to be returned.  Something like:
> 
> 	const char *error_desc;
> 
> in the task_struct.

Yes this will be heaps better than what we have now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
