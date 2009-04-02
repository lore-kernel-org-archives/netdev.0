From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Thu, 2 Apr 2009 23:09:08 +0800
Message-ID: <20090402150908.GA1382@gondor.apana.org.au>
References: <20090304.030044.163418715.davem@davemloft.net> <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au> <49D4CECA.3010703@trash.net> <20090402144549.GA764@gondor.apana.org.au> <49D4D260.6020809@trash.net> <20090402145952.GA1276@gondor.apana.org.au> <49D4D480.9030306@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59936 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758330AbZDBPJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:09:23 -0400
Content-Disposition: inline
In-Reply-To: <49D4D480.9030306@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 05:06:40PM +0200, Patrick McHardy wrote:
>
> Yes, that should always work. For new stuff I think we should try
> to avoid encapsulating larger structures in single attributes though
> since it forces us to do copy everything, instead of just the types
> that really require it (and the padding issues in case of at least
> non-priviledged interfaces).

Are there any situations where we want to use a struct? Perhaps
we can just ban it altogether for new code?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
