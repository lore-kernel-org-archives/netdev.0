From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Wed, 9 Apr 2014 01:23:49 +0800
Message-ID: <20140408172349.GA7147@gondor.apana.org.au>
References: <20140407075347.GA26461@gondor.apana.org.au>
 <E1WX4P2-0006wA-9Q@gondolin.me.apana.org.au>
 <1396879662.12330.63.camel@edumazet-glaptop2.roam.corp.google.com>
 <20140407142334.GA28814@gondor.apana.org.au>
 <53442868.3090701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:59877 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754579AbaDHRXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 13:23:54 -0400
Content-Disposition: inline
In-Reply-To: <53442868.3090701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 08, 2014 at 09:48:40AM -0700, Ben Greear wrote:
> 
> At least for ARPs, maybe we could inspect the packet and only
> deliver to interfaces configured with the MAC that is being
> ARPed for (or ones that are in promisc)?

Yes this would definitely be a great optimisation.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
