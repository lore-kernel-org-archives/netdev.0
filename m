From: Vladimir Ivashchenko <hazard@francoudi.com>
Subject: Re: bond + tc regression ?
Date: Wed, 6 May 2009 23:47:59 +0300
Message-ID: <20090506204759.GA16681@francoudi.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0105A8.3060707@cosmosbay.com> <1241635518.13702.37.camel@hazard2.francoudi.com> <200905062230.04594.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cerber.thunderworx.net ([217.27.32.18]:3109 "EHLO
	cerber.thunderworx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249AbZEFUsB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 16:48:01 -0400
Content-Disposition: inline
In-Reply-To: <200905062230.04594.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2009 at 10:30:04PM +0300, Denys Fedoryschenko wrote:

> > What's interesting, the same 850mbps load, identical machine, but with
> > only two NICs and no bond, HTB+esfq, kernel 2.6.21.2 => 60% CPU idle.
> > 2.5x overhead.
> 
> Probably oprofile can sched some light on this.
> On my own experience IRQ balancing hurt performance a lot, because of cache 
> misses.

This is a dual-core machine, isn't cache shared between the cores?

Without IRQ balancing, one of the cores goes around 10% idle and HTB doesn't do
its job properly. Actually, in my experience HTB stops working properly after
idle goes below 35%.

I'll try gathering some stats using oprofile.

-- 
Best Regards
Vladimir Ivashchenko
Chief Technology Officer
PrimeTel, Cyprus - www.prime-tel.com
