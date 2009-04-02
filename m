From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Patch 4/5] Network Drop Monitor: Adding drop monitor
	implementation & Netlink protocol
Date: Thu, 2 Apr 2009 23:30:42 +0800
Message-ID: <20090402153042.GB1670@gondor.apana.org.au>
References: <20090402093952.GA30553@gondor.apana.org.au> <20090402.025223.242893473.davem@davemloft.net> <20090402095957.GA30799@gondor.apana.org.au> <49D4CECA.3010703@trash.net> <20090402144549.GA764@gondor.apana.org.au> <49D4D260.6020809@trash.net> <20090402145952.GA1276@gondor.apana.org.au> <49D4D480.9030306@trash.net> <20090402150908.GA1382@gondor.apana.org.au> <49D4D66A.50101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, nhorman@tuxdriver.com,
	zbr@ioremap.net, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37536 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750799AbZDBPaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:30:55 -0400
Content-Disposition: inline
In-Reply-To: <49D4D66A.50101@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 02, 2009 at 05:14:50PM +0200, Patrick McHardy wrote:
>
> I'd prefer that as well. The only reason to do this is to save a few
> bytes and cycles for attribute encapsulation. I don't think this
> matters at all, judging by the fact that I've never seen a userspace
> implementation using message batching, the current users don't seem
> to care about performance *that* much.

OK, let's all just keep an eye out for new struct users and see
how it goes.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
