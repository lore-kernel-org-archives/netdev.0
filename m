From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Thu, 23 Jun 2011 15:25:35 +1000
Message-ID: <20110623152535.e9ec4ad2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Thu__23_Jun_2011_15_25_35_+1000_4YcWZ3hFGHKYhAl7"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__23_Jun_2011_15_25_35_+1000_4YcWZ3hFGHKYhAl7
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_rea=
d_reg':
drivers/net/can/sja1000/sja1000_of_platform.c:61:2: error: implicit declara=
tion of function 'in_8'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_wri=
te_reg':
drivers/net/can/sja1000/sja1000_of_platform.c:67:2: error: implicit declara=
tion of function 'out_8'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_rem=
ove':
drivers/net/can/sja1000/sja1000_of_platform.c:81:2: error: implicit declara=
tion of function 'iounmap'
drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_pro=
be':
drivers/net/can/sja1000/sja1000_of_platform.c:113:2: error: implicit declar=
ation of function 'ioremap_nocache'
drivers/net/can/sja1000/sja1000_of_platform.c:113:7: warning: assignment ma=
kes pointer from integer without a cast

Since this file has not been changed recently, I suspect that this was
caused by commit b7f080cfe223 ("net: remove mm.h inclusion from
netdevice.h").

I have left the build broken for now since it is also broken for other
reasons.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Thu__23_Jun_2011_15_25_35_+1000_4YcWZ3hFGHKYhAl7
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOAs5PAAoJEDMEi1NhKgbsBjAH/1B9ibkttIMUXGf5GlbFfl/c
tFj0OZCTO0elt3yt7FEK28/K+Fz6YS0AU4nFbAw/KR/opWBD2CoB5YEZW+SBWLe7
L9VulRyyojEuRBcdxkcJhIGp2Pkal25T7l3tx+wzzLq958zgkpoYb/IkT2vxIvPE
T7kSQk4O9UBIIJ1/5CObmZN4r//YyOA0U39ZOXu67ACxzMaZLw53smuoEZfgqXrq
LnT1Atpyd+cZ5f2VWYkWtXQehC9bPS5DHqMLicWlnDYArNbA+3QvE1UPTS7agJ/M
7CqKMT73MrYVyxbSBaj4hyCcEPc67pfMT1QxmFaxFJDPC75bsO/4+rFrFykGpjQ=
=mGwc
-----END PGP SIGNATURE-----

--Signature=_Thu__23_Jun_2011_15_25_35_+1000_4YcWZ3hFGHKYhAl7--
