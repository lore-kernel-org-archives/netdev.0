From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] bd4265fe36 bridge: Only flood unreg groups... breaks
	DHCP setup
Date: Wed, 6 Jul 2011 13:08:48 +0800
Message-ID: <20110706050848.GA7564@gondor.apana.org.au>
References: <20110705204200@it-loops.com> <20110705235833.GA5599@gondor.apana.org.au> <20110705.184044.1261486363010308552.davem@davemloft.net> <20110705220636.6afeb81c@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mike@it-loops.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:55868 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738Ab1GFFIz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2011 01:08:55 -0400
Content-Disposition: inline
In-Reply-To: <20110705220636.6afeb81c@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 05, 2011 at 10:06:36PM -0700, Stephen Hemminger wrote:
> On Tue, 05 Jul 2011 18:40:44 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Herbert Xu <herbert@gondor.hengli.com.au>
> > Date: Wed, 6 Jul 2011 07:58:33 +0800
> > 
> > > bridge: Always flood broadcast packets
> > > 
> > > As is_multicast_ether_addr returns true on broadcast packets as
> > > well, we need to explicitly exclude broadcast packets so that
> > > they're always flooded.  This wasn't an issue before as broadcast
> > > packets were considered to be an unregistered multicast group,
> > > which were always flooded.  However, as we now only flood such
> > > packets to router ports, this is no longer acceptable.
> > > 
> > > Reported-by: Michael Guntsche <mike@it-loops.com>
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > Applied.
> 
> Obviously needs to go to stable as well.

I don't think the buggy patch has made it to a release kernel
yet.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
