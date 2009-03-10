From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell 88E609x switch?
Date: Tue, 10 Mar 2009 10:43:12 +0100
Message-ID: <20090310094312.GL4738@xi.wantstofly.org>
References: <49A806C5.1010200@mlbassoc.com> <20090227153102.GH17040@xi.wantstofly.org> <49A80A75.8000101@mlbassoc.com> <20090227155224.GK17040@xi.wantstofly.org> <Pine.LNX.4.64.0902272211260.19905@ask.diku.dk> <20090227222802.GZ17040@xi.wantstofly.org> <1235991382.30736.62.camel@localhost.localdomain> <1235991937.30736.65.camel@localhost.localdomain> <49ABF7DF.8060302@mlbassoc.com> <49ABF9A9.2040608@mlbassoc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jdb@comx.dk, Jesper Dangaard Brouer <hawk@diku.dk>,
	netdev <netdev@vger.kernel.org>
To: Gary Thomas <gary@mlbassoc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40209 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752247AbZCJJnO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 05:43:14 -0400
Content-Disposition: inline
In-Reply-To: <49ABF9A9.2040608@mlbassoc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 02, 2009 at 08:22:17AM -0700, Gary Thomas wrote:

> >>> You should write 0x003E ... see attached patch
> >> Ups, I see (from the thread) that you have already done/tried this...
> > 
> > Yes, although I think it will need some work in the future
> > (I've set it to 1000Mb connection, you said you used 100Mb, etc)
> > 
> > Question: I'm testing this by trying a ping out of my box.
> > Linux replies by sending an ARP packet out, and the destination
> > replies with an ARP packet in.  I can see from the ethtool stats
> > that the reply packets get into lan1.1 (the physical port I'm
> > using), but I don't see them get moved through the CPU port.
> > My understanding is that this should work via the VLAN map?
> > I checked that setup and it looks OK.
> > 
> > Any ideas where this might be going wrong?
> 
> I also just noticed that the ESA registers (Global 1,2,3)
> aren't set at all.

This is done by mv88e6xxx_set_addr_{in,}direct() in mv88e6xxx.c,
via the ->set_addr() callback.
