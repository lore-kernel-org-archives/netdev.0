From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Thu, 2 Apr 2009 22:45:49 +0800
Message-ID: <20090402144549.GA764@gondor.apana.org.au>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au> <49D4CECA.3010703@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52187 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756178AbZDBOqD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 10:46:03 -0400
Content-Disposition: inline
In-Reply-To: <49D4CECA.3010703@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 04:42:18PM +0200, Patrick McHardy wrote:
>
> Actually we should be fine since the current netlink helpers only do
> bytewise copying anyways. And I think we've pretty much gotten rid of
> all the raw attribute accesses.

What about stuff like xfrm_userpolicy_info? I suppose if *everything*
is copied then it wouldn't matter.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
