From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/24] [IPSEC]: Forbid BEET + ipcomp for now
Date: Tue, 13 Nov 2007 21:39:18 -0800 (PST)
Message-ID: <20071113.213918.51461693.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1Ipla0-0001HT-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45831
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758813AbXKNFjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:39:19 -0500
In-Reply-To: <E1Ipla0-0001HT-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:28 +0800

> [IPSEC]: Forbid BEET + ipcomp for now
> 
> While BEET can theoretically work with IPComp the current code can't do that
> because it tries to construct a BEET mode tunnel type which doesn't (and
> cannot) exist.  In fact as it is it won't even attach a tunnel object at
> all for BEET which is bogus.
> 
> To support this fully we'd also need to change the policy checks on input
> to recognise a plain tunnel as a legal variant of an optional BEET transform.
> 
> This patch simply fails such constructions for now.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
