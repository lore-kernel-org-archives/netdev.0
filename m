From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: fix fragmentation for ipv4 xfrm tunnel
Date: Tue, 17 Jun 2008 16:37:34 -0700 (PDT)
Message-ID: <20080617.163734.245281222.davem@davemloft.net>
References: <20080616125946.GE9886@secunet.com>
	<20080617044403.GA8825@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38285
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759087AbYFQXhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 19:37:33 -0400
In-Reply-To: <20080617044403.GA8825@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 17 Jun 2008 14:44:03 +1000

> On Mon, Jun 16, 2008 at 02:59:46PM +0200, Steffen Klassert wrote:
> > When generating the ip header for the transformed packet
> > we just copy the frag_off field of the ip header from the original packet
> > to the ip header of the new generated packet. If we receive a packet
> > as a chain of fragments, all but the last of the new generated packets
> > have the IP_MF flag set. We have to mask the frag_off field to only
> > keep the IP_DF flag from the original packet. This got lost with git commit
> > 
> > 36cf9acf93e8561d9faec24849e57688a81eb9c5
> > [IPSEC]: Separate inner/outer mode processing on output
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Good catch!
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, t hanks everyone.
