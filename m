From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: 2.6 ipv6 doesn't take route advertisements
Date: Mon, 10 Nov 2003 22:58:57 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1068501536.774.1.camel@tux.rsn.bth.se>
References: <Pine.LNX.4.44.0311101629100.2898-100000@chimarrao.boston.redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-JE8rCjEXJ8wazuw75Pzj"
Cc: Dave Miller <davem@redhat.com>, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Rik van Riel <riel@redhat.com>
In-Reply-To: <Pine.LNX.4.44.0311101629100.2898-100000@chimarrao.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-JE8rCjEXJ8wazuw75Pzj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2003-11-10 at 22:31, Rik van Riel wrote:
> Hi,
>=20
> it looks like the 2.6 kernel doesn't take default route
> advertisements from either zebra or radvd.  I can see
> the default routes being advertised with radvdump, but
> they don't show up in the routing table of either of my
> 2.6 machines.  They both run a fairly recent 2.6 kernel.
>=20
> Known bug ?

Works fine here with test9-bk15
Router runs radvd.

default dev eth1  proto kernel  metric 256  mtu 1500 advmss 1440 metric10 6=
4
default dev eth2  proto kernel  metric 256  mtu 1500 advmss 1440 metric10 6=
4
default via fe80::202:b3ff:fe5f:11fd dev eth0  proto kernel  metric 1024  e=
xpires 1788sec mtu 1500 advmss 1440 metric10 64

--=20
/Martin

--=-JE8rCjEXJ8wazuw75Pzj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQA/sAofWm2vlfa207ERAl3aAKCFBsQN6V2ftFEyssROiv5wmN5NLwCfbmQP
/lEiXbz/YuRCVL8c/zjYFVU=
=p5gv
-----END PGP SIGNATURE-----

--=-JE8rCjEXJ8wazuw75Pzj--
