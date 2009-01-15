From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen/netfront: do not mark packets of length < MSS as
 GSO
Date: Wed, 14 Jan 2009 20:41:27 -0800 (PST)
Message-ID: <20090114.204127.247304876.davem@davemloft.net>
References: <20090114041845.GA8881@gondor.apana.org.au>
	<1231930752.4078.18.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, jeremy@goop.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54988
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755380AbZAOEl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 23:41:26 -0500
In-Reply-To: <1231930752.4078.18.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Campbell <Ian.Campbell@citrix.com>
Date: Wed, 14 Jan 2009 10:59:12 +0000

> On Wed, 2009-01-14 at 15:18 +1100, Herbert Xu wrote:
> > gso: Ensure that the packet is long enough
> > 
> > When we get a GSO packet from an untrusted source, we need to
> > ensure that it is sufficiently long so that we don't end up
> > crashing.
> > 
> > Based on discovery and patch by Ian Campbell.
> > 
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Looks good, thanks.
> 
> Tested-by: Ian Campbell <ian.campbell@citrix.com>

Applied, thanks everyone.
