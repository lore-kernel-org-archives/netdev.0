From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sungem: PHY updates & pause fixes
Date: Wed, 03 Jan 2007 18:55:21 -0800 (PST)
Message-ID: <20070103.185521.64808473.davem@davemloft.net>
References: <1167801614.6165.117.camel@localhost.localdomain>
	<20070102.212605.15263907.davem@davemloft.net>
	<1167802802.6165.129.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35551
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932243AbXADCzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jan 2007 21:55:21 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1167802802.6165.129.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 03 Jan 2007 16:40:02 +1100

> On the quad G5 which has tg3, I get "Flow control is on for TX and on
> for RX". Let me double check if I'm on the same switch...
> 
> Heh ! It's not :-)
> 
> If I switch the cables, then pause is enabled on the sungem box and
> disabled (both Tx and Rx) on tg3, so at least the behaviour is
> consistent and follow the switches. Let me check the switch models...
> 
> The one with only asym. support is a big Cisco Catalyst 3350 (well.. big
> but not that many ports :-)
> 
> The one with "classic" pause support is a tiny Netgear GS116
> 
> It's possible that the cisco is just misconfigured though, I'll have to
> ask Keith when he's around tomorrow to take a peek at the mgmnt
> interface.

Thanks for tracking this down :-)

> > > > You should try to use flow control, even slower than 1000Mbit links.
> > > 
> > > Sorry, not sure I parse ;-) You mean allowing pause on 10 and 100 as
> > > well ? I sure can, it's easy to fix.
> > 
> > That's correct.
> 
> On it's way.

I've applied that patch, thanks.
