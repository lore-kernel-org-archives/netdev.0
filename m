From: Matt Mackall <mpm@selenic.com>
Subject: Re: Do you know the TCP stack? (127.x.x.x routing)
Date: Wed, 9 Mar 2005 09:52:09 -0800
Message-ID: <20050309175209.GX3163@waste.org>
References: <1110288879.1050.167.camel@jzny.localdomain> <20050308135134.GA20607@atrey.karlin.mff.cuni.cz> <1110290300.1050.190.camel@jzny.localdomain> <20050308140301.GC20607@atrey.karlin.mff.cuni.cz> <1110291470.1043.211.camel@jzny.localdomain> <Pine.LNX.4.61.0503081937020.5332@filer.marasystems.com> <1110316631.1084.57.camel@jzny.localdomain> <Pine.LNX.4.61.0503090009120.6780@filer.marasystems.com> <E1D91Rz-0004wp-00@smtp01.mrf.mail.rcn.net> <1110377889.1090.124.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zdenek Radouch <zdenek@rcn.com>, Henrik Nordstrom <hno@marasystems.com>,
        Martin Mares <mj@ucw.cz>, Eran Mann <emann@mrv.com>,
        Thomas Graf <tgraf@suug.ch>, Andi Kleen <ak@muc.de>,
        netdev@oss.sgi.com, linux-net@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1110377889.1090.124.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Mar 09, 2005 at 09:18:10AM -0500, jamal wrote:
> On Wed, 2005-03-09 at 08:39, Zdenek Radouch wrote:
> > At 07:39 AM 3/9/05 -0500, jamal wrote:
> 
> [..]
> > Imagine a simple gateway, connecting two parts of your company
> >  - the east
> > interface connects to a corporate net with a default gateway, the west net
> > is the software dept. net.  Now imagine that you give your internal line card
> > in this simple gateway a "_whatever_" address, say 18.7.22.69.
> > Your gateway now has a route 18.7.22.69/32 -> dev linecard
> > Now please tell me what happens when a guy on the west net tries
> > to check his MIT evening class schedule.
> 
> Are we still talking about the same problem? The linecards addresses and
> interconnect interfaces are "internal". They are never advertised/seen
> outside of the chasis. So if you choose 18.7.22.69/32 to use internally
> you make sure it is never advertised to the outside world as belonging
> to you. If you have to advertise it or actually know it is used, then
> you must deal with the conflict.

Jamal, he's building a router. A router must be transparent to _all_
addresses that might be seen outside the "box". Reconfiguring such
internal details per installation is not acceptable. It would not be
ok if 18.7.22.69 mysteriously disappeared when the customer hammered
random addresses through it, even if said address was 'owned' by the
vendor. The customer might be testing their own equipment for net
deployment!

The only addresses he might not legitimately see on the wire are the
loopback ones. The routers I worked on at Cisco that had internal
networks did exactly this, by the way.

> If the router upstream from you used the same hack you end up being in
> trouble.

Uh, why? The 127 packets never leave the "box".

-- 
Mathematics is the supreme nostalgia of our time.
