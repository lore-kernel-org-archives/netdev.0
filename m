From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 10/11] [IPSEC]: Disallow combinations of RO and
 AH/ESP/IPCOMP
Date: Wed, 17 Oct 2007 21:35:23 -0700 (PDT)
Message-ID: <20071017.213523.58458049.davem@davemloft.net>
References: <20071017142940.GA23879@gondor.apana.org.au>
	<E1Ii9yU-0006Hr-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56798
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbXJREf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 00:35:29 -0400
In-Reply-To: <E1Ii9yU-0006Hr-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 17 Oct 2007 22:34:18 +0800

> [IPSEC]: Disallow combinations of RO and AH/ESP/IPCOMP
> 
> Combining RO and AH/ESP/IPCOMP does not make sense.  So this patch adds a
> check in the state initialisation function to prevent this.
> 
> This allows us to safely remove the mode input function of RO since it
> can never be called anymore.  Indeed, if somehow it does get called we'll
> know about it through an OOPS instead of it slipping past silently.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
