From: Laurent DENIEL <laurent.deniel@thalesatm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Tue, 12 Aug 2003 16:10:49 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F38F569.C1EC7769@thalesatm.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
		<200308111720.38472.shmulik.hen@intel.com>
		<1060612481.1034.15.camel@jzny.localdomain>
		<200308111925.38278.shmulik.hen@intel.com>
		<3F37C7C3.7070807@pobox.com>
		<3F37D2ED.B4B9223C@thalesatm.com>
		<3F37D5BF.8000702@pobox.com>
		<3F3889C7.1B4EC2BE@thalesatm.com>
		<1060693157.1027.87.camel@jzny.localdomain> <20030812060845.0e0ba2e8.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: hadi@cyberus.ca, jgarzik@pobox.com, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" a =E9crit :
>=20
> On 12 Aug 2003 08:59:17 -0400
> jamal <hadi@cyberus.ca> wrote:
>=20
> > You dont think asking "what if the application dies" is in the same
> > calibre as "what happens when the kernel oopses"?
>=20
> Don't sweat it Jamal, some people just don't get it :-)
>=20
> Look, people, when userlevel routing daemon dies your system
> effectively stops to route.

That's why in really *safe* systems, we do not use routing daemon
but only static routes ;-)

And there is a BIG difference :=20

When user level daemon dies, you have to be sure that some stuff
exists to monitor and recover from that situation (either by=20
restarting the faulty deamon (if it could recover in time which
I doubt with the bonding case), or by switching to a new machine
in a fault tolerant configuration). With kernel ooops, there is
NOTHING to do in such in such a fault tolerant systems, since the
machine is unusable (this is the same as a hardware failure).

But people does not understand the constraints of really safe
systems.

> Policy belongs strictly at user space.
>=20
> One of the great things about what Jamal spends his time working
> on is finally a strict seperation of the control layer from everything
> else.  And part of this is moving all of the control logic into userspa=
ce.
> Once that is accomplished, I can have my toilet flush every time a TCP
> packet is routed through my system and this won't crap up the kernel.
>=20
> If you don't see the value in that, perhaps you shouldn't be partaking
> in this discussion :-)

This is OK as long as your kernel and user space stuff remains suitable
for highly fault tolerant systems and which does not require big montains
of user stuff to do the same as a few line of code in the kernel. Remembe=
r
the aim of bonding : NIC fault tolerance or load balancing. I am not agai=
nst
a user space configurable policy for more complex job but the initial aim=
 of=20
the bonding shall remain coded in the kernel (and is only usable in the a=
bove=20
mentioned systems in that way).

Laurent
