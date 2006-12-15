From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [Bridge] Bridge & it's MAC address question
Date: Fri, 15 Dec 2006 17:04:29 +0100
Message-ID: <20061215160429.GC12679@xi.wantstofly.org>
References: <200610301527.15018.dim@openvz.org> <20061030072837.51177183@localhost.localdomain> <20061215131908.GC11579@xi.wantstofly.org> <20061215075236.321e6a07@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dmitry Mishin <dim@openvz.org>, netdev@vger.kernel.org,
	bridge@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:57892 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbWLOQEb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 11:04:31 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061215075236.321e6a07@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[ dropped subscriber-only openvz.org list ]

On Fri, Dec 15, 2006 at 07:52:36AM -0800, Stephen Hemminger wrote:

> > > The bridge physical address is the minimum of all the attached devices.
> > > This is done because the STP standard requires it.  You can reset it
> > > to be the same as any of the attached devices. This will not cause a
> > > problem unless using STP.
> > 
> > You can in fact use any MAC address.  The STP standard recommends using
> > the minimum address, as that is deterministic, and so it doesn't depend
> > on the order in which you enslave subdevices.
> 
> So should restriction be lifted?

We should definitely allow users to override the MAC address of a
bridge interface.


> Please update wiki page FAQ, or I'll do it

Please do.
