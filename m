From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Accept ESP packets regardless of UDP
 encapsulation mode
Date: Wed, 17 Dec 2008 20:17:55 -0800 (PST)
Message-ID: <20081217.201755.11960524.davem@davemloft.net>
References: <20081217.194942.01082060.davem@davemloft.net>
	<20081218035758.GA31610@gondor.apana.org.au>
	<20081218041419.GA11722@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: martin@strongswan.org, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35845
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751150AbYLRERx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 23:17:53 -0500
In-Reply-To: <20081218041419.GA11722@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 15:14:19 +1100

> A quick google failed to reveal any specific requirements apart
> from the need to move in and out of NAT environments.
> 
> That isn't actually an issue because when your addresses change
> you have to renegotiate with the other side to ensure that this
> isn't some kind of an attack.  Afterwards you have to recreate
> the SAs at which point you can easily set the encapsulation to
> whatever it should be.
> 
> The only time when you need this patch is if the other side
> unilaterally switched from NAT-T to no NAT-T, or vice versa,
> which does not sound like a sane thing to do.

My interpretation of the situation is that when you change (address or
NAT-T) you still have to perform the renegotiation over the old SA.

Or something like that.
