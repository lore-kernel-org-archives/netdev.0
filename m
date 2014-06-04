From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] net: ethernet: intel: ixgbe:
 ixgbe_main.c: Cleaning up missing null-terminate after strncpy call
Date: Wed, 04 Jun 2014 16:45:17 -0700
Message-ID: <1401925517.19767.175.camel@jtkirshe-mobl>
References: <1401917380-2772-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============5675933098046855784=="
Cc: Don@isotope.jf.intel.com, NICS <linux.nics@intel.com>,
	Linux@isotope.jf.intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Jesse Brandeburg <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org
To: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1401917380-2772-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============5675933098046855784==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XKWcFaUQst+hbSnjUrfr"


--=-XKWcFaUQst+hbSnjUrfr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-06-04 at 23:29 +0200, Rickard Strandqvist wrote:
> Added a guaranteed null-terminate after call to strncpy.
>=20
> This was partly found using a static code analysis program called
> cppcheck.
>=20
> Signed-off-by: Rickard Strandqvist
> <rickard_strandqvist@spectrumdigital.se>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

NAK, I won't be picking this patch up based on Mark's and Joe's
feedback.

--=-XKWcFaUQst+hbSnjUrfr
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAABCgAGBQJTj6+NAAoJEOVv75VaS+3OVJUP/1YONvsZ0hxDz5IMn59SXzNf
359R8nBq00KUIKxCgb9StrPdXCsxaAIPCDTmaU3/bixQq2R36lrlxT3im6MtoBDG
R/Mbh/TDokG9/UTV+5RBw+n+s5sojeL2HRZzhrUCid0NmQVdJYdPWxji5d+DSBnT
pYLBTyWV0drXYflK8S2nRtyE2qg7TwXN1L0ZMFadzN8T0D/1OFaXmhrVkQRnteYQ
ozJ+O8rRDggltWn/nc+zHwvce7aDVXFJGo5pUTtsZ2dwC3p1nB/pkA/5ooT82Z2t
zn8KD15XA9WSKRkaWmYOhV6+bahUar2uXhGJ8+EcUTkJEbuWZHLS9RBAAdgQVsAf
m1rlouzi9Zxia2KP+HHixlsoPor/8lO39WVUPgmsDxMK3K88FE/R73DZ3pYUMdQo
TK2OIR1LY2wEGVXqErHl80rLDp/ZVU/vj+fSjQzd47x3bMcMY/jsDgwU2akjms4O
nC/cVox/xPg3LdzFCW4S1XEm+Q/2LkniclFhCpVUJzOWjldzbQ+Ng44LJYNxoxmS
Qd9xRce9dKOOdNbWDXjEL0yvSTis9hi/8+glsfp080BoObN2QbtxynRfG9mLWRCk
WObnciTF9ya4/AKpvV+RiW79dRVmdxRwb+1Hcagjj2umKaHV53bSbKIgJPJOXHoj
aOK7rDaP1B3lVvbQLk1D
=9W/H
-----END PGP SIGNATURE-----

--=-XKWcFaUQst+hbSnjUrfr--



--===============5675933098046855784==
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
--===============5675933098046855784==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============5675933098046855784==--
