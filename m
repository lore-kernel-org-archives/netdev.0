From: Jamie Lokier <jamie@shareable.org>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Thu, 10 Mar 2005 01:47:57 +0000
Message-ID: <20050310014757.GC12990@mail.shareable.org>
References: <1110288879.1050.167.camel@jzny.localdomain> <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain> <20050308140301.GC20607@atrey.karlin.mff.cuni.cz> <1110291470.1043.211.camel@jzny.localdomain> <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com> <1110316631.1084.57.camel@jzny.localdomain> <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com> <1110371962.1088.90.camel@jzny.localdomain> <Pine.LNX.4.61.0503091730280.16557@filer.marasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, Martin Mares <mj@ucw.cz>,
        Zdenek Radouch <zdenek@rcn.com>,
        Steve Iribarne <steve.iribarne@dilithiumnetworks.com>,
        Eran Mann <emann@mrv.com>, Thomas Graf <tgraf@suug.ch>,
        Andi Kleen <ak@muc.de>, netdev@oss.sgi.com, linux-net@vger.kernel.org
To: Henrik Nordstrom <hno@marasystems.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0503091730280.16557@filer.marasystems.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Henrik Nordstrom wrote:
> If Linux could manage different IP stacks per interface this would not be 
> a problem, but as it is today the same IP stack is used for all interfaces 
> making dual homing (not routing) a bit troublesome when the same addresses 
> may be in both networks..

Indeed, I have exactly the same problem with a device that must
simultaneously connect to:

     - the local customer-site ethernet
     - the local customer-site 802.11 wireless

and auto-configure both interfaces using DHCP to connect to hosts on
the internet as best as possible through all available interfaces.
There is absolutely no guarantee that I won't see a network or even
address conflict on the two interfaces, as they may be _separate_
networks each behind a NAT to the outside world over ADSL.

In fact, it's quite likely that DHCP for each interface will provide a
192.168.0.0/24 address, as that seems to be the typical setup of both
kinds of ADSL NAT router...

Any suggestion of asking customer-site to specially configure their
network rather defeats the point, which is a device which
automatically tries available connections, using DHCP, and routes its
traffic over whichever one works best at any time.

-- Jamie
