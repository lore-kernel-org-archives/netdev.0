From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9543] New: RTNL: assertion failed at net/ipv6/addrconf.c (2164)/RTNL: assertion failed at net/ipv4/devinet.c (1055)
Date: Sun, 16 Dec 2007 11:23:21 +0800
Message-ID: <20071216032321.GA1393@gondor.apana.org.au>
References: <bdfc5d6e0712150709k2dc0a845n84c494c519298f8d@mail.gmail.com> <E1J3jE4-0000FE-00@gondolin.me.apana.org.au> <bdfc5d6e0712151917k4adeaa34q3f498950883697ab@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: olel@ans.pl, fubar@us.ibm.com, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2528 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751140AbXLPDXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 22:23:48 -0500
Content-Disposition: inline
In-Reply-To: <bdfc5d6e0712151917k4adeaa34q3f498950883697ab@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 15, 2007 at 10:17:35PM -0500, Andy Gospodarek wrote:
>
> Not all of them in the bonding code, but all two of them in the small patch.

OK, we need to change all of the ones that may be called from
process context with BH on.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
