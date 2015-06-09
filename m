From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Weird DHCP related problems with net-next
Date: Tue, 9 Jun 2015 23:42:27 +0200
Message-ID: <20150609214227.GB32336@lunn.ch>
References: <5577367A.50901@gmail.com>
 <20150609192242.GD16778@lunn.ch>
 <55774D23.1010508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Scott Feldman <sfeldma@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53375 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933185AbbFIVsD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 17:48:03 -0400
Content-Disposition: inline
In-Reply-To: <55774D23.1010508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 01:31:31PM -0700, Florian Fainelli wrote:
> Hi Andrew,
> 
> On 09/06/15 12:22, Andrew Lunn wrote:
> > On Tue, Jun 09, 2015 at 11:54:50AM -0700, Florian Fainelli wrote:
> >> Hi,
> >>
> >> I am observing a strange problem on net-next (not observed with net,
> >> bisection in progress) where the initial DHCP configuration using
> >> busybox's udhcpc is able to configure the local interface address and
> >> DNS serer, but not the default gateway. Restarting udhcpc a second time
> >> does not exhibit this problem.
> > 
> > Hi Florian
> > 
> > I've seen something similar, but different, again with DSA involved,
> > on a WiFi Access point. I have debian, and i'm using isc dhcp. It gets
> > an address, sets the address on the interface, but does not add the
> > interface route to the routing table. Not sure about default route, i
> > would have to go check that.
> 
> Interesting, did you also observe this with 'net', or just with 'net-next'?

Just net-next, for some value of net-next. But i've not used net much,
since i see this problem during developing new features.
 
> Contrary to what I reported above, this is only an issue with
> SYSTEMPORT/DSA/SF2, I could not reproduce this GENET or the Asix driver,

> Note that I am observing this on ARM (Andrew probably is as well),

Yep.

	Andrew
