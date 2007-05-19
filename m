From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][af_key]pfkey_add: Optimize SA adds and algorithm probes
Date: Sat, 19 May 2007 14:21:40 -0700 (PDT)
Message-ID: <20070519.142140.115640764.davem@davemloft.net>
References: <4643CD64.4090000@mvista.com>
	<E1HouAO-0003i5-00@gondolin.me.apana.org.au>
	<20070518212148.GA25363@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mhuth@mvista.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57169
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755791AbXESVVi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2007 17:21:38 -0400
In-Reply-To: <20070518212148.GA25363@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 19 May 2007 07:21:48 +1000

> On Fri, May 18, 2007 at 02:34:12PM +1000, Herbert Xu wrote:
> > 
> > Actually, I think we should just probe for the specific algorithm
> > requested rather than everything.  See patch below.
> 
> Doh, forgot to actually remove the probe call :)
> 
> [IPSEC] pfkey: Load specific algorithm in pfkey_add rather than all
> 
> This is a natural extension of the changeset
> 
>     [XFRM]: Probe selected algorithm only.
> 
> which only removed the probe call for xfrm_user.  This patch does exactly
> the same thing for af_key.  In other words, we load the algorithm requested
> by the user rather than everything when adding xfrm states in af_key.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
