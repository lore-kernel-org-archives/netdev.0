From: Joerg Dorchain <joerg@dorchain.net>
Subject: Re: Prism54 AP WPA using Hostap and WDS
Date: Mon, 8 Nov 2004 15:17:51 +0100
Message-ID: <20041108141751.GM23338@Redstar.dorchain.net>
References: <20041104032219.GU388@ruslug.rutgers.edu>
	<20041105162037.GN388@ruslug.rutgers.edu>
	<20041105162811.GP388@ruslug.rutgers.edu>
	<20041108122922.GV388@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0180531483=="
Return-path: <prism54-devel-bounces@prism54.org>
To: prism54-devel@prism54.org, Netdev <netdev@oss.sgi.com>,
	Jouni Malinen <jkmaline@cc.hut.fi>
In-Reply-To: <20041108122922.GV388@ruslug.rutgers.edu>
List-Unsubscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=unsubscribe>
List-Archive: <http://prism54.org/pipermail/prism54-devel>
List-Post: <mailto:prism54-devel@prism54.org>
List-Help: <mailto:prism54-devel-request@prism54.org?subject=help>
List-Subscribe: <http://prism54.org/mailman/listinfo/prism54-devel>,
	<mailto:prism54-devel-request@prism54.org?subject=subscribe>
Mime-version: 1.0
Sender: prism54-devel-bounces@prism54.org
Errors-To: prism54-devel-bounces@prism54.org
List-Id: netdev.vger.kernel.org


--===============0180531483==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="L2zmpNdaDxUzilj2"
Content-Disposition: inline


--L2zmpNdaDxUzilj2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Nov 08, 2004 at 07:29:22AM -0500, Luis R. Rodriguez wrote:
> >=20
> > > Access Point WPA support (NEW) (requires hostapd)
> > > Access Point WDS Support (NEW)
> >=20
> > For your convenience, here are some links for those of you wishing to t=
est:
> >=20
> > http://prism54.org/pub/linux/snapshot/tars/prism54-cvs-latest.tar.bz2
>=20
> The kernel patches were broken for WDS support as I forgot to include
> isl_wds.[ch] in the patch process. I have now fixed this in my script.
> The patches should now work.

The built outside the kernel tree (linus 2.6.9) still has not changed.
There is still a include for isl_wds.h missing in islpci_eth.c, and
"dev_alloc" is still an undefined symbol.

Bye,

Joerg

--L2zmpNdaDxUzilj2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQFBj4APjY4+4PdzvOARAiZrAJ9hUBm3oetGO2rKL1TJ72/w8pGupgCfdtmY
Fnv+BSCeD5HhSed0EdZkJEo=
=M9TB
-----END PGP SIGNATURE-----

--L2zmpNdaDxUzilj2--

--===============0180531483==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Prism54-devel mailing list
Prism54-devel@prism54.org
http://prism54.org/mailman/listinfo/prism54-devel

--===============0180531483==--
