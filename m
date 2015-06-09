From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Weird DHCP related problems with net-next
Date: Tue, 9 Jun 2015 21:22:42 +0200
Message-ID: <20150609192242.GD16778@lunn.ch>
References: <5577367A.50901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53313 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753351AbbFIT2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 15:28:17 -0400
Content-Disposition: inline
In-Reply-To: <5577367A.50901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 09, 2015 at 11:54:50AM -0700, Florian Fainelli wrote:
> Hi,
> 
> I am observing a strange problem on net-next (not observed with net,
> bisection in progress) where the initial DHCP configuration using
> busybox's udhcpc is able to configure the local interface address and
> DNS serer, but not the default gateway. Restarting udhcpc a second time
> does not exhibit this problem.

Hi Florian

I've seen something similar, but different, again with DSA involved,
on a WiFi Access point. I have debian, and i'm using isc dhcp. It gets
an address, sets the address on the interface, but does not add the
interface route to the routing table. Not sure about default route, i
would have to go check that.

Might be related, might not be.

      Andrew
