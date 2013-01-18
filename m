From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 3/3] xfrm4: Invalidate all ipv4 routes on IPsec
 pmtu events
Date: Fri, 18 Jan 2013 14:39:23 -0500 (EST)
Message-ID: <20130118.143923.1384219845592340856.davem@davemloft.net>
References: <50F3C153.9030204@oktetlabs.ru>
	<20130118081145.GB24987@secunet.com>
	<20130118081601.GE24987@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yurij.Plotnikov@oktetlabs.ru, bhutchings@solarflare.com,
	netdev@vger.kernel.org, Alexandra.Kossovsky@oktetlabs.ru
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab3ARTj0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jan 2013 14:39:26 -0500
In-Reply-To: <20130118081601.GE24987@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 18 Jan 2013 09:16:01 +0100

> On IPsec pmtu events we can't access the transport headers of
> the original packet, so we can't find the socket that sent
> the packet. The only chance to notify the socket about the
> pmtu change is to force a relookup for all routes. This
> patch implenents this for the IPsec protocols.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Expensive, but I really can't come up with a better idea.
