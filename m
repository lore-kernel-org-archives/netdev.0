From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Don't allow esn with disabled anti replay
 detection
Date: Tue, 10 May 2011 12:28:19 -0700 (PDT)
Message-ID: <20110510.122819.48494581.davem@davemloft.net>
References: <20110510054305.GC8013@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751850Ab1EJT2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 15:28:51 -0400
In-Reply-To: <20110510054305.GC8013@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Tue, 10 May 2011 07:43:05 +0200

> Unlike the standard case, disabled anti replay detection needs some
> nontrivial extra treatment on ESN. RFC 4303 states:
> 
> Note: If a receiver chooses to not enable anti-replay for an SA, then
> the receiver SHOULD NOT negotiate ESN in an SA management protocol.
> Use of ESN creates a need for the receiver to manage the anti-replay
> window (in order to determine the correct value for the high-order
> bits of the ESN, which are employed in the ICV computation), which is
> generally contrary to the notion of disabling anti-replay for an SA.
> 
> So return an error if an ESN state with disabled anti replay detection
> is inserted for now and add the extra treatment later if we need it.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Also applied, thanks for fixing these bugs!
