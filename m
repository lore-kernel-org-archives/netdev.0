From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/1] add ethtool loopback support
Date: Thu, 08 Apr 2010 20:35:56 +0100
Message-ID: <1270755356.5055.23.camel@achroite.uk.solarflarecom.com>
References: <pvmbpdtn8yh.fsf@chavey.mtv.corp.google.com>
	 <1270751373.5055.22.camel@achroite.uk.solarflarecom.com>
	 <w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, therbert@google.com
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54732 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933182Ab0DHTgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 15:36:00 -0400
In-Reply-To: <w2i97949e3e1004081217jdeca953dz162c62b61c0e8f72@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-08 at 12:17 -0700, Laurent Chavey wrote:
> On Thu, Apr 8, 2010 at 11:29 AM, Ben Hutchings
> <bhutchings@solarflare.com> wrote:
> > On Thu, 2010-04-08 at 10:35 -0700, chavey@google.com wrote:
[...]
> >> +enum ethtool_loopback_type {
> >> +     ETH_MAC                 = 0x00000001,
> >> +     ETH_PHY_INT             = 0x00000002,
> >> +     ETH_PHY_EXT             = 0x00000004
> >> +};
> > [...]
> >
> > There are many different places you can loop back within a MAC or PHY,
> > not to mention bypassing the MAC altogether.  See
> > drivers/net/sfc/mcdi_pcol.h, starting from the line
> > '#define MC_CMD_LOOPBACK_NONE 0'.  I believe we implement all of those
> > loopback modes on at least one board.
> >
> > Also are these supposed to be an enumeration or flags?  In theory you
> those are enums that can be or together.

I.e. they are flags.  So how do you answer this:

> > could use wire-side and host-side loopback at the same time if they
> > don't overlap, but it's probably too much trouble to bother with.  Any
> > other combination is meaningless.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

