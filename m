From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 14:49:08 -0700
Message-ID: <20110418144908.55967b06@nehalam>
References: <loom.20110418T154445-102@post.gmane.org>
	<1303135512.3137.335.camel@edumazet-laptop>
	<20110418083827.05dd2d43@nehalam>
	<alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
	<4DAC8A8A.1010401@cox.net>
	<alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Buehler <aspam@cox.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41653 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751862Ab1DRVtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 17:49:11 -0400
In-Reply-To: <alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011 21:16:35 +0200 (CEST)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> On Mon, 18 Apr 2011, Joe Buehler wrote:
> 
> > The argument I have seen for not making reflection standard behavior is 
> > that it is not always appropriate for the application.  For example, web 
> > servers have short requests but large responses so non-identical DSCP 
> > values might make more sense.
> 
> I'm a router guy. I don't understand this reasoning at all.
> 
> Anyone care to elaborate?
> 
> I'd like reflection be standard and have the application set DSCP if it 
> needs to.
> 

If the DSCP bits are reflected, then it could allow for even better
SYN flood attack. Attacker could maliciously set DSCP to elevate priority
processing of his bogus SYN packets and also cause SYN-ACK on reverse path
to also take priority.

-- 
