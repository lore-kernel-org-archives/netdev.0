From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: Route cache performance tests
Date: Wed, 18 Jun 2003 08:50:53 +0300 (EEST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.44.0306180849210.4731-100000@netcore.fi>
References: <20030617205101.GD25773@netnation.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, <gandalf@wlug.westbo.se>,
	<Robert.Olsson@data.slu.se>, <ralph+d@istop.com>,
	<hadi@shell.cyberus.ca>, <xerox@foonet.net>, <fw@deneb.enyo.de>,
	<netdev@oss.sgi.com>, <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20030617205101.GD25773@netnation.com>
List-Id: netdev.vger.kernel.org

On Tue, 17 Jun 2003, Simon Kirby wrote:
> On Tue, Jun 17, 2003 at 01:36:35PM -0700, David S. Miller wrote:
> 
> > I have no idea why they do this, it's the stupidest thing
> > you can possibly do by default.
> > 
> > If we thought it was a good idea to turn this on by default
> > we would have done so in the kernel.
> > 
> > Does anyone have some cycles to spare to try and urge whoever is
> > repsponsible for this in Debian to leave the kernel's default setting
> > alone?
> 
> Sure, I can do this.  But why is this stupid?  It uses more CPU, but
> stops IP spoofing by default.  Specific firewall rules would have to be
> created otherwise.  And the overhead only really shows when the routing
> table is large, right?

Personally I think rp_filter by default is the only good choice
(security/operational-wise).  It's typically not useful when you have a
lot of routes, though.. but as the 99.9% of users _don't_, it still seems 
like a good default value.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

