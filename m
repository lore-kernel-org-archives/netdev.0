From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix xfrm hash collisions by changing
 __xfrm4_daddr_saddr_hash to hash addresses with addition
Date: Wed, 12 Aug 2009 20:56:35 -0700 (PDT)
Message-ID: <20090812.205635.244644770.davem@davemloft.net>
References: <20090813020606.GA18205@gondor.apana.org.au>
	<20090812.204247.183387787.davem@davemloft.net>
	<20090813035310.GA19182@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joamaki@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752715AbZHMD4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 23:56:24 -0400
In-Reply-To: <20090813035310.GA19182@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Aug 2009 13:53:10 +1000

> Take corporate VPN servers for instance.  Yes each client is
> trusted to the extent that it is being offered connectivity to
> the corporate network.  However, it would not be ideal if one
> rogue client can take down the entire VPN server, especially
> in this case because repeatedly creating identical SAs can often
> occur purely by accident.

1) The client is on your private network, much more serious
   mischief is possible.

2) Whoever creates such a hash collision explosion can be
   precisely identified.

The ikev1 failure case is an interesting situation I hadn't
considered.

Maybe that can matter, but again the guilty party is easy to identify
and easy to block via whatever means appropriate.
