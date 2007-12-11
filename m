From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPSEC]: Added xfrm_decode_session_reverse and
 xfrmX_policy_check_reverse
Date: Tue, 11 Dec 2007 09:09:27 -0800 (PST)
Message-ID: <20071211.090927.48689392.davem@davemloft.net>
References: <20071211165317.GA16420@gondor.apana.org.au>
	<E1J28Np-0004IK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40681
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751983AbXLKRJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 12:09:27 -0500
In-Reply-To: <E1J28Np-0004IK-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Dec 2007 00:55:01 +0800

> [IPSEC]: Added xfrm_decode_session_reverse and xfrmX_policy_check_reverse
> 
> RFC 4301 requires us to relookup ICMP traffic that does not match any
> policies using the reverse of its payload.  This patch adds the functions
> xfrm_decode_session_reverse and xfrmX_policy_check_reverse so we can get
> the reverse flow to perform such a lookup.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I suspect you generated this against a tree with your async
crypto bits in it, because there were a bunch of line offsets
when I applied this.

Nevertheless I fixed it up, patch applied, thanks.
