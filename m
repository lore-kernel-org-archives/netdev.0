From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] possible bug in inet->opt handling
Date: Sat, 16 Apr 2011 01:17:15 +0800
Message-ID: <20110415171715.GA5648@gondor.apana.org.au>
References: <1302881994.3613.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52286 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753998Ab1DORRX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2011 13:17:23 -0400
Content-Disposition: inline
In-Reply-To: <1302881994.3613.34.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 15, 2011 at 05:39:54PM +0200, Eric Dumazet wrote:
>
> My plan is to add RCU protection on inet->opt, unless someone has better
> idea ?

inet->opt is rarely non-NULL.  So perhaps just throw some locks
around the memcpy.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
