From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: DSCP values in TCP handshake
Date: Tue, 19 Apr 2011 05:50:34 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se>
References: <loom.20110418T154445-102@post.gmane.org> <1303135512.3137.335.camel@edumazet-laptop> <20110418083827.05dd2d43@nehalam> <alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se> <4DAC8A8A.1010401@cox.net> <alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
 <20110418144908.55967b06@nehalam>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Joe Buehler <aspam@cox.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:42877 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751282Ab1DSDug (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Apr 2011 23:50:36 -0400
In-Reply-To: <20110418144908.55967b06@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Apr 2011, Stephen Hemminger wrote:

> If the DSCP bits are reflected, then it could allow for even better SYN 
> flood attack. Attacker could maliciously set DSCP to elevate priority 
> processing of his bogus SYN packets and also cause SYN-ACK on reverse 
> path to also take priority.

Incoming, it's already too late. Outgoing, yes, that might be a problem, 
but if you have a QoS enabled network then you might as well solve that in 
the network, not in the host.

Does Linux internally look at DSCP when deciding what SYNs to handle 
first? If not, I think the above reasoning is misdirected.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
