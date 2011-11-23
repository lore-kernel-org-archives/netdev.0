From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] netrom: check that user string is terminated
Date: Wed, 23 Nov 2011 22:54:22 +0300
Message-ID: <20111123195421.GB3258@mwanda>
References: <20111123065240.GD6871@elgon.mountain>
 <4ECCAD38.9090309@bfs.de>
 <20111123191249.GB7260@linux-mips.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Pd0ReVV5GZGQvF3a"
Cc: walter harms <wharms@bfs.de>,
	"David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Ralf Baechle <ralf@linux-mips.org>
Return-path: <linux-hams-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111123191249.GB7260@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Pd0ReVV5GZGQvF3a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 23, 2011 at 07:12:49PM +0000, Ralf Baechle wrote:
> On Wed, Nov 23, 2011 at 09:22:16AM +0100, walter harms wrote:
>=20
> > I am not sure that it does what you intends.
> > mnemonic is an array and a  malicious use may fill it upto the last char
> > causing strlen go beyond. perhaps this may help:
>=20
> Correct, it makes thigs worse.  I'm going to reply in detail later tonigh=
t,
> have to bail out now.
>=20

Ok.  I said in a different thread that I was going to redo these
using strnlen() but I'll wait to read your comments.

regards,
dan carpenter


--Pd0ReVV5GZGQvF3a
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOzU9tAAoJEOnZkXI/YHqRsQgQAJgUTFnGqYHKmqJPECSmReCx
b9pTH2l1c2LTIC+9BXLmXbN8LRBomZMOjadtsmeBoIkSPkGYYhrApHPRTJuFCUwI
WF8XXchnBLJUCFf+Suje4bVVtbr2qxSBW0OMte48piEpm1031KyvEsIOshCQRhli
sdrnhEx/Ed2drdcEtFiGArejtKri0mpnTaWrC3GVDNSL0V5nOP8lsqmLCFuhFl1P
6qC8Kltdm7WHEMW/bWEwZ5dZpNkdt3mWQ+xNlCJd4OfuqeaN6THS+ee99Fpt6sIh
bG9qE7j5vQVMDZaSlrMxevFtna1hlMVmL/RKFGovshT9zIf+gAxUC3K+BAVd4tbc
CZmBrJgrxAwU5/jvYnybFJuUFofjxRoef+AR0NgbkXSyBy1mijnx0pPTia4IaBH4
HQwJVEeaauG/spElLjse4PZ2doZa6p+0I//n9ZjsPefxMmgTcstPY5p2Z/lxsocn
WgQ1GXpGMN5fmBqMAPFcyfjpJsrBJg1RJJdRgJALB1SSZ603ofzhdOXiJiviMOgJ
8dP0ckugZ40C3r2OjXV4mtxF753uG03/amq51oPFzMx8SvOrGxwCHthcPUzyIAjk
tPH8oHIuYPaGuiDe9llcfinJnyl7TWUuZkO28gUoKDhUeHuq9GfrPgtddcgSNpza
4As3Z6w+br4eCP+qluMj
=JhGF
-----END PGP SIGNATURE-----

--Pd0ReVV5GZGQvF3a--
