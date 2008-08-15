From: David Miller <davem@davemloft.net>
Subject: Re: ipv4: Disable route secret interval on zero interval
Date: Fri, 15 Aug 2008 13:45:14 -0700 (PDT)
Message-ID: <20080815.134514.199978423.davem@davemloft.net>
References: <20080814082702.GA32676@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbYHOUpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 16:45:13 -0400
In-Reply-To: <20080814082702.GA32676@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 14 Aug 2008 18:27:02 +1000

> ipv4: Disable route secret interval on zero interval
> 
> Let me first state that disabling the route cache hash rebuild
> should not be done without extensive analysis on the risk profile
> and careful deliberation.
> 
> However, there are times when this can be done safely or for
> testing.  For example, when you have mechanisms for ensuring
> that offending parties do not exist in your network.
> 
> This patch lets the user disable the rebuild if the interval is
> set to zero.  This also incidentally fixes a divide-by-zero error
> with name-spaces.
> 
> In addition, this patch makes the effect of an interval change
> immediate rather than it taking effect at the next rebuild as
> is currently the case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
