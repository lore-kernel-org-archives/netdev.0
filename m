From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [PATCH 2.4] backport neighbour cache redesign
Date: Mon, 4 Oct 2004 23:11:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004211158.GG27499@sunbeam.de.gnumonks.org>
References: <20040930154753.GD1860@sunbeam.de.gnumonks.org> <20041004121759.26798f1d.davem@davemloft.net> <20041004201525.GF27499@sunbeam.de.gnumonks.org> <20041004132034.00cfe23c.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="jk/5KjyVsvxWSMIA"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041004132034.00cfe23c.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jk/5KjyVsvxWSMIA
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 04, 2004 at 01:20:34PM -0700, David S. Miller wrote:

> I think tieing it to the subnet size is wrong, because the real
> cap is the routing cache size.  Remember the email where I was
> talking about that?

yes, I remember that email.  I didn't think further about it, since I
got the feeling that there is significant movement to get rid of the
neighbour cache at some point (if/when there is some fast lookup
algorithm implemented) - and if we look at ipv6, there is no routing
cache.

> I'm nearly ambivalent about a bound-less neighbour cache.  I hate
> to think about having tons of crap sitting in the neighbour cache
> unused and sucking up memory.  BSD's scheme works because when routing
> entries die so do the neighbour entries they point to, so they have no
> need for garbage collection like we do.

mh, I see.  I understood your email related to that subject that you
actually think this is not that stupid a thing to do...=20

anyway, I'll drop my prefix-based sizing idea.  And I have to admit that
I also dislike the 'routing cache tell neighbour cache' approach (since
it's only applicable to ipv4)... so as for me, we'll just stick with
that hard limit.  No more fiddling with that code, I'll get back to flow
accounting and pkttables for some time ;)

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--jk/5KjyVsvxWSMIA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBYbyeXaXGVTD0i/8RAiVBAJsGS19s/sCo8GmeelzjRm83LXqB8wCggmpA
nxa93JMnUATsNYYfJyENoeI=
=Fxg5
-----END PGP SIGNATURE-----

--jk/5KjyVsvxWSMIA--
