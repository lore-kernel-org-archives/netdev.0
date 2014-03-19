From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] INTEL-IGB: Convert iounmap to
	pci_iounmap
Date: Tue, 18 Mar 2014 21:33:06 -0700
Message-ID: <1395203586.2050.7.camel@jtkirshe-mobl>
References: <1395159085-11691-1-git-send-email-peter.senna@gmail.com>
	<1395159085-11691-2-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4161537122662688588=="
Cc: kernel-janitors@vger.kernel.org, linux.nics@intel.com,
	e1000-devel@lists.sourceforge.net, bruce.w.allan@intel.com,
	jesse.brandeburg@intel.com, linux-kernel@vger.kernel.org,
	john.ronciak@intel.com, netdev@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1395159085-11691-2-git-send-email-peter.senna@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============4161537122662688588==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-3zjns+ZL2TfZRMyWNk/3"


--=-3zjns+ZL2TfZRMyWNk/3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-03-18 at 17:11 +0100, Peter Senna Tschudin wrote:
> Use pci_iounmap instead of iounmap when the virtual mapping was done
> with pci_iomap. A simplified version of the semantic patch that finds
> this
> issue is as follows: (http://coccinelle.lip6.fr/)
>    =20
> // <smpl>
> @r@
> expression addr;
> @@
> addr =3D pci_iomap(...)
>=20
> @rr@
> expression r.addr;
> @@
> * iounmap(addr)
> // </smpl>
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> ---
>  Tested by compilation only.
>=20
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)

Thanks Peter, I have added you patch to my queue.

--=-3zjns+ZL2TfZRMyWNk/3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTKR4CAAoJEOVv75VaS+3O2GYP/1ALxiYvn0+dv/9+AObLK5E1
20+vVgc2arJO3SBxH8ItcROvatSXnnuVGIVYDr35ogGxutye/onu+pcxvNHEyjal
0mlfBT6G5HfNrg6ahlMwf3VbB57aUgjY4SHYHU5EC+ogDKLdOhogMdNH+EN1UtCt
SEyUVfz7HWrzq/i+otW7tUCflz8mK3KFS+HhAl1y5tsGiA/z85dG9F66lm5nPt0D
NA52OBorr7auzD2lUGRF4TEPZIJs/D1ShSsTyg21IZj/JkkGWpvvVcHBp0yyXSiR
O8cKg3gMmv0dEV43DxGOPrvqRJ2T/rG7bgW4IMgIjXRj4EGHljhichpNIj5iXV3Q
9KHgp1UdPnjOJHTzy6bIYyV1mEmcWckU9MJmU9K+p58UovEtXB37YKcPWLDd1zbN
7k5tlG/C/LUIXgKyjCXuHmEpSnBGEjwGMwC1cOAWCimpTug2N4+tYDBDhtrXKSDs
qZObjAryn3521riFtAvP9CMct0JTDlnwni02Nnv5Np31RPFFumr0ZRDmVZTu/pOP
qMq5A7/OxdOripXzHIPvzlqr2qZ822n5U6Fe1nqUZ7gc1/cmnz6u4dH/fFp/mrW9
0nRlhxK0WvzQLi0xi9uaQvU/07gAI17A7wTNWfA8Vlsf+Hq6N+uSKteb3UMosEH6
G3HAHy5UB23he3G0wXka
=20Hr
-----END PGP SIGNATURE-----

--=-3zjns+ZL2TfZRMyWNk/3--



--===============4161537122662688588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their
applications. Written by three acclaimed leaders in the field,
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/13534_NeoTech
--===============4161537122662688588==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============4161537122662688588==--
