From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Deadlock with icmpv6fuzz
Date: Wed, 25 Feb 2009 16:25:43 +0800
Message-ID: <20090225082543.GB809@gondor.apana.org.au>
References: <20090206.030716.136181382.davem@davemloft.net> <20090209050354.GA3548@gondor.apana.org.au> <20090224.234401.257258567.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdreier@cisco.com, snakebyte@gmx.de, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42377 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751163AbZBYIZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 03:25:59 -0500
Content-Disposition: inline
In-Reply-To: <20090224.234401.257258567.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2009 at 11:44:01PM -0800, David Miller wrote:
>
> Actually it turns out we can't do that here.  This flow label object
> is global, rather than specifically associated with a given socket.
> 
> See net/ipv6/ip6_flowlabel.c:fl_{create,intern}() and how those
> are used.

They're global but that doesn't stop us from charging it once
for each socket that uses it (isn't that what Microsoft does
for Windows :)

The fact is right now we have an entity that a user can create
willy nilly with no limits.  That can't be good.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
