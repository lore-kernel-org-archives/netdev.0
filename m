From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] e1000e: Change wthresh to 1 to avoid possible Tx
 stalls.
Date: Wed, 06 Jun 2012 21:52:32 -0700
Message-ID: <1339044752.2075.14.camel@jtkirshe-mobl>
References: <20120606174355.823e9aa7.shimoda.hiroaki@gmail.com>
	 <1339030752.2075.1.camel@jtkirshe-mobl>
	 <1339043085.26966.77.camel@edumazet-glaptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-31Frtu/xhsE4Cc2dMMtZ"
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"denys@visp.net.lb" <denys@visp.net.lb>,
	"therbert@google.com" <therbert@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:31286 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751728Ab2FGEwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2012 00:52:33 -0400
In-Reply-To: <1339043085.26966.77.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-31Frtu/xhsE4Cc2dMMtZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2012-06-07 at 06:24 +0200, Eric Dumazet wrote:
> On Wed, 2012-06-06 at 17:59 -0700, Jeff Kirsher wrote:
>=20
> > After further internal review, NACK.
> >=20
> > This patch will cause unacceptable performance issues with non-ESB2
> > parts.
> >=20
> > I am dropping this patch from my queue.
> >=20
>=20
> I'd like you share your performance numbers before NACKing this patch.
>=20
> What is the alternative patch you guys have ?
>=20

Jesse did not share any performance numbers with me, I am sure he can
give some background tomorrow when he is back online.

I am working on an alternative patch now and should have something to
share tomorrow.

--=-31Frtu/xhsE4Cc2dMMtZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJP0DOQAAoJEOVv75VaS+3OvGEP/0me6gk+AHVCtQtova+xfSPG
+qgoStTQ8q+fDoeXuwaKuhsKU3Ol/kZvt6NxKhyz6rTvboDrRT0DJrtpv5sHqn0M
OZl1M8XJ1m33L8X/tN6/vBORxnmGTbd7cGhsBMAUhBIbPgX2UACkB65Fm8PhquCv
xsf/tzTMd6oakSfdd/bWHRa/y0DMul4B3Aywyuue3RdNmD6YqXQQX3FuIdB6KUTz
VD+RUjWhdSJaWmbJyL5bMdxIw5mA9GGu3Xj6S6vEwivd2ErMzhOBG+28CLAxt1KN
64eft2G6Ztus5IO4IWBffi9ZFdQ6FXaMzuiOarqqDLak6A2auXNk3mW4t1cebKxA
3VN0kjqYRITudw4fKkgcgPasgBNcCOmbOH3/IShtCP8qiRWwdG8HMIDJScnLKBzV
RP/PsyMWwxPOsWCBE33qjrmIeDg4RaNauux/ZM9almSIaA5uix/gkDB61j+bVY3N
uTdktmIULnrUjGUMfqvbigFoAja4j6CqJwukpIzNlJkmaGGakNeypDYjnQXOUIqu
KkJ4QAdfcSDg0OUD2qdA20+hMfYOtZWtbnPaaMnxNcqP6VaBTyuL4nMA16BKpsmN
vvJeGCvFQYQAVV10y1D8MbOCB1PN+grFenQRHaoaBINahJUp1absUzPQiMyUoWul
VkVdnsuEI0wGOYgcGToe
=cKYj
-----END PGP SIGNATURE-----

--=-31Frtu/xhsE4Cc2dMMtZ--
