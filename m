From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 21:16:37 -0700
Message-ID: <20110418211637.57f1cfb8@nehalam>
References: <loom.20110418T154445-102@post.gmane.org>
	<1303135512.3137.335.camel@edumazet-laptop>
	<20110418083827.05dd2d43@nehalam>
	<alpine.DEB.2.00.1104181750150.14027@uplift.swm.pp.se>
	<4DAC8A8A.1010401@cox.net>
	<alpine.DEB.2.00.1104182115291.14027@uplift.swm.pp.se>
	<20110418144908.55967b06@nehalam>
	<alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Joe Buehler <aspam@cox.net>, Eric Dumazet <eric.dumazet@gmail.com>,
	netdev@vger.kernel.org
To: Mikael Abrahamsson <swmike@swm.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37616 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750958Ab1DSEQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 00:16:40 -0400
In-Reply-To: <alpine.DEB.2.00.1104190547300.14027@uplift.swm.pp.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 19 Apr 2011 05:50:34 +0200 (CEST)
Mikael Abrahamsson <swmike@swm.pp.se> wrote:

> On Mon, 18 Apr 2011, Stephen Hemminger wrote:
> 
> > If the DSCP bits are reflected, then it could allow for even better SYN 
> > flood attack. Attacker could maliciously set DSCP to elevate priority 
> > processing of his bogus SYN packets and also cause SYN-ACK on reverse 
> > path to also take priority.
> 
> Incoming, it's already too late. Outgoing, yes, that might be a problem, 
> but if you have a QoS enabled network then you might as well solve that in 
> the network, not in the host.
> 
> Does Linux internally look at DSCP when deciding what SYNs to handle 
> first? If not, I think the above reasoning is misdirected.

Linux does not look at DSCP of incoming packets (there is no queue).

Of course, you can do anything with qdisc, and iptables.
