From: Harald Welte <laforge@netfilter.org>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 16 Sep 2003 16:06:21 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030916140621.GE810@obroa-skai.de.gnumonks.org>
References: <200309022116.41697.bdschuym@pandora.be> <20030905153152.GA3623@obroa-skai.de.gnumonks.org> <20030908191400.5ef59ab6.davem@redhat.com> <200309132159.37834.bdschuym@pandora.be> <20030915155903.12a3f95d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="RpqchZ26BWispMcB"
Cc: Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030915155903.12a3f95d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--RpqchZ26BWispMcB
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Sep 15, 2003 at 03:59:03PM -0700, David S. Miller wrote:

> I have to reject the fix for this problem again.
>=20
> You can't change the struct exported to userspace in any way
> without breaking the tools.  I tried to explain this in the
> first revision of your change.

But ipt_physdev is a 2.6ism, thus we can still introduce any
incompatibility... For me it's enough to be compatible within 2.4 or
within 2.6.x (once 2.6.0 is out).

--=20
- Harald Welte <laforge@netfilter.org>             http://www.netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--RpqchZ26BWispMcB
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.2 (GNU/Linux)

iD8DBQE/ZxjdXaXGVTD0i/8RAvwEAJ4htvS6D4AkjvQ7jP73ip6fNWIIWwCgkWvh
p5vr4UEckgkef/6IvUVH/vA=
=l7fr
-----END PGP SIGNATURE-----

--RpqchZ26BWispMcB--
