From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 20/31]: pkt_sched: Perform bulk of qdisc destruction in
 RCU.
Date: Fri, 22 Aug 2008 00:16:20 -0700 (PDT)
Message-ID: <20080822.001620.141235108.davem@davemloft.net>
References: <20080721.100821.38432201.davem@davemloft.net>
	<20080721171141.GA13573@gondor.apana.org.au>
	<20080822065655.GA18471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, kaber@trash.net, netdev@vger.kernel.org,
	johannes@sipsolutions.net, linux-wireless@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33337
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750926AbYHVHQW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2008 03:16:22 -0400
In-Reply-To: <20080822065655.GA18471@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 22 Aug 2008 16:56:55 +1000

... Storing initial TXQ assignment in dst entry idea ...

> Of course to make this work we need to restart the flow cache
> project so that we have somewhere to store this txq assignment.
> 
> The good thing is that a flow cache would be of benefit for IPsec
> users too and I hear that there is some interest in doing that
> in the immediate future.  So perhaps we can combine efforts and
> use it for txq assignment as well.

IPSEC already has a flow cache doesn't it? :)

I suppose you're talking about the grand unified flow cache
that never gets implemented right?  I classify that in the
same category as net channels at the moment, theoretically
very interesting but no practical implementation in sight.
