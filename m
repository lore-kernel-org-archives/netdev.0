From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: RE: Bug?  TCP shutdown behaviour when deleting local IP addresses
Date: Thu, 18 Oct 2012 12:00:23 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.1210181158190.21297@uplift.swm.pp.se>
References: <507F38D4.102@genband.com> <alpine.DEB.2.00.1210180946020.21297@uplift.swm.pp.se> <AE90C24D6B3A694183C094C60CF0A2F6026B7051@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Chris Friesen <chris.friesen@genband.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:54499 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932118Ab2JRKAY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Oct 2012 06:00:24 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7051@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Oct 2012, David Laight wrote:

> Doing that is almost pointless and gives people false expectations.
>
> Consider the simple network host-hub-hub-host.
> If you disconnect the link between the two hubs then
> only timeouts can cause disconnects.
> Such a remote fault is much more likely than the local one.

My doing suspect/resume on my laptop causes more network interruptions 
than any link going down in the network outside my home.

> If the kernel takes down connections when a local interface
> goes down (as windows does) then people doing testing
> fail to test the correct scenario.

I never asked for the kernel to take down connections, I asked for the 
connection manager to be able to do it.

> You also don't want a power glitch in the wiring cupboard to disconnect 
> all your connections.

In a server environment, most likely you're right. In some other 
environment, the opposite probably applies.

> In the past I've also moved IP addresses between physical
> interfaces - modern HA systems might do the same.

Yes, in your described scenario you're right, in my scenario (laptop 
suspend/resume) I don't agree with your view.

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
