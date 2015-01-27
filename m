From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3/3] Revert "drivers/net: Disable UFO through virtio"
Date: Tue, 27 Jan 2015 02:51:09 +0000
Message-ID: <1422327069.31046.243.camel@decadent.org.uk>
References: <1422283026-27832-1-git-send-email-vyasevic@redhat.com>
	<1422283026-27832-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============9085797363852748619=="
Cc: netdev@vger.kernel.org, edumazet@google.com, mst@redhat.com,
	virtualization@lists.linux-foundation.org
To: Vladislav Yasevich <vyasevich@gmail.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1422283026-27832-4-git-send-email-vyasevic@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org


--===============9085797363852748619==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-pd45T3WrkEvRm/YPwoFI"


--=-pd45T3WrkEvRm/YPwoFI
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-01-26 at 09:37 -0500, Vladislav Yasevich wrote:
> This reverts commit 3d0ad09412ffe00c9afa201d01effdb6023d09b4.
>=20
> Now that UFO functionality can correctly track the fragment
> id has been selected and select a fragment id if necessary,
> we can re-enable UFO on tap/macvap and virtio devices.
>=20
> Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
[...]

Acked-by: Ben Hutchings <ben@decadent.org.uk>

I think this is sensible even before your other patches.

Ben.

--=20
Ben Hutchings
When in doubt, use brute force. - Ken Thompson

--=-pd45T3WrkEvRm/YPwoFI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVMb9Iue/yOyVhhEJAQoRERAAj62T1Ek+plRRurjLWLSBoxZ05jobjeWp
YWkgDW615F9IPcpdZpswBoDhq7fqqo7UxyLY+KzWkzzWHVVAZQuJkbG5WEpHXFp3
+GfXr39P0mnkvdn87iigUR2f04JUM615iThq9qh33XbpTsNCT/fI2nGI2Lt9yo+S
GsML3P18ZcOF5ByEEFsoZp99dwdAbBaEbEjPJGLlZ64KkwiPSkWk1LIWBCOJHozl
iyxvICCBGBWY8L0KEIoqYPOmZ7/lgrXHKME2GmiTiRN+DHehTryfoj/eQKTSKl08
Xr9aUSHXmy2gGJD8d+71QtykohXlkpmkVqBVz4MCLPdx2wuS/KRyWe4sZbJMCVHO
WTs68v6RgqyadZkwC83cbx7pEydL0N+KkODPiSl6lq6WLm8EM8o/LTYyu0nfm3S0
LK0zy6MBvSsDHReKI3zGctIt4YcUC5gVC9FLac2iBKytWMXDtd9O00giC9GDD2aR
qH4+ofm+uJY4z/VxMEIxQyd+FouQlCtK8PnDw4nSs43/r116Sq8GPhYfUNGh8LTF
SRnsrAoVrvZLXthmACJyfdqZ88IfXRdEO8YdZtaXmfunECZRgW8GnoW16sgn6TMo
AyUZt/uv8TvapG16OKbuVPHofM0QtaMqyJ/WLStQLUH8yO2sWCoYVyFs1UteslVF
ETAbq3wmQ9o=
=qPjJ
-----END PGP SIGNATURE-----

--=-pd45T3WrkEvRm/YPwoFI--

--===============9085797363852748619==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Virtualization mailing list
Virtualization@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/virtualization
--===============9085797363852748619==--
