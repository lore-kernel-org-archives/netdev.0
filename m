From: "David S. Miller" <davem@redhat.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Tue, 12 Aug 2003 06:08:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812060845.0e0ba2e8.davem@redhat.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	<200308111720.38472.shmulik.hen@intel.com>
	<1060612481.1034.15.camel@jzny.localdomain>
	<200308111925.38278.shmulik.hen@intel.com>
	<3F37C7C3.7070807@pobox.com>
	<3F37D2ED.B4B9223C@thalesatm.com>
	<3F37D5BF.8000702@pobox.com>
	<3F3889C7.1B4EC2BE@thalesatm.com>
	<1060693157.1027.87.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laurent.deniel@thalesatm.com, jgarzik@pobox.com, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1060693157.1027.87.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 12 Aug 2003 08:59:17 -0400
jamal <hadi@cyberus.ca> wrote:

> You dont think asking "what if the application dies" is in the same
> calibre as "what happens when the kernel oopses"?

Don't sweat it Jamal, some people just don't get it :-)

Look, people, when userlevel routing daemon dies your system
effectively stops to route.

There is zero difference between that example and the ones
we are discussing here.

Policy belongs strictly at user space.

One of the great things about what Jamal spends his time working
on is finally a strict seperation of the control layer from everything
else.  And part of this is moving all of the control logic into userspace.
Once that is accomplished, I can have my toilet flush every time a TCP
packet is routed through my system and this won't crap up the kernel.

If you don't see the value in that, perhaps you shouldn't be partaking
in this discussion :-)
