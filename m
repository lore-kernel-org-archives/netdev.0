From: Harald Welte <laforge@gnumonks.org>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Sun, 19 Sep 2004 00:02:11 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918220211.GI6005@sunbeam.de.gnumonks.org>
References: <20040917230803.GJ2678@sunbeam.de.gnumonks.org> <20040918.084304.75142669.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="va4/JQ6j8/8uipEp"
Cc: netdev@oss.sgi.com, usagi-users@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040918.084304.75142669.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--va4/JQ6j8/8uipEp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Sep 18, 2004 at 08:43:04AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:

> > I'm experiencing some strange problems on a 2.6.8.1 vanilla kernel.  I
> > tried to reproduce it with a minimal system:
> :
> > (intermixed with a 'ip6tables -A OUTPUT -j LOG' and '-A INPUT -j LOG'
> > rules for diagnostics).
>=20
> It is not minimum with ip6tables. :-)

i just added ip6tables to get some log messages on incoming/outgoing
packets (small embedded system with no tcpdump).

> Anyway, please try the latest bk tree.
> There are may fixes in it.

In fact the problem disappeared with 2.6.9-rc2.  I thought the idea of
2.6.8.x is to have real show-stopper bugfixes go into that series... and
if something like this is severely broken in ipv6, I would say it
rectifies a 2.6.8.2 release, don't you think?

I have to admit that this is the first time that my linux ipv6 setup
breaks within four years...

Now I'm stuck with another issue:  The interfaces suddenly no logner
get any link-local addresses:

/proc/net # ip -6 addr
2: eth1: <BROADCAST,MULTICAST,UP> mtu 1500 qlen 1000
    inet6 3ffe:400:900:1100::1/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 3ffe:400:900:1100:207:e9ff:fe09:b920/64 scope global=20
       valid_lft forever preferred_lft forever
3: lo: <LOOPBACK,UP> mtu 16436=20
    inet6 ::1/128 scope host=20
       valid_lft forever preferred_lft forever
4: eth0.2: <BROADCAST,MULTICAST,UP> mtu 1500=20
    inet6 3ffe:400:900:1101::1/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 3ffe:400:900:1101:207:e9ff:fe09:b920/64 scope global=20
       valid_lft forever preferred_lft forever
5: eth0.3: <BROADCAST,MULTICAST,UP> mtu 1500=20
    inet6 3ffe:400:900:9999::1/64 scope global=20
       valid_lft forever preferred_lft forever
    inet6 3ffe:400:900:9999:207:e9ff:fe09:b920/64 scope global=20
       valid_lft forever preferred_lft forever
8: tap0: <BROADCAST,MULTICAST,UP> mtu 1399 qlen 1000
    inet6 3ffe:400:900:3001::2/64 scope global=20
       valid_lft forever preferred_lft forever
/proc/net # uname -r
2.6.9-rc2

Thanks!

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--va4/JQ6j8/8uipEp
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBTLBjXaXGVTD0i/8RAjE1AKCtC8gWtcWurCmUF3bslFQd/HP5/ACfcY8z
fR6CakIsZ65ssMPONoQEthc=
=fN3p
-----END PGP SIGNATURE-----

--va4/JQ6j8/8uipEp--
