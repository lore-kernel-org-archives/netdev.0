From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] remove superfluous diverter printk'ing
Date: Sun, 16 Jan 2005 18:22:02 +0100
Message-ID: <20050116172202.GC20537@xi.wantstofly.org>
References: <20050114124700.GA4079@xi.wantstofly.org> <20050114134642.4be4e2fc.davem@davemloft.net> <20050115104750.GB14991@xi.wantstofly.org> <1105895420.1090.708.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com,
        bdschuym@pandora.be
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105895420.1090.708.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Jan 16, 2005 at 12:10:21PM -0500, jamal wrote:

> Diverter could simply be killed now that tc actions exist if theres no
> maintainer or user.
> Should be able to divert any packet of choce to any interface.

The diverter is not used for redirecting a packet to another interface.

What it does (IIRC) is overwrite the destination MAC address on selected
packets so that the local host will process them.  You can do the same
thing with iptables' "-j REDIRECT" but the diverter was made for use on
ethernet bridges (REDIRECTing bridged packets) when the bridge-nf stuff
didn't exist yet.

Nowadays we have bridge-nf and you should be able to do the same thing
by just using '-j REDIRECT' as you would do with routing (Bart, please
correct me if I'm wrong there.)


--L
