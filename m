From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks
 DHCP setup
Date: Tue, 05 Jul 2011 18:40:44 -0700 (PDT)
Message-ID: <20110705.184044.1261486363010308552.davem@davemloft.net>
References: <20110705204200@it-loops.com>
	<20110705235833.GA5599@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mike@it-loops.com, netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51038 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654Ab1GFBkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 21:40:53 -0400
In-Reply-To: <20110705235833.GA5599@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Wed, 6 Jul 2011 07:58:33 +0800

> bridge: Always flood broadcast packets
> 
> As is_multicast_ether_addr returns true on broadcast packets as
> well, we need to explicitly exclude broadcast packets so that
> they're always flooded.  This wasn't an issue before as broadcast
> packets were considered to be an unregistered multicast group,
> which were always flooded.  However, as we now only flood such
> packets to router ports, this is no longer acceptable.
> 
> Reported-by: Michael Guntsche <mike@it-loops.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
