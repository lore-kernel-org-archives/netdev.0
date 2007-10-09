From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] [IPSEC]: Remove bogus ref count in
 xfrm_secpath_reject
Date: Tue, 09 Oct 2007 13:24:19 -0700 (PDT)
Message-ID: <20071009.132419.48798717.davem@davemloft.net>
References: <20071009143517.GA20486@gondor.apana.org.au>
	<E1IfGCF-0005Lh-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58344
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752628AbXJIUYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 16:24:19 -0400
In-Reply-To: <E1IfGCF-0005Lh-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 09 Oct 2007 22:36:31 +0800

> [IPSEC]: Remove bogus ref count in xfrm_secpath_reject
> 
> Constructs of the form
> 
> 	xfrm_state_hold(x);
> 	foo(x);
> 	xfrm_state_put(x);
> 
> tend to be broken because foo is either synchronous where this is totally
> unnecessary or if foo is asynchronous then the reference count is in the
> wrong spot.
> 
> In the case of xfrm_secpath_reject, the function is synchronous and therefore
> we should just kill the reference count.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks!
