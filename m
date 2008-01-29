From: David Miller <davem@davemloft.net>
Subject: Re: [INET]: Prevent out-of-sync truesize on ip_fragment slow path
Date: Mon, 28 Jan 2008 20:45:54 -0800 (PST)
Message-ID: <20080128.204554.63558184.davem@davemloft.net>
References: <20080128111259.GA6490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752500AbYA2Eph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 23:45:37 -0500
In-Reply-To: <20080128111259.GA6490@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 28 Jan 2008 22:12:59 +1100

> Hi:
> 
> [INET]: Prevent out-of-sync truesize on ip_fragment slow path
> 
> When ip_fragment has to hit the slow path the value of skb->truesize
> may go out of sync because we would have updated it without changing
> the packet length.  This violates the constraints on truesize.
> 
> This patch postpones the update of skb->truesize to prevent this.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, I'll queue this up for 2.6.24-stable too.
