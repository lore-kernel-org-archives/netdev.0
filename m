From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPVS] Don't leak sysctl tables if the scheduler
 registration fails
Date: Tue, 04 Dec 2007 00:43:50 -0800 (PST)
Message-ID: <20071204.004350.09249852.davem@davemloft.net>
References: <4753D4C5.4040301@openvz.org>
	<20071204013647.GB28582@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, devel@openvz.org, wensong@linux-vs.org,
	ja@ssi.bg
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751229AbXLDInz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 03:43:55 -0500
In-Reply-To: <20071204013647.GB28582@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Tue, 4 Dec 2007 10:36:48 +0900

> On Mon, Dec 03, 2007 at 01:04:53PM +0300, Pavel Emelyanov wrote:
> > In case we load lblc or lblcr module we can leak some sysctl
> > tables if the call to register_ip_vs_scheduler() fails.
> 
> This looks correct to me.
> 
> > I've looked at the register_ip_vs_scheduler() code and saw, that
> > the only reason to fail is the name collision, so I think that
> > with some 3rd party schedulers this becomes a relevant issue. No?
> 
> I guess so. Though presumably register_ip_vs_scheduler() could
> have other modes of failure in the future.
> 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks.
