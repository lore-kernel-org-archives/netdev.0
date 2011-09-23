From: David Lamparter <equinox@diac24.net>
Subject: Re: GRE devices and MULTICAST flag.
Date: Fri, 23 Sep 2011 23:16:25 +0200
Message-ID: <20110923211625.GA2409116@jupiter.n2.diac24.net>
References: <4E7CE473.3000304@candelatech.com>
 <4E7CEF4D.6080309@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41982 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752340Ab1IWVQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Sep 2011 17:16:30 -0400
Content-Disposition: inline
In-Reply-To: <4E7CEF4D.6080309@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 23, 2011 at 01:42:53PM -0700, Ben Greear wrote:
> On 09/23/2011 12:56 PM, Ben Greear wrote:
> > I was under the impression that GRE tunnels could support MULTICAST
> > traffic, but the MULTICAST flag is not set. This is making the xorp
> > router crap out because it checks the MULTICAST flag and will
> > not start multicast on the interface if it's not set....
> >
> > Is it supposed to be set?
> >
> > 7: gre0: <NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
> > link/gre 0.0.0.0 brd 0.0.0.0
> > 8: netb: <POINTOPOINT,NOARP,UP,LOWER_UP> mtu 1476 qdisc noqueue state UNKNOWN
> > link/gre 192.168.100.223 peer 192.168.100.138
> > inet 10.0.1.1/32 scope global netb
> 
> Well, ifconfig netb multicast seems to add the flag,
> so maybe all is as it should be.

I distinctively remember that the MULTICAST flag is supposed to be an
input to the kernel, not a feature-indication flag output. I'm quite
unsure where I picked this up, but I remember using it in that way that
xorp does and then finding out it's wrong.


-David
