From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Runtime power management for network interfaces
Date: Tue, 1 Aug 2006 17:18:12 +0200
Message-ID: <20060801151812.GA17791@xi.wantstofly.org>
References: <Pine.LNX.4.44L0.0607251147040.6498-100000@iolanthe.rowland.org> <20060731091728.4d992cf1@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Stern <stern@rowland.harvard.edu>,
	Network development list <netdev@vger.kernel.org>,
	David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:42183 "EHLO
	xi.wantstofly.org") by vger.kernel.org with ESMTP id S1751630AbWHAPSO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 11:18:14 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060731091728.4d992cf1@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 09:17:28AM -0700, Stephen Hemminger wrote:

> > During a Power Management session at the Ottawa Linux Symposium, it was
> > generally agreed that network interface drivers ought to automatically
> > suspend their devices (if possible) whenever:
> > 
> >     (1) The interface is ifconfig'ed down, or
> > 
> >     (2) No link is available.
> 
> This is hard because most of the power may be consumed by the PHY
> interface and it needs to be alive to see link.

At least some Davicom PHYs (IIRC) have an 'energy detect' bit, which
allows you to very quickly see whether there is a link partner without
waiting for autonegotiation to complete.

So, you could just power on the PHY only once every couple of seconds,
and instantly power it down again if the 'energy detect' bit doesn't go
on within some short time interval.


cheers,
Lennert
