From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: IMQ / new Dummy device post.
Date: Sun, 18 Apr 2004 23:23:52 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1082323432.13261.397.camel@tux.rsn.bth.se>
References: <407E5905.9070108@dsl.pipex.com>
	 <1082031313.1039.13.camel@jzny.localdomain>
	 <407EE3E5.8060200@dsl.pipex.com>
	 <1082087553.1035.287.camel@jzny.localdomain>
	 <4080356F.4020609@dsl.pipex.com>
	 <1082145341.1026.125.camel@jzny.localdomain>
	 <40810957.6030209@dsl.pipex.com>
	 <1082203795.1043.18.camel@jzny.localdomain>
	 <4081A824.5020107@dsl.pipex.com>
	 <1082298480.1041.94.camel@jzny.localdomain>
	 <4082AE45.7030101@dsl.pipex.com>
	 <1082321582.1039.319.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ii7GnMs9b8DQn+4nkyhN"
Cc: Andy Furniss <andy.furniss@dsl.pipex.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
In-Reply-To: <1082321582.1039.319.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-ii7GnMs9b8DQn+4nkyhN
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2004-04-18 at 22:53, jamal wrote:
> On Sun, 2004-04-18 at 12:35, Andy Furniss wrote:
>=20
> > Connmark is a netfilter patch which is required by the type of P2P=20
> > limiting/marking projects on sf.net that could mark bittorrent traffic.=
=20
>=20
> just from the sounds of it, appears it may be able to mark a group of
> related flows with the same fwmark.

connmark is like nfmark but it marks the connection-entry in
ip_conntrack instead. And then you can "restore" that mark to the nfmark
of the packet at any time you want with filter rules.

> > will be OK with connbytes sometime. I don't really know how to use it,=20
> > but if it is possible to mark egress connections in output and have=20
> > connmark match their incoming packets that would be a solution. I=20
> > haven't got a clue if connmark can do this, though, just speculating.
> >
> > Does anyone else know, and why it's not compatable with connbytes?
> >=20
>=20
> some of the netfilter people should be able to help.

with connmark you mark the connection, and then you can "restore" that
mark to packets in either direction in the mangle table of iptables.

connmark isn't incompatible with connbytes. It's just that both patches
modify the same part of the code, a struct, and the patch program can't
handle that. You'll have to fix some rejects by hand, that's it.

--=20
/Martin

--=-ii7GnMs9b8DQn+4nkyhN
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBAgvHoWm2vlfa207ERAqw1AJ4t4XgDuenaJwtUHc1exZFdUbRWpwCgsBYW
R6K7gyIJe+8ntTACFfTvnjY=
=mTms
-----END PGP SIGNATURE-----

--=-ii7GnMs9b8DQn+4nkyhN--
