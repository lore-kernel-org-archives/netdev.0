From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH RFC] inetpeer: Support ipv6 addresses.
Date: Sun, 28 Mar 2010 21:59:31 +0800
Message-ID: <20100328135931.GA16430@gondor.apana.org.au>
References: <20100328082250.GA14053@gondor.apana.org.au> <20100328.055312.58421329.davem@davemloft.net> <20100328131112.GA15984@gondor.apana.org.au> <20100328.064012.193708716.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:46628 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754610Ab0C1N7h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Mar 2010 09:59:37 -0400
Content-Disposition: inline
In-Reply-To: <20100328.064012.193708716.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 28, 2010 at 06:40:12AM -0700, David Miller wrote:
>
> Same for all the other metrics at the TCP level.

I don't think they are quite the same.  The TCP time stamp is
an attribute of the destination host, it doesn't vary depending
on which route you take to reach the host.  The MTU on the other
hand is an attribute of the route that reaches the host.

BTW, it appears that the inetpeer cache doesn't take namespaces
into account.  This means that information could potentially leak
from one namespace into another.  I'm not sure whether that's a
big deal or not but it's something for the namespaces folks to
consider.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
