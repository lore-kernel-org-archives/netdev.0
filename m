From: Harald Welte <laforge@netfilter.org>
Subject: Re: driver ability to use iptables?
Date: Sun, 21 Nov 2004 20:15:48 +0100
Message-ID: <20041121191548.GE4009@obroa-skai.de.gnumonks.org>
References: <4198A1CE.7040905@syncro-community.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wTWi5aaYRw9ix9vO"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Hendrik Wiese <7.e.Q@syncro-community.de>
Content-Disposition: inline
In-Reply-To: <4198A1CE.7040905@syncro-community.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--wTWi5aaYRw9ix9vO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 15, 2004 at 01:32:14PM +0100, Hendrik Wiese wrote:
> Hello there,
>=20
> I hope I do right posting this here. So please don't be angry if I'm=20
> wrong. I'm kind of newbie.

There is a netfilter-devel@lists.netfilter.org lists for
iptables/netfilter related questions.  But I think netdev is quite ok in
this case, since at this time it is unclear (and I think very unlikely)
to be a netfilter/iptables issue.

> as soon as we want to use iptables to establish one of the modules as a=
=20
> router to the outer world (tp network connected via front panel eth
> device) this doesn't work...=20

_please_ give us more detailed descriptions than "doesn't work".

> correctly as it works for to eth devices. Is there any ability else a
> network device driver must have to work with iptables?

no, as iptables is based on netfilter IPv4 hooks which are embedded into
the IPv4 stack.  Between your driver and iptables is the ipv4 stack and
the generic networking core.  There is no driver/iptables interface at
all.

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--wTWi5aaYRw9ix9vO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBoOljXaXGVTD0i/8RAm5dAKCOs8MrdFv+Ib2U6qr9drAGath8JwCeJCKr
ohq0yBrFrkR1aF+x63lCBIo=
=mA4e
-----END PGP SIGNATURE-----

--wTWi5aaYRw9ix9vO--
