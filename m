From: Laurent DENIEL <laurent.deniel@thalesatm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
 master'ssettings toslaves
Date: Tue, 12 Aug 2003 08:31:35 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F3889C7.1B4EC2BE@thalesatm.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com> <200308111720.38472.shmulik.hen@intel.com> <1060612481.1034.15.camel@jzny.localdomain> <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com> <3F37D2ED.B4B9223C@thalesatm.com> <3F37D5BF.8000702@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: shmulik.hen@intel.com, hadi@cyberus.ca,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik a =E9crit :
>
> > You forgot one important aspect :
> >
> >   (4) does moving code to userspace break compatibility (or behavior)
> >       with user land applications (or systems)
>=20
> I agree... assuming these userland interfaces are fairly standard and
> widely deployed.
>=20
> > What can one do if say, kernel 2.[4|5] switches the NIC in 10 msecond=
s
> > while kernel 2.7 with user land daemon switches in a few seconds ?
> > nothing but stay with the previous version or fork the driver develop=
ment ;-(
>=20
> This is a silly example.  If that happens in practice, then that is a
> bug in the configuration of the userland daemon, or a bug in the
> kernel<->userland ABI.

Not a silly example but a real case that happened to me with another
operating system and I'd hate if it happens also with Linux ...
=20
> > But I agree that it is interesting to do some stuff at user land, and=
 if
> > the bonding had an option to disable the automatic failover policy,
> > this could be implemented with trigger towards user land application =
that
> > could use an ioctl call to switch to the appropriate NIC according to
> > the user lan configuration ...
>=20
> Remember, ioctls are bad.  :)  Unix design mistake.

ioctl (which already exist) or something else, this is not the point here.

> > what happens when the=20
> > system is heavily loaded ?=20
>=20
> What happens now ?=20
>=20
> > What happens if the application dies for=20
> > some reason ?=20
>=20
> What happens when the kernel oopses? ;->

Such silly responses make me think that it is no longer worth to argue ...

Laurent
