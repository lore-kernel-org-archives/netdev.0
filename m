From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next 1/6] e1000e: Avoid wrong check on TX hang
Date: Sun, 04 Dec 2011 22:25:17 -0800
Message-ID: <1323066318.24828.14.camel@jtkirshe-mobl>
References: <1322912671-6903-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1322912671-6903-2-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20111203.222659.277419094309941060.davem@davemloft.net>
	 <1322983717.24828.8.camel@jtkirshe-mobl>
	 <4EDC18D3.4060900@linux.vnet.ibm.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8bgsGF5ZJDb1NRRCcy9f"
Cc: Flavio Leitner <fbl@redhat.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:18728 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751018Ab1LEGZT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Dec 2011 01:25:19 -0500
In-Reply-To: <4EDC18D3.4060900@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8bgsGF5ZJDb1NRRCcy9f
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2011-12-04 at 17:05 -0800, Michael Wang wrote:
> On 12/04/2011 03:28 PM, Jeff Kirsher wrote:
>=20
> > On Sat, 2011-12-03 at 19:26 -0800, David Miller wrote:
> >> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> >> Date: Sat,  3 Dec 2011 03:44:26 -0800
> >>
> >>> +	if ((!adapter->tx_hang_recheck) &&
> >>
> >> Excessive parenthesis, please remove.
> >>
> >>> +		adapter->tx_hang_recheck =3D 1;
> >>
> >> This variable is a bool, set it to true or false.
> >>
> >>> +			adapter->tx_hang_recheck =3D 0;
> >>
> >> Likewise.
> >>
> >>> +	adapter->tx_hang_recheck =3D 0;
> >>
> >> Likewise.
> >=20
> > Michael/Flavio -
> >=20
> > To expedite this patch, I can make the changes that Dave is requesting
> > and re-submit v2 of the patch, if that is ok with you.
> >=20
>=20
> Hi, Jeff
>=20
> That's ok for me, I think it's good if you can work with Dave and make
> out a final version for us, if you want my help, please mail me at any
> time, I'm glad to work with you.
>=20
> Flavio:
> What's your opinion?
>=20
> Thanks,
> Michael Wang

I have the patch read to push, so I will go ahead an push v2 out
tonight.  Since I am making changes to your patch, I will be removing
your signed-off-by (and Flavio's) and keep you as a CC: so that you can
verify the changes I have made to resolve the issues that Dave saw.

Cheers,
Jeff

--=-8bgsGF5ZJDb1NRRCcy9f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJO3GPNAAoJEOVv75VaS+3OepEP/2DUOete134IMsa56qIu4B8b
Su6Nm5i3okv3QFa7jgPfgc5xwOC/uIvgWxvD6RDe5cEfAWafreoipceGMJrCVj3w
VSFaL8rXKRV7t+9hNBnvp14corQghY9l5jckujelE8d69G0gtFa7IWrW1FFTEKwM
O9CKYl941GOGeyJaJ0haws7pwTLujD35mmHPN+STT28uIcxsWLDz8adxxbGEQ/TZ
QUKMPl8DLX/q3opVXc+uIxQSX5aE6yvO2rjE13/JmQ5TC/jVC4c3fRwLDYJAN1ed
8SOEW1A/8yj3S5h/VtWDns5yke9i15/Hgk5+7onMYFuKHEInoGNlgdQXTwgnI5iN
u0YCrlg4bx0luuoutw53Cf6k5FGbRGBhJLnXDtd+Mm1k6Q/PnC3UPGGduRpEbR9c
T/oAifSCVD9icYtGQcB1UMOyMQz7yoGuF8fo2EoWRa9u/NpLebuuRnRqL0icuSIN
cSAQ2rI6++LJTSEsoWlfWmbhU9Zq66ci2oHG0bvdggcmDI1H7mAzwP01zQA5Ef42
MnvdMvr2QVh+5J1ICWpzlWLlQmp8S3g9QK4uqsG9ks7FKAY4fGW7dsFTMNzDDKSx
6Hl5XxovBsLJA+cCyc8RbziYO10hbZ/rXFCbzFkuBmaWUhFENb1ge4IgyjTyRVci
3HY5TbhEkczXzJyUJ/Yv
=MVUm
-----END PGP SIGNATURE-----

--=-8bgsGF5ZJDb1NRRCcy9f--
