From: Donald Becker <becker@scyld.com>
Subject: Re: SIOCADDMULTI for unicast broken
Date: Sat, 4 Jan 2003 01:33:11 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0301040121530.29812-100000@beohost.scyld.com>
References: <20030103224852.L48869@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Ben Greear <greearb@candelatech.com>, Jeff Garzik <jgarzik@pobox.com>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <20030103224852.L48869@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 3 Jan 2003, jamal wrote:

> Too many emails to respond to at once.
> 
> Q: Is this a hack?
> A: Yes, indeed it is. wrong API is the main culprit.
> 
> Q: Is this a feature needed by only a few people?
> A: No, Absolutely not. RFC2338 is one example that needs

The common way of handling this is unsolicited ARP.

> How common are NICS such as the 21x4x that can be programmed to do
> perfect hashing and accept multiple MAC addresses in hardware?

Not very common.  I mentioned the 21*4* explicitly because few other
common chips implement this feature.
The Digital design implemented it because of DECnet, which is long dead.

> And if this was a commodity feature - what happens to PACKET_HOST
> setting? an netdevice can only have one unicast MAC address.
> SIOCDEVPRIVATE does not seem to be the right place to do this.
> You still wanna have ability to do proper RFC2338 and related protocols
> even when the h/ware is incapable.
> And btw, i didnt even open up the whole can of worms - we also need to
> respond back with proper MAC addresses to ARPs and packets sourced with
> specific virtual router IPs. This is a seprate problem.

Yup, a whole can of worms if you want it to be a general feature handled
by the kernel...

> PS: the hack credit (for using SIOCADDMULTI/DELMULTI) goes to Jerome
> Ettiene (this is a guy who never responds to email, probably too busy
> unicycling somewhere, so no point in ccing him) - Except it doesnt work
> without the patch i posted.

This has worked with the Tulip driver for many years.  I've pointed it
out to a number of people that requested this as a new feature.


-- 
Donald Becker				becker@scyld.com
Scyld Computing Corporation		http://www.scyld.com
410 Severn Ave. Suite 210		Scyld Beowulf cluster system
Annapolis MD 21403			410-990-9993
