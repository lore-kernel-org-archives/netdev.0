From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next v2 35/71] skge/sky2/mv643xx/pxa168: Move the Marvell
 Ethernet drivers
Date: Sun, 31 Jul 2011 19:43:34 -0700
Message-ID: <1312166615.20837.128.camel@jtkirshe-mobl>
References: <1312082850-24914-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1312082850-24914-36-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20110731151116.647e9974@nehalam.ftrdhcpuser.net>
	 <1312151237.11635.5.camel@Joe-Laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-zQ/l2UwAXh0UfalktasH"
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Sachin Sanap <ssanap@marvell.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>,
	Mark Brown <markb@marvell.com>,
	Lennert Buytenhek <buytenh@marvell.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:16101 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752637Ab1HACng (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2011 22:43:36 -0400
In-Reply-To: <1312151237.11635.5.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-zQ/l2UwAXh0UfalktasH
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-07-31 at 15:27 -0700, Joe Perches wrote:
> On Sun, 2011-07-31 at 15:11 -0700, Stephen Hemminger wrote:
> > On Sat, 30 Jul 2011 20:26:54 -0700
> > Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > >  MARVELL MWIFIEX WIRELESS DRIVER
> > > @@ -5816,8 +5816,7 @@ SKGE, SKY2 10/100/1000 GIGABIT ETHERNET DRIVERS
> > >  M:	Stephen Hemminger <shemminger@linux-foundation.org>
> > >  L:	netdev@vger.kernel.org
> > >  S:	Maintained
> > > -F:	drivers/net/skge.*
> > > -F:	drivers/net/sky2.*
> > > +F:	drivers/net/ethernet/marvell/sk*
> > The old SysKonnect fddi driver should probably be moved in there
> > as well. It is called skfp.c
>=20
> fddi isn't ethernet so I think skfp.c should not be moved there.
>=20
>=20

Joe is right, the skfp (fddi) driver would go in driver/net/fddi/, which
is the next set of follow on patches I am working on.


--=-zQ/l2UwAXh0UfalktasH
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAABAgAGBQJONhLWAAoJECTsCADr/EWUZdEH/js8kAfOgn773oB3whVSA+96
I3qBXDP3TWg5fO9I+Z+xs3kON0NZaQ+MGNOhUXRSUi6YBEYpE0meCvQGahwB1FrE
4EUcp1pHKV3KJ3ez210Ib6oh+8jTXj0wZQXmELuIZSLsnLJiJEeKZ/1KIdX0G8Ln
+qmH27/qtEw431kIzS2dk11eDFFTJuYwQ3SA34Nzic//ktiZlfmpAePKK1hoDQEN
WZMrKBO1XhBC+R+vFz4spyfkRiVB7qfxwdc+/dtmVh5M+5W0wz9D1lbz/sRyqbPL
tD85hJPh91/4PSMup9udCnJc6hhbq0gF/fw72AMuRYDEB58wr7sTCTXkLitLRSM=
=6vhQ
-----END PGP SIGNATURE-----

--=-zQ/l2UwAXh0UfalktasH--

