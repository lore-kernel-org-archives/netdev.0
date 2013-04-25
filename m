From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] GRE: Use IS_ERR_OR_NULL in gre_gso_segment
Date: Thu, 25 Apr 2013 17:03:46 +0800
Message-ID: <20130425090346.GA27618@gondor.apana.org.au>
References: <20130423075042.GA25776@verge.net.au>
 <CAEP_g=93aAXPk+A2u7LzAzEk6Fr33y7HiEMmXBCEkD8+B90kZQ@mail.gmail.com>
 <20130425084617.GA27463@gondor.apana.org.au>
 <20130425.050157.1080837692941670798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse@nicira.com, horms@verge.net.au, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xeb@mail.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36824 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752938Ab3DYJDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 05:03:55 -0400
Content-Disposition: inline
In-Reply-To: <20130425.050157.1080837692941670798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 25, 2013 at 05:01:57AM -0400, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 25 Apr 2013 16:46:17 +0800
> 
> > Perhaps add an wrapper for the IS_ERR_OR_NULL with a descriptive
> > name?
> 
> Or pick an error code for the case covered by NULL.

Picking an error code may create a maintainence problem down the
track because the same error code could be reused by something
deeper down in the GSO stack.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
