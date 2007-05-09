From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [patch 7/9] lguest: the net driver
Date: Wed, 09 May 2007 22:13:28 +1000
Message-ID: <1178712808.7286.92.camel@localhost.localdomain>
References: <E1HljA6-0001E4-00@gondolin.me.apana.org.au>
	 <1178711725.7286.82.camel@localhost.localdomain>
	 <20070509120030.GA12853@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	virtualization@lists.osdl.org, ak@suse.de, jeff@garzik.org,
	jmorris@namei.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36155 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755002AbXEIMNp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 08:13:45 -0400
In-Reply-To: <20070509120030.GA12853@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-05-09 at 22:00 +1000, Herbert Xu wrote:
> Hi Rusty:
> 
> On Wed, May 09, 2007 at 09:55:25PM +1000, Rusty Russell wrote:
> > 
> > 	NO_CSUM because it really doesn't need a checksum.  The
> > LGUEST_NET_F_NOCSUM is only set for local inter-guest networking.  If
> > some guest were to route the packets outside the machine, this would be
> > an issue, though ("don't do that").
> 
> While I can see that this is good in keeping things simple, I think
> it's something that you want to be able to support since the user
> may wish to setup a guest as a firewall appliance which would involve
> passing packets from another guest to the outside world.

Indeed, you understand the tradeoff.  The example launcher could have an
option not to set the LGUEST_NET_F_NOCSUM in this case.

That said, one significant purpose of lguest is to serve as an example
of how to do things.  So if you feel really strongly that there's a
Right Way, we could look at the patch...

Thanks,
Rusty.


