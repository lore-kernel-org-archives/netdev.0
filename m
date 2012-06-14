From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Thu, 14 Jun 2012 08:36:32 +0200
Message-ID: <20120614063632.GS27795@secunet.com>
References: <20120613.032228.1574539964049471628.davem@davemloft.net>
 <20120614053529.GP27795@secunet.com>
 <20120613.224203.297717896085583687.davem@davemloft.net>
 <20120613.225941.2175393318277942399.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45994 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab2FNGgf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2012 02:36:35 -0400
Content-Disposition: inline
In-Reply-To: <20120613.225941.2175393318277942399.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 13, 2012 at 10:59:41PM -0700, David Miller wrote:
> 
> Actually, thinking some more, we could extend my inet->pmtudisc patch
> to achieve a similar effect.
> 
> Essentially we'd have a socket local PMTU value for datagram sockets.
> 
> Would you be OK with that approach?

This would require to maintain socket local pmtu expire times too.
Also, which of these pmtu values do we report if a user asks for
that? And how should we flush all these pmtu values?

It could have some side effects. But if we get it to work,
it would be an improvement. I'm fine with everything
that works in the end :-)
