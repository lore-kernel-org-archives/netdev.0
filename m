From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Namespaces and inetpeer
Date: Mon, 12 Mar 2012 23:11:30 +1100
Message-ID: <20120312121130.GA17547@gondor.apana.org.au>
References: <20120310132529.GA3631@gondor.apana.org.au> <20120312085756.GL15404@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:54596 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754745Ab2CLMLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 08:11:36 -0400
Content-Disposition: inline
In-Reply-To: <20120312085756.GL15404@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 12, 2012 at 09:57:56AM +0100, Steffen Klassert wrote:
>
> Actually, it would be nice if we could have an inetpeer base per
> fib table. This would imply namespace awareness and it would
> handle the problem when we have mulitiple routes (with different
> metrics etc.) to the same ip address on policy routing.

How would you handle incoming ICMP need-to-frag messages?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
