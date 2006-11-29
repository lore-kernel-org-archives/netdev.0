From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Broken commit: [NETFILTER]: ipt_REJECT: remove largely duplicate route_reverse function
Date: Wed, 29 Nov 2006 15:56:57 +1100
Message-ID: <E1GpHVB-0005CB-00@gondolin.me.apana.org.au>
References: <20061128.204440.39160464.davem@davemloft.net>
Cc: herbert@gondor.apana.org.au, kaber@trash.net, khc@pm.waw.pl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47886 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S933397AbWK2E5K
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 23:57:10 -0500
To: davem@davemloft.net (David Miller)
In-Reply-To: <20061128.204440.39160464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Longer term this is really messy, we should handle this some
> other way.

Definitely.  I'm not sure whether 48 is enough even for recursive
tunnels.  This should really just be a hint.  It's OK to spend a
bit of time reallocating skb's if it's too small, but it's not OK
to die.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
