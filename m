From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Disable forwarding of LRO skbs
Date: Thu, 01 May 2008 03:52:04 -0700 (PDT)
Message-ID: <20080501.035204.147190700.davem@davemloft.net>
References: <20080501.033414.132094744.davem@davemloft.net>
	<20080501103854.GA7285@gondor.apana.org.au>
	<20080501104517.GA7390@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, kmansley@solarflare.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54980
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754505AbYEAKwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2008 06:52:05 -0400
In-Reply-To: <20080501104517.GA7390@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 1 May 2008 18:45:17 +0800

> On Thu, May 01, 2008 at 06:38:54PM +0800, Herbert Xu wrote:
> > 
> > I still don't understand why we can't forward LRO packets.  It
> > should be no different to forwarding GSO packets if it's properly
> > constructed.
> 
> Nevermind, doing LRO on forwarded traffic is fundamentally broken
> because it breaks the end-to-end connection.

Ok, that brings us back to your virtualization issues.
