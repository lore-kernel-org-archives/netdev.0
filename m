From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [patch 7/9] lguest: the net driver
Date: Wed, 9 May 2007 22:00:30 +1000
Message-ID: <20070509120030.GA12853@gondor.apana.org.au>
References: <E1HljA6-0001E4-00@gondolin.me.apana.org.au> <1178711725.7286.82.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, ak@suse.de, jeff@garzik.org,
	jmorris@namei.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2543 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755285AbXEIMBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 08:01:07 -0400
Content-Disposition: inline
In-Reply-To: <1178711725.7286.82.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rusty:

On Wed, May 09, 2007 at 09:55:25PM +1000, Rusty Russell wrote:
> 
> 	NO_CSUM because it really doesn't need a checksum.  The
> LGUEST_NET_F_NOCSUM is only set for local inter-guest networking.  If
> some guest were to route the packets outside the machine, this would be
> an issue, though ("don't do that").

While I can see that this is good in keeping things simple, I think
it's something that you want to be able to support since the user
may wish to setup a guest as a firewall appliance which would involve
passing packets from another guest to the outside world.
 
> Indeed, that would be a new feature, and is certainly a consideration
> for more efficient inter-guest networking.  However, I consider that
> somewhat cheating: it's nice to know that 1500 doesn't suck too hard.
> 
> Remember, "Features kill puppies!" 8)

Heh :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
