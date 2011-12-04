From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Sat, 03 Dec 2011 23:28:36 -0800
Message-ID: <1322983717.24828.8.camel@jtkirshe-mobl>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111203.222659.277419094309941060.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9IbfqiBtL0Cm5t8Drb2m"
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>,
	Flavio Leitner <fbl@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:29149 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751630Ab1LDH2h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Dec 2011 02:28:37 -0500
In-Reply-To: <20111203.222659.277419094309941060.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9IbfqiBtL0Cm5t8Drb2m
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Sat,  3 Dec 2011 03:44:26 -0800
>=20
> > +	if ((!adapter->tx_hang_recheck) &&
>=20
> Excessive parenthesis, please remove.
>=20
> > +		adapter->tx_hang_recheck =3D 1;
>=20
> This variable is a bool, set it to true or false.
>=20
> > +			adapter->tx_hang_recheck =3D 0;
>=20
> Likewise.
>=20
> > +	adapter->tx_hang_recheck =3D 0;
>=20
> Likewise.

Michael/Flavio -

To expedite this patch, I can make the changes that Dave is requesting
and re-submit v2 of the patch, if that is ok with you.

-Jeff

--=-9IbfqiBtL0Cm5t8Drb2m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO2yEkAAoJEOVv75VaS+3OY9kQAKQpD0KBRBXV1OoZiXaIE01W
hHPr5TE5XidVeSrWeG7x7C8Z/iSXvl62mXyu8SRqRp2hS4pLGP5IL1c6+AAyD9Cw
tqZlIl8jSUR4m9wfeY4w6XZ+yi6qFlcjB1tXiqId4Fqnealr2hCD/msZqFtcIlTX
w0BqhWa5BzAWbZhZ1deyRBA3NZnPD7URRQtmwp4d1DeKm5j57C4tGUnDRUD/su/T
mtSaWqzFX2Hao81/HNtMJnUjg8KfWjE4uTLxciFJoFlFoNFTTfJ4zfzbxmJ9JlNy
q3o9418K4lv850uxzUIh7UsenALj2DPymiOOnGWu98lc9gD+KFTlUrsndHZ1WSPC
Xjtt0/xLhDNYC1lt0O5WIQny5drwwfkQ5AOhBixEossCJbiOey1RSz0BrsZRlwoC
zbVp99FZ8AD0kh37HRPoS1Wl0hr0Dle01IUlshtYA8M7gKFkBVUZ4SxZtlWLBmAV
M+QaZFW7kiyHkbscnbjkVeQa4ajNh/GdYYE9Ap7KsO3vZJ0hblFO8BI/ZxIO/4xm
VDykHK3TUtzM8Czb+Wc8IgzmkK+Qcn2d3ogbs4A/VyTPmN9R4WEhRXt7i32OUOOK
Cd8mmgjSudte1W+JP1Z0fvurNZVf2gOHaeSKM9GcLfPwK6oehDVwqIgpPeH4qKpB
fiY2XoxYEd9jqKJJfg65
=Pglt
-----END PGP SIGNATURE-----

--=-9IbfqiBtL0Cm5t8Drb2m--
