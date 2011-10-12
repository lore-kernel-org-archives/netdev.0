From: David Lamparter <equinox@diac24.net>
Subject: Re: bridge: HSR support
Date: Wed, 12 Oct 2011 15:28:22 +0200
Message-ID: <20111012132822.GJ2840382@jupiter.n2.diac24.net>
References: <4E948A04.8060400@enea.com>
 <20111011112821.28cd3e51@nehalam.linuxnetplumber.net>
 <4E94D67A.9060207@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Lennert Buytenhek <kernel@wantstofly.org>
To: Arvid Brodin <arvid.brodin@enea.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:49694 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753045Ab1JLN22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 09:28:28 -0400
Content-Disposition: inline
In-Reply-To: <4E94D67A.9060207@enea.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2011 at 01:51:22AM +0200, Arvid Brodin wrote:
> Stephen Hemminger wrote:
> >> I want to add support for HSR ("High-availability Seamless Redundancy",
> >> IEC-62439-3) to the bridge code. With HSR, all connected units have two network
> >> ports and are connected in a ring. All new Ethernet packets are sent on both
> >> ports (or passed through if the current unit is not the originating unit).


> >> The same packet is never passed twice.

How does the bridge decide whether a packet is arriving the second time?
Is the ring pre-resolved to stop things or does this happen per-packet?


-David
