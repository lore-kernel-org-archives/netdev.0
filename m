From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 0/4] Fix routing metrics
Date: Fri, 10 Feb 2012 08:51:07 +0100
Message-ID: <20120210075106.GL23142@secunet.com>
References: <20120209124411.GJ23142@secunet.com>
 <20120209.134010.832064360325335834.davem@davemloft.net>
 <20120210065031.GK23142@secunet.com>
 <20120210.023815.192069104397847238.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50629 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753546Ab2BJHvJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Feb 2012 02:51:09 -0500
Content-Disposition: inline
In-Reply-To: <20120210.023815.192069104397847238.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 10, 2012 at 02:38:15AM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> > 
> > I fully agree with you here. But we check for the genid just in
> > rt_init_metrics() which is invoked only on route cache entry
> > creation. There is no check when the metrics are accessed,
> > because the metrics on the inetpeer are valid on every access.
> 
> Every routing cache entry we will use after the flush will be
> a newly created one!  All the old ones will be stop being used.

Yes, I know that. All inetpeer metrics are updated once with the
first new routing cache entry that binds that inetpeer to the route.
