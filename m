From: "David S. Miller" <davem@davemloft.net>
Subject: Re: unregister_netdevice: waiting for tun6to4 to become free.
Date: Wed, 22 Sep 2004 11:15:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040922111544.469dc4c2.davem@davemloft.net>
References: <20040920212453.GA15392@ee.oulu.fi>
	<414F7CD9.3090008@pobox.com>
	<414FC92F.6090009@tomt.net>
	<1095854932.17821.1190.camel@hades.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: andre@tomt.net, jgarzik@pobox.com, pp@ee.oulu.fi, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <1095854932.17821.1190.camel@hades.cambridge.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 22 Sep 2004 13:08:52 +0100
David Woodhouse <dwmw2@infradead.org> wrote:

> On Tue, 2004-09-21 at 08:24 +0200, Andre Tomt wrote:
> > Jeff Garzik wrote:
> > > I hit this _once_ on my gateway (NAT'ing firewall IPv4, now also IPv6 
> > > router).
> > > 
> > > No idea why it went away, I just assumed a more recent kernel fixed 
> > > something.
> > 
> > We've been seeing this all the time on 2.6.8.1 + "critical fixes". 
> > Pretty much anytime a router with tunneling interfaces is taken down for 
> > shutdown or reboot, it hangs spinning waiting for the tunnel devices to 
> > get freed, as ifdown gets run.
> 
> It's not just tunnel interfaces. It seems to be related to hot-unplug of
> interfaces with live IPv6 addresses. I've seen it on my prism54 card too
> on many recent kernels. All I have to do is insert it and remove it a
> few times. 

There is code in ipv6 which takes route references to devices and moves
that reference over to loopback.  There might be bugs in that area, and
I would suggest debugging in that area.
