From: Laurent DENIEL <laurent.deniel@thalesatm.com>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating master's
 settings toslaves
Date: Mon, 11 Aug 2003 16:07:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F37A331.88EB0B1D@thalesatm.com>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
		 <1060570284.1056.15.camel@jzny.localdomain>
		 <200308111308.48263.shmulik.hen@intel.com> <1060607079.1050.144.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: shmulik.hen@intel.com, bonding-devel@lists.sourceforge.net,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal a =E9crit :
>=20
> > Trying to move that from the kernel module into the config applicatio=
n
> > seems to be a very hard task to implement since we'll have to find a
> > way to make the application constantly aware to the specifics like
> > current topology, slave-to-bond affiliation, updated status of each
> > slave, etc., etc. It would also mean that the driver will have to
> > wait for the application to tell it what to do each time it needs a
> > decision, and by that we'll surely suffer some performance hit and
> > probably get low availability or temporary loss of communications.
> >
>=20
> Not at all. If you let some app control this i am sure whoever writes
> the app has vested interest in getting fast failovers etc.
>=20

>=20
> Basically what i described at the top. Move any "richness" to user
> space.

HP/Compaq/Digital used to have the same approach with their Netrain
implementation, and from one release of Tru64 UNIX to another, they
could no longer support resolution ala milli-seconds but only seconds
due to the move of such "richness" to user space (among other things).=20
I am not saying that doing so on Linux will result to the same, but=20
a minimal failover policy shall remain in the kernel for performance=20
reason ... (or a user space facility could exist to *configure* such
policy but without direct interaction with user space when the kernel
has to decide).

Laurent
