From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 3/3] xfrm4: Invalidate all ipv4 routes on IPsec pmtu
 events
Date: Mon, 21 Jan 2013 07:48:37 +0100
Message-ID: <20130121064837.GB30530@secunet.com>
References: <50F3C153.9030204@oktetlabs.ru>
 <20130118081145.GB24987@secunet.com>
 <20130118081601.GE24987@secunet.com>
 <20130118.143923.1384219845592340856.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yurij.Plotnikov@oktetlabs.ru, bhutchings@solarflare.com,
	netdev@vger.kernel.org, Alexandra.Kossovsky@oktetlabs.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41000 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752667Ab3AUGsk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 01:48:40 -0500
Content-Disposition: inline
In-Reply-To: <20130118.143923.1384219845592340856.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 18, 2013 at 02:39:23PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Fri, 18 Jan 2013 09:16:01 +0100
> 
> > On IPsec pmtu events we can't access the transport headers of
> > the original packet, so we can't find the socket that sent
> > the packet. The only chance to notify the socket about the
> > pmtu change is to force a relookup for all routes. This
> > patch implenents this for the IPsec protocols.
> > 
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> 
> Expensive, but I really can't come up with a better idea.

Yes, it's a last resort fix. But pmtu events are rare, so
it should not harm too much.
