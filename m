From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Patch for tbench regression.
Date: Mon, 29 Sep 2008 08:34:50 -0500
Message-ID: <48E0D97A.8000305@linux-foundation.org>
References: <20080928211530.GA9341@2ka.mipt.ru> <20080929031244.GA22619@gondor.apana.org.au> <20080929053605.GA21663@2ka.mipt.ru> <20080929054052.GA23600@gondor.apana.org.au> <20080929055203.GA3460@2ka.mipt.ru> <20080929064006.GA23967@gondor.apana.org.au> <20080929064518.GA10653@2ka.mipt.ru> <20080929070213.GA24146@gondor.apana.org.au> <20080929094352.GA25273@gondor.apana.org.au> <20080929103437.GD14943@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	Mel Gorman <mel@csn.ul.ie>, David Miller <davem@davemloft.net>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:59458 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910AbYI2Ngw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 09:36:52 -0400
In-Reply-To: <20080929103437.GD14943@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some graphs of the time that each pass through the network stack takes
and from what I see we still have measurements where we get the optimal
performance with 2.6.27 that 2.6.22 does. However, the time differentials vary
much more with 2.6.27. 2.6.22 times results cluster around the minimum. 2.6.27
has periods where the time increases by around 30usec. It dips down repeatedly
to 2.6.22 performance.

