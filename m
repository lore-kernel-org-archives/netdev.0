From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 6/7] [IPSEC]: Lock state when copying non-atomic fields to user-space
Date: Wed, 10 Oct 2007 08:48:22 +0800
Message-ID: <20071010004822.GB25265@gondor.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au> <E1IfGCK-0005ML-00@gondolin.me.apana.org.au> <20071009.133307.88477317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1779 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753333AbXJJAsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 20:48:24 -0400
Content-Disposition: inline
In-Reply-To: <20071009.133307.88477317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 09, 2007 at 01:33:07PM -0700, David Miller wrote:
>
> I would be more careful with the changelog description for
> something like this in the future.  It sounds like this
> patch will cause us to touch userspace with locks held,
> which obviously only works in very limited scenerios
> and is usually a BUG.
> 
> But you're actually just constructing SKB response netlink
> bits, which later will be copied into userspace but long
> after we've released these locks.

Good point.  I should've said skb destined for user-spac

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
