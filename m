From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 11/11] drivers/net/ethernet/intel: Remove
 useless return variables
Date: Sun, 01 Jun 2014 18:11:48 -0700
Message-ID: <1401671508.19767.11.camel@jtkirshe-mobl>
References: <1401542051-3174-11-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5981168014787477052=="
Cc: Alex, e1000-devel@lists.sourceforge.net, kernel-janitors@vger.kernel.org,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, John Ronciak <john.ronciak@intel.com>,
	Linux NICS <linux.nics@intel.com>, netdev@vger.kernel.org
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1401542051-3174-11-git-send-email-peter.senna@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============5981168014787477052==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2z8KW5XLcMh0yKC1wqgB"


--=-2z8KW5XLcMh0yKC1wqgB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-05-31 at 10:14 -0300, Peter Senna Tschudin wrote:
> This patch remove variables that are initialized with a constant,
> are never updated, and are only used as parameter of return.
> Return the constant instead of using a variable.
>=20
> Verified by compilation only.
>=20
> The coccinelle script that find and fixes this issue is:
> // <smpl>
> @@
> type T;
> constant C;
> identifier ret;
> @@
> - T ret =3D C;
> ... when !=3D ret
>     when strict
> return
> - ret
> + C
> ;
> // </smpl>
>=20
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
>=20
> ---
>  drivers/net/ethernet/intel/i40e/i40e_adminq.c   |   12 +++---------
>  drivers/net/ethernet/intel/i40evf/i40e_adminq.c |   12 +++---------
>  drivers/net/ethernet/intel/igb/e1000_82575.c    |   22
> ++++++++--------------
>  3 files changed, 14 insertions(+), 32 deletions(-)

I have added this patch to my queue, thanks.

--=-2z8KW5XLcMh0yKC1wqgB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTi89UAAoJEOVv75VaS+3OFjAP/iqXeKfP56T3jvOgmAzAAWP2
xxuBj+4gmB18NMC2ExusnfmpxWLgjS+sXMssLE0RxzDkJIEHkPk7EVe+l2ZuIfop
zJW+368LZy5EKS+R1TNz/dgiIvSddLcS96JjkzeD1ufVUvYVqQPMzOKArVPQdsxp
Vw/Sc9yAlyl8fLd7uwUCGnrZeql/CWsf1+OymlgUjyLUCL4XPmTGzz6gnlDR4tEK
mnEjlf/8vMMDZ1TemIfRd4E7zKKWsRetbbQg/z4VQ0qZZHG+hN6ArtCu8fIiPujo
stokUNAODVjSaptN51Odeej2ehIltk7RcaUKtwtqpWgiHeqeeh5ydhNSyVrrHnUG
tHKseLi85A87FEWlvyaDOLSbi6FQEjePPglYYK/QuYwvBe4CgTi//zhEPMyDNjxH
5dpmC356s7rmia7hVYC7GnBUJaVI9aA1KatsCEVAgJd/CyLdUbr3suL3JghtNtBb
RryBiEhRh4zHRfgVL1qi0JCD0DJeoCxBT4ChyfAjuHPLnBevNl2VZMjsYBj5/xhy
hFeAvc01ltb7DQEFux850SPF4CaNwLRnps/tS6ZFF4kJQZhVLiQ90JJf5y1vYLwk
eTh8Isxv6lwe1mBEUbPr2YQu9kAdR/QadmCIEK8NGkJCJPv/JWpczKviKA/w8wF+
ydPmtoURR4HK5vAeG2iF
=o1Vg
-----END PGP SIGNATURE-----

--=-2z8KW5XLcMh0yKC1wqgB--



--===============5981168014787477052==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their 
applications. Written by three acclaimed leaders in the field, 
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
--===============5981168014787477052==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5981168014787477052==--
