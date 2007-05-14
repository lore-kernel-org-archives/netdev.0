From: David Miller <davem@davemloft.net>
Subject: Re: [IPSEC]: Don't warn if high-order hash resize fails
Date: Mon, 14 May 2007 02:17:46 -0700 (PDT)
Message-ID: <20070514.021746.17866513.davem@davemloft.net>
References: <20070514072657.GA24412@gondor.apana.org.au>
	<20070514072755.GB24412@gondor.apana.org.au>
	<20070514073941.GA24722@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44690
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754012AbXENJR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 May 2007 05:17:56 -0400
In-Reply-To: <20070514073941.GA24722@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 14 May 2007 17:39:41 +1000

> [IPSEC]: Check validity of direction in xfrm_policy_byid
> 
> The function xfrm_policy_byid takes a dir argument but finds the policy
> using the index instead.  We only use the dir argument to update the
> policy count for that direction.  Since the user can supply any value
> for dir, this can corrupt our policy count.
> 
> I know this is the problem because a few days ago I was deleting
> policies by hand using indicies and accidentally typed in the wrong
> direction.  It still deleted the policy and at the time I thought
> that was cool.  In retrospect it isn't such a good idea :)
> 
> I decided against letting it delete the policy anyway just in case
> we ever remove the connection between indicies and direction.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Good spotting, patch applied, thanks!
