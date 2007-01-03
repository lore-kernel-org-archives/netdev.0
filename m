From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Wed, 03 Jan 2007 16:40:02 +1100
Message-ID: <1167802802.6165.129.camel@localhost.localdomain>
References: <1167800285.6165.105.camel@localhost.localdomain>
	 <20070102.211158.35016452.davem@davemloft.net>
	 <1167801614.6165.117.camel@localhost.localdomain>
	 <20070102.212605.15263907.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45655 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752581AbXACFkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 00:40:09 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20070102.212605.15263907.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-01-02 at 21:26 -0800, David Miller wrote:
> From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Date: Wed, 03 Jan 2007 16:20:14 +1100
> 
> > Now, I cross-over with a TG3 and I get:
> > 
> >  - I advertise 0x5e1 (hopefully same value)
> >  - I read in LPA 0xc5e1 from the TG3
> > (and that other register tells me Rx and Tx pause can be enabled).
> 
> Does flow control get enabled with the TG3 on these
> switches?  Just curious.

On the quad G5 which has tg3, I get "Flow control is on for TX and on
for RX". Let me double check if I'm on the same switch...

Heh ! It's not :-)

If I switch the cables, then pause is enabled on the sungem box and
disabled (both Tx and Rx) on tg3, so at least the behaviour is
consistent and follow the switches. Let me check the switch models...

The one with only asym. support is a big Cisco Catalyst 3350 (well.. big
but not that many ports :-)

The one with "classic" pause support is a tiny Netgear GS116

It's possible that the cisco is just misconfigured though, I'll have to
ask Keith when he's around tomorrow to take a peek at the mgmnt
interface.

> > > You should try to use flow control, even slower than 1000Mbit links.
> > 
> > Sorry, not sure I parse ;-) You mean allowing pause on 10 and 100 as
> > well ? I sure can, it's easy to fix.
> 
> That's correct.

On it's way.

Ben.

