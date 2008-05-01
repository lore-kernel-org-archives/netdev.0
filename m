From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 03:34:14 -0700 (PDT)
Message-ID: <20080501.033414.132094744.davem@davemloft.net>
References: <20080430.145820.50450486.davem@davemloft.net>
	<E1JrVtK-0001pb-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752084AbYEAKeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:34:14 -0400
In-Reply-To: <E1JrVtK-0001pb-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 01 May 2008 18:19:54 +0800

> This patch completely breaks forwarding of GSO packets in a
> virtualised environment where we explicitly want to forward
> them as is to reduce per-packet overhead.  So if LRO is causing
> problems then I suggest we find a better way around that that
> does not penalise all forms of GSO.

I assume you mean forwarding via a bridge?

I think we'll need to add a device attribute for what
you want.

