From: David Miller <davem@davemloft.net>
Subject: Re: [TCP]: Reset gso_segs if packet is dodgy
Date: Thu, 29 Jun 2006 20:11:51 -0700 (PDT)
Message-ID: <20060629.201151.112287022.davem@davemloft.net>
References: <20060630020044.GA28317@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:17634
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964940AbWF3DLw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 23:11:52 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060630020044.GA28317@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 30 Jun 2006 12:00:44 +1000

> [TCP]: Reset gso_segs if packet is dodgy
> 
> I wasn't paranoid enough in verifying GSO information.  A bogus gso_segs
> could upset drivers as much as a bogus header would.  Let's reset it in
> the per-protocol gso_segment functions.
> 
> I didn't verify gso_size because that can be verified by the source of
> the dodgy packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
