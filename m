From: Harald Welte <laforge@netfilter.org>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 20:15:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915181516.GB2678@sunbeam.de.gnumonks.org>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org> <414808F3.70104@draigBrady.com> <16712.14153.683690.710955@robur.slu.se> <41484AC2.8090408@draigBrady.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="4SFOXa2GPu3tIq4H"
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
Content-Disposition: inline
In-Reply-To: <41484AC2.8090408@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--4SFOXa2GPu3tIq4H
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 15, 2004 at 02:59:30PM +0100, P@draigBrady.com wrote:
> Interesting info thanks!
> It would be very interesting to see the performance of PCI express
> which should not have the bus arbitration issues.

Unfortunately there is no e1000 for PCI Express available yet... only
Marvell-Yukon and syskonnect single-port boards so far :(

> Well from the intel docs they say "The devices include a PCI interface
> that maximizes the use of bursts for efficient bus usage.
> The controllers are able to cache up to 64 packet descriptors in
> a single burst for efficient PCI bandwidth usage."
>=20
> So I'm guessing that increasing the PCI-X burst size setting
> (MMRBC) will automatically get more packets sent per transfer?
> I said previously in this thread to google for setpci and MMRBC,
> but what I know about it is...

Mh, I tried it on my System, following parameters:

dual 82456GB, PCI-X, 64bit, 66MHz, UP x86_64 kernel, modified e1000 with
hard-wired tx descriptor refill.

I did not observe any change in tx pps throughput when setting MMRBC to
512 / 4096 byte bursts.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--4SFOXa2GPu3tIq4H
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBSIa0XaXGVTD0i/8RAtnHAJ9FV+Z1yRbc5/GTviZDpvUlo2OxxwCgr5XW
lPcRVFkyXgMWWW9TQ5zclMo=
=OKqX
-----END PGP SIGNATURE-----

--4SFOXa2GPu3tIq4H--
