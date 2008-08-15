From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 11316] New: severe performance regression for iptables nat routing
Date: Fri, 15 Aug 2008 14:34:50 +1000
Message-ID: <E1KTr1W-0001WZ-00@gondolin.me.apana.org.au>
References: <20080813.192101.221940876.davem@davemloft.net>
Cc: alex.williamson@hp.com, akpm@linux-foundation.org,
	buytenh@marvell.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, kaber@trash.net
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33925 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750928AbYHOEfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 00:35:03 -0400
In-Reply-To: <20080813.192101.221940876.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
>
> Patrick I wonder if there a case where iptables NAT will COW the packet
> when it really doesn't need to.

This doesn't make sense.  He's downloading from a remote host, so
GSO shouldn't even come into play.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
